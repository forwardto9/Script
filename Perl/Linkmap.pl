#!/usr/local/bin/perl
use diagnostics;
#use strict;

require("Object.pl");


open(LINKMAPFILE, "XG-SDK-LinkMap-normal-arm64.txt");

#数组或者是散列中只能存标量
my @objectFiles = ();
my @objectSymbols = ();
while(<LINKMAPFILE>) {
    chomp();
    my @files = /\[\s*(\d{1,})]\s.+\/(.+o$)/;
    my $fileO = $#files;
    if ( $fileO > 0) {
        #将一个数组的指针(标量)传给另一个数组
        push(@objectFiles, \@files);
        #my ($findex, $name) = @files;
        #printf ("index =%s, name =%s\n", $findex, $name);
    }
    
    my @symbols =  /(0x.{8})\t(0x.{8})\t\[\s*(\d{1,})]\s([+|-].+\s.+)/;
    #my @symbols =  /(0x.{8})\t0x.0+([1-9A-F]{1,})\t\[\s*(\d{1,})]\s([+|-].+\s.+)/;
    my $symbolO = $#symbols;
    if ($symbolO > 0) {
        push(@objectSymbols, \@symbols);
        #my($address, $size, $index, $symble) = @symbols;
        #printf ("address =%s, size =%s, index =%s, symble =%s\n", $address, $size, $index, $symble);
    }
}

close(LINKMAPFILE);

my %oFileSize = (); #objectName => size
foreach my $file (@objectFiles) {
    my ($oIndex, $name) = ($file->[0], $file->[1]);
    my $objectSize = 0;
    foreach my $symbol (@objectSymbols) {
        my($address, $size, $sIndex, $symble) = ( $symbol->[0], hex($symbol->[1]), $symbol->[2], $symbol->[3]);
        if ($sIndex == $oIndex) {
            $objectSize = $objectSize + $size;
            next;
        }
        #printf ("address =%s, size =%s, index =%s, symble =%s\n", $symbol->[0], hex($symbol->[1]), $symbol->[2], $symbol->[3]);
    }
    $oFileSize{$name} = $objectSize;
    
    #printf ("index =%s, name =%s\n", $oIndex, $name);
}

sub desc_sort_ofile {
    $oFileSize{$b} <=> $oFileSize{$a};
}


format  OBJECTFORMATTER =
--------------------------------------------------
@<<<<<<<<<<<<<<<<<<<<<<
$object
^<<<<<
$osize
.

select(STDOUT);
$~ = OBJECTFORMATTER;

foreach my $key (sort desc_sort_ofile(keys(%oFileSize))) {
     $object = $key;
     $osize = $oFileSize{$key};
    write ;
    #my $value = $oFileSize{$key};
    #my $lkey = length($key);
    #my $lvlaue = length($value);
    #my $ll = 100 - $lkey - $lvlaue;
    #my $f = "%-".$ll."s%d\n";
    # printf ("$f", $key, $oFileSize{$key}); #无法完全对齐的原因是大小写字符实际显示的长度
 }