#!/usr/local/bin/perl
use diagnostics;
use strict;
use Data::Dumper;


use constant SPACE => " ";


my $imageFIlePath = "/Users/uwei/Library/Developer/Xcode/DerivedData/TestLinkMapWithOC-gmvzvpmjiwrokhdqdtmsmkungdwx/Build/Products/Debug/TestLinkMapWithOC";
my $otoolCommand = "otool -";
my $segmentOption = "s";
my $objcOption = "ov";
my $otoolSegmentPipe = $otoolCommand.$segmentOption;
my $otoolObjcClassPipe = $otoolCommand.$objcOption;
my $pipe = SPACE."|".SPACE;
my $dataSegment = "__DATA";
my $textSegment = "__TEXT";
my $classlistSection = "__objc_classlist";
my $classrefsSection = "__objc_classrefs";
my $classListPipe = $otoolSegmentPipe.SPACE.$dataSegment.SPACE.$classlistSection.SPACE.$imageFIlePath.$pipe;
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

printf("----------------------------------------------------------------------\n");

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

printf("----------------------------------------------------------------------\n");

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

printf("----------------------------------all classes------------------------------------\n");
foreach my $a (@allObjcClassesInfo) {
    printf("%s\n", $a);
}

printf("----------------------------------reference classes------------------------------------\n");

foreach my $a (@refClassesInfo) {
    printf("%s\n", $a);
}

printf("-----------------------------------unused classes-----------------------------------\n");

my %allClasses = map{$_=>1} @allObjcClassesInfo;
my %refClasses = map{$_=>1} @refClassesInfo;
#difference set
my @unusedClassesList = grep {!$refClasses{$_}} @allObjcClassesInfo;

foreach my $a (@unusedClassesList) {
    printf("address = %s\n", $a);
}
