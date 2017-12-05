#!/usr/local/bin/perl
use diagnostics;
use strict;

open(LINKMAPFILE, "XG-SDK-LinkMap-normal-arm64.txt");
while(<LINKMAPFILE>) {
    chomp();
    my @files = /\[\s*(\d{1,})]\s.+\/(.+o$)/;
                my $fileO = $#files;
    if ( $fileO > 0) {
        my ($findex, $name) = @files;
        printf ("index =%s, name =%s\n", $findex, $name);    
    }
    
    my @symbols =  /(0x.{8})\t(0x.{8})\t\[\s*(\d{1,})]\s([+|-].+\s.+)/;
    my $symbolO = $#symbols;
    if ($symbolO > 0) {
        my($address, $size, $index, $symble) = @symbols;
        printf ("address =%s, size =%s, index =%s, symble =%s\n", $address, $size, $index, $symble);
    }
    
}
close(LINKMAPFILE);