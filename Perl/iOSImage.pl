#!/usr/local/bin/perl
use diagnostics;
use strict;
use Data::Dumper;


use constant SPACE => " ";
my $imageFIlePath;
if (@ARGV)
{
 $imageFIlePath = $ARGV[0];
 if ((length $imageFIlePath) == 0) {
	printf ("Can't find the image file paramater in ARGV");
	exit 0;
 }
} else {
	printf ("ARGV is empty");
	exit 0;
}


#my $imageFIlePath = "/Users/uwei/Library/Developer/Xcode/DerivedData/TestLinkMapWithOC-gmvzvpmjiwrokhdqdtmsmkungdwx/Build/Products/Debug/TestLinkMapWithOC";
my $otoolCommand = "otool";
my $optionChar = "-";
my $segmentOption = "s";
my $objcOption = "ov";
my $disassembledOption = "V";
my $otoolSegmentPipe = $otoolCommand.SPACE.$optionChar.$segmentOption;
my $otoolObjcClassPipe = $otoolCommand.SPACE.$optionChar.$objcOption;
my $otoolSeletorPipe = $otoolCommand.SPACE.$optionChar.$disassembledOption.SPACE.$optionChar.$segmentOption.SPACE;
my $pipe = SPACE."|".SPACE;
my $dataSegment = "__DATA";
my $textSegment = "__TEXT";
my $classlistSection = "__objc_classlist";
my $classrefsSection = "__objc_classrefs";
my $methodListSection = "__objc_methname";
my $selectorrefsSection = "__objc_selrefs";
my $classListPipe = $otoolSegmentPipe.SPACE.$dataSegment.SPACE.$classlistSection.SPACE.$imageFIlePath.$pipe;
printf("-----------------------------------All Classes Address-----------------------------------\n");
my @classList = ();
open(OTOOIMAGE, "$classListPipe");
while(<OTOOIMAGE>)
{
                chomp();
                my @address = /.{16}\t(.{24})(.{24})/;
                my $addressCount = $#address;
                if ($addressCount > 0)
                {
                        my($firstAddress, $secondAddress) = @address;
                        foreach my $littleAddress(@address)
                      {
                            my@ tempArray = split(' ', $littleAddress);
                            @tempArray = reverse(@tempArray);
                            my $bigAddress = join('', @tempArray);
                            push(@classList, $bigAddress);
                      }
                }
}
close(OTOOIMAGE);

foreach my $a (@classList)
{
    printf("address = %s\n", $a);
}

printf("----------------------------------References Classes Address------------------------------------\n");

my $classRefsPipe = $otoolSegmentPipe.SPACE.$dataSegment.SPACE.$classrefsSection.SPACE.$imageFIlePath.$pipe;
my @classRefsList = ();
open(OTOOIMAGE, "$classRefsPipe");
while(<OTOOIMAGE>)
{
        chomp();
        my @address = /.{16}\t(.{24})(.{24})/;
        my $addressCount = $#address;
        if ($addressCount > 0)
        {
            my($firstAddress, $secondAddress) = @address;
            foreach my $littleAddress(@address)
            {
                  my@ tempArray = split(' ', $littleAddress);
                  @tempArray = reverse(@tempArray);
                  my $bigAddress = join('', @tempArray);
                  if ($bigAddress !~ /0{16}/) { #filter illegal address
                                push(@classRefsList, $bigAddress);
                  }
            }
        }
}
close(OTOOIMAGE);

foreach my $a (@classRefsList) {
    printf("address = %s\n", $a);
}

printf("-------------------------------------Unused Classes Address---------------------------------\n");

my %hashClassList = map{$_=>1} @classList;
my %hashClassRefsList = map{$_=>1} @classRefsList;
#difference set
my @unusedClassList = grep {!$hashClassRefsList{$_}} @classList;

foreach my $a (@unusedClassList) {
    printf("address = %s\n", $a);
}

my $objcClassStructInfoPipe = $otoolObjcClassPipe.SPACE.$imageFIlePath.$pipe;
my @allObjcClassesInfo = ();
my @refClassesInfo = ();
my $isStartClassRef = 0;
open(OTOOIMAGE, "$objcClassStructInfoPipe");
while(<OTOOIMAGE>)
{
        chomp();
        my $currentLine = $_;
        # dummy data: 0000000100005328 0x100005d18 _OBJC_CLASS_$_test5
        #my @info = /^0.{15}\s(0x.{9})\s.+\$.(.+)/;

        if ($currentLine eq "Contents of (__DATA,__objc_protolist) section")
            {
                last;
            }

        if ($currentLine eq "Contents of (__DATA,__objc_classrefs) section")
            {
                $isStartClassRef = 1;
                next;
            }

        if ($currentLine =~  /^0.{15}\s0x.{9}\s.+\$.+/)
        {
            my $targetString = substr($currentLine, 17);
            if ($isStartClassRef > 0) {

                push(@refClassesInfo, $targetString);
                next;
            }

            push(@allObjcClassesInfo, $targetString);
        }


}
close(OTOOIMAGE);

printf("----------------------------------All  Classes------------------------------------\n");
foreach my $a (@allObjcClassesInfo) {
    printf("%s\n", $a);
}

printf("----------------------------------Reference Classes------------------------------------\n");

foreach my $a (@refClassesInfo) {
    printf("%s\n", $a);
}

printf("-----------------------------------Unused Classes-----------------------------------\n");

my %allClasses = map{$_=>1} @allObjcClassesInfo;
my %refClasses = map{$_=>1} @refClassesInfo;
#difference set
my @unusedClassesList = grep {!$refClasses{$_}} @allObjcClassesInfo;

foreach my $a (@unusedClassesList) {
    printf("address = %s\n", $a);
}

printf("-----------------------------------All Methods-----------------------------------\n");

my $methodListPipe = $otoolSeletorPipe.SPACE.$textSegment.SPACE.$methodListSection.SPACE.$imageFIlePath.$pipe;

my @methodList = ();
open(OTOOIMAGE, "$methodListPipe");
while(<OTOOIMAGE>)
{
        chomp();
        #dammy data:0000000100004148  callMethod:
        my($address, $symbol) = /(.+)\s{2}(.+)/;
        if( defined $symbol && defined $address)
        {
            push(@methodList, $symbol);
        }
}
close(OTOOIMAGE);

foreach my $a (@methodList) {
    printf("symbol = %s\n", $a);
}

printf("-----------------------------------Reference Methods-----------------------------------\n");

my $methodrefsPipe = $otoolSeletorPipe.SPACE.$dataSegment.SPACE.$selectorrefsSection.SPACE.$imageFIlePath.$pipe;

my @methodrefsList = ();
open(OTOOIMAGE, "$methodrefsPipe");
while(<OTOOIMAGE>)
{
        chomp();
        #dammy data:0000000100005980  __TEXT:__objc_methname:alloc
        my($address, $segment, $section, $symbol) = /(.+)\s{2}..(.{4}).(.{15}).(.+)/;
        if( defined $symbol && defined $address)
        {
            push(@methodrefsList, $symbol);
        }
}
close(OTOOIMAGE);

foreach my $a (@methodrefsList) {
    printf("symbol = %s\n", $a);
}

printf("-----------------------------------Unused Methods-----------------------------------\n");
my %allSelectors = map{$_=>1} @methodList;
my %refSelectors = map{$_=>1} @methodrefsList;
#difference set
my @unusedSelectorList = grep {!$refSelectors{$_}} @methodList;

foreach my $a (@unusedSelectorList) {
    printf("symbol = %s\n", $a);
}
