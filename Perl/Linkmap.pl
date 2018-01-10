#!/usr/local/bin/perl
use diagnostics;
use strict;


if (@ARGV)
{
 my $linkmapFilePath = $ARGV[0];
 if (defined $linkmapFilePath)
	{
  open(LINKMAPFILE, $linkmapFilePath);

#数组或者是散列中只能存标量
my @objectFiles = ();
my @objectSymbols = ();
while(<LINKMAPFILE>)
{
    chomp();
    #增加一个？进行模式匹配，在静态库中的目标文件会是以括号的形式呈现，而源码形式的目标文件是没有括号的   
    my @files = /\[\s*(\d{1,})]\s.+\/(.+o\)?$)/;
    if (@files)
    {
        #将一个数组的指针(标量)传给另一个数组
        push(@objectFiles, \@files);
        #my ($findex, $name) = @files;
        #printf ("index =%s, name =%s\n", $findex, $name);
        next;
    }

    my @symbols =  /(0x.{8,})\t(0x.{8})\t\[\s*(\d{1,})]\s([+|-].+\s.+)/;
    #my @symbols =  /(0x.{8})\t0x.0+([1-9A-F]{1,})\t\[\s*(\d{1,})]\s([+|-].+\s.+)/;

    if (@symbols)
    {
        push(@objectSymbols, \@symbols);
        #my($address, $size, $index, $symble) = @symbols;
        #printf ("address =%s, size =%s, index =%s, symble =%s\n", $address, $size, $index, $symble);
    }
}

close(LINKMAPFILE);

my %oFileSize = (); #objectName => size
my @symbolsInfos = ();
foreach my $file (@objectFiles)
{
    my ($oIndex, $name) = ($file->[0], $file->[1]);
    my $objectSize = 0;
    foreach my $symbol (@objectSymbols)
    {
        my($address, $size, $sIndex, $symbolName) = ( $symbol->[0], hex($symbol->[1]), $symbol->[2], $symbol->[3]);
        if ($sIndex == $oIndex) {
            my @symbolsInfo = ();
            $objectSize = $objectSize + $size;
            
            push(@symbolsInfo, $address);
            push(@symbolsInfo, $name);
            push(@symbolsInfo, $size);
            push(@symbolsInfo, $symbolName);
            
            push(@symbolsInfos, \@symbolsInfo);
            next;
        }
        #printf ("address =%s, size =%s, index =%s, symble =%s\n", $symbol->[0], hex($symbol->[1]), $symbol->[2], $symbol->[3]);
    }
    $oFileSize{$name} = $objectSize;

    #printf ("index =%s, name =%s\n", $oIndex, $name);
}

my $symbolName;
my $symbolAddress;
my $symbolObjectFile;
my $symbolSize;

format  SYMBOLFORMATTER =
@* @* @* ^*
$symbolAddress,$symbolSize,$symbolObjectFile,$symbolName
.

if (open(SYMBOL, ">symbol.txt"))
{
      select(SYMBOL);
     $~ = 'SYMBOLFORMATTER';
     foreach my $item (@symbolsInfos)
     {
      
      $symbolAddress = $$item[0];
      $symbolObjectFile = $$item[1];
      $symbolSize = $$item[2];
      $symbolName = $$item[3];
      write SYMBOL;
     }
     close(SYMBOL)
}




sub desc_sort_ofile
{
    $oFileSize{$b} <=> $oFileSize{$a};
}

my $summerySize = 0;

my $object;
my $osize;

format  OBJECTFORMATTER =
--------------------------------------------------
@<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
$object
^<<<<<<<<
$osize
.

select(STDOUT);
$~ = 'OBJECTFORMATTER';

foreach my $key (sort desc_sort_ofile(keys(%oFileSize)))
{
					$object = $key;
     $osize = $oFileSize{$key};
     #if ($object !~ /MTA/){
     $summerySize += $osize;
     write ;
     #}
     
    
    #my $value = $oFileSize{$key};
    #my $lkey = length($key);
    #my $lvlaue = length($value);
    #my $ll = 100 - $lkey - $lvlaue;
    #my $f = "%-".$ll."s%d\n";
    # printf ("$f", $key, $oFileSize{$key}); #无法完全对齐的原因是大小写字符实际显示的长度
}

printf("This image size is %s kb", $summerySize/1204);

} else {
	printf ("Can't find the Linkmap file paramater in ARGV");
}
} else {
	printf ("ARGV is empty");
}
