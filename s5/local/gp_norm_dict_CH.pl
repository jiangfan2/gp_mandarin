#!/usr/bin/env perl

use strict;
use warnings;
use Carp;

# normalizes the GlobalPhone Mandarin dictionary.
# Removes the braces that separate word & pronunciation. 
# Removes the 'M_' marker from each phone.
# Converts   words to UTF8 and lowercases everything

BEGIN {
    @ARGV == 1 or croak "USAGE:  <DICT>
$0 /mnt/corpora/Globalphone/GlobalPhoneLexicons/Mandarin/Mandarin-GPDict.txt
";
}

use Unicode::Normalize;

my ($in_dict) = @ARGV;
binmode STDOUT, ":encoding(utf8)";

open my $L, '<', $in_dict or croak "Problems with $in_dict $!";
LINE: while ( my $line = <$L>) {
    # files may have CRLF line-breaks!
    $line =~ s/\r//g;
    next LINE if($line =~ /\+|\=|^\{\'|^\{\-|\<_T\>/);

    $line =~ m:^\{?(\S*?)\}?\s+\{?(.+?)\}?$: or croak "Bad line: $line";
    my $word = $1;
    my $pron = $2;
    # Silence will be added later to the lexicon
    next if ($pron =~ /SIL/);

    # First, normalize the pronunciation:

    $pron =~ s/\{//g;


    # remove leading or trailing spaces
    $pron =~ s/^\s*//;
    $pron =~ s/\s*$//;

    $pron =~ s/ WB\s?\}//g;
    $pron=~ s/\}//g;
    # Normalize spaces
    $pron =~ s/\s+/ /g;
    # Get rid of the M_ marker before the phones
    $pron =~ s/M_//g;

    # Next, normalize the word:
    # Pron variants should have same orthography
    $word =~ s/\(.*\)//g;
    $word =~ s/^\%//;
    next if($word =~ /^\'|^\-|^$|^\(|^\)|^\*/);
    # Check for spurious prons: quick & dirty!
    my @w = split(//, $word);
    my @p = split(/ /, $pron);
    next if (scalar(@p)<=5 && scalar(@w)>scalar(@p)+5);
    $word = &rmn2utf8_SW($word);
    $word = lc $word;
    print "$word\t$pron\n";
}
close $L;

sub rmn2utf8_SW {
    my ($in_str) = "@_";
    $in_str =~ s/\~A/\x{00C4}/g;
    $in_str =~ s/\~O/\x{00D6}/g;
    $in_str =~ s/\~U/\x{00DC}/g;
    $in_str =~ s/\~a/\x{00E4}/g;
    $in_str =~ s/\~o/\x{00F6}/g;
    $in_str =~ s/\~u/\x{00FC}/g;
    $in_str =~ s/\~s/\x{00DF}/g;
    # recompose & reorder canonically
    return NFC($in_str);
}
