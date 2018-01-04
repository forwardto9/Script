#!/usr/local/bin/perl
use diagnostics;
use strict;
use Data::Dumper;


use constant SPACE => " ";

my $CPU_TYPE_ARM = "12";
my $CPU_SUBTYPE_ARM_V7 = "9";
my $CPU_SUBTYPE_ARM_V7S = "11";
my $CPU_TYPE_ARM64 = "16777228";
my $CPU_TYPE_X86_64 = "16777223";
my $CPU_ARM64 = "arm64";
sub isProperty($@);


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
my $headOption = "h";
my $headPipe = $otoolCommand.SPACE.$optionChar.$headOption;
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


my $machOHeadPipe = $headPipe.SPACE.$imageFIlePath.$pipe;

my $hasX86Arch = 0;
my $hasARM64Arch = 0;
open(HEAD, $machOHeadPipe) or die "Can not open mach-o file, $!";

while(<HEAD>)
{
     chomp();
     my $headLine = $_;
     if ($headLine =~ /$CPU_TYPE_ARM64/) {
      $hasARM64Arch = 1;
      last;
     }
     
     if ($headLine =~ /$CPU_TYPE_X86_64/) {
      $hasX86Arch = 1;
      last;
     }
 
}
close(HEAD);

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

foreach my $item (@classList)
{
    printf("address = %s\n", $item);
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

foreach my $item (@classRefsList) {
    printf("address = %s\n", $item);
}

printf("-------------------------------------Unused Classes Address---------------------------------\n");

my %hashClassList = map{$_=>1} @classList;
my %hashClassRefsList = map{$_=>1} @classRefsList;
#difference set
my @unusedClassList = grep {!$hashClassRefsList{$_}} @classList;

foreach my $item (@unusedClassList) {
    printf("address = %s\n", $item);
}

my $objcClassStructInfoPipe = $otoolObjcClassPipe.SPACE.$imageFIlePath.$pipe;
my @allObjcClassesInfo = ();
my @refClassesInfo = ();
my $isStartClassRef = 0;
open(OTOOIMAGE, "$objcClassStructInfoPipe");
#为了防止非arm64的架构符号，现在又不需要了？
my $iOSFatFlag = 0;
while(<OTOOIMAGE>)
{
        chomp();
        my $currentLine = $_;
        # dummy data: 0000000100005328 0x100005d18 _OBJC_CLASS_$_test5
        #my @info = /^0.{15}\s(0x.{9})\s.+\$.(.+)/;
        if($hasARM64Arch == 1)
        {
             # if($iOSFatFlag == 0)
             # {
             #      if ($currentLine =~ /$CPU_ARM64/)
             #     {
             #          $iOSFatFlag = 1;
             #     }
             #     next;
             #}
        }
        
        
        if ($currentLine eq "Contents of (__DATA,__objc_protolist) section")
            {
                last;
            }

        if ($currentLine eq "Contents of (__DATA,__objc_classrefs) section")
            {
                $isStartClassRef = 1;
                next;
            }
            #00000001000080a0 0x100009008 _OBJC_CLASS_$_TestClass
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
foreach my $item (@allObjcClassesInfo) {
    printf("%s\n", $item);
}

printf("----------------------------------Reference Classes------------------------------------\n");

foreach my $item (@refClassesInfo) {
    printf("%s\n", $item);
}

printf("-----------------------------------Unused Classes-----------------------------------\n");

my %allClasses = map{$_=>1} @allObjcClassesInfo;
my %refClasses = map{$_=>1} @refClassesInfo;
#difference set
my @unusedClassesList = grep {!$refClasses{$_}} @allObjcClassesInfo;

foreach my $item (@unusedClassesList) {
    printf("address = %s\n", $item);
}

printf("-----------------------------------All Methods-----------------------------------\n");

my $methodListPipe = $otoolSeletorPipe.SPACE.$textSegment.SPACE.$methodListSection.SPACE.$imageFIlePath.$pipe;

my @methodList = ();
my @methodAddressList = ();
open(OTOOIMAGE, "$methodListPipe");
while(<OTOOIMAGE>)
{
        chomp();
        #dammy data:0000000100004148  callMethod:
        my($address, $symbol) = /(.+)\s{2}(.+)/;
        if( defined $symbol && defined $address)
        {
            push(@methodList, $symbol);
            push(@methodAddressList, $address);
        }
}
close(OTOOIMAGE);

foreach my $item (@methodList) {
    printf("symbol = %s\n", $item);
}

foreach my $item (@methodAddressList) {
    #printf("address = %s\n", $item);
}



printf("-----------------------------------Reference Methods-----------------------------------\n");

my $methodrefsPipe = $otoolSeletorPipe.SPACE.$dataSegment.SPACE.$selectorrefsSection.SPACE.$imageFIlePath.$pipe;

my @methodrefsList = ();
my @methodrefsAddressList = ();
open(OTOOIMAGE, "$methodrefsPipe");
while(<OTOOIMAGE>)
{
        chomp();
        #dammy data:0000000100005980  __TEXT:__objc_methname:alloc
        my($address, $segment, $section, $symbol) = /(.+)\s{2}..(.{4}).(.{15}).(.+)/;
        if( defined $symbol && defined $address)
        {
         if (! isProperty($symbol, @methodList)) {
          push(@methodrefsList, $symbol);
            push(@methodrefsAddressList, $address);
         }
        }
}
close(OTOOIMAGE);

foreach my $item (@methodrefsList) {
    printf("symbol = %s\n", $item);
}

foreach my $item (@methodrefsAddressList) {
    #printf("address = %s\n", $item);
}

printf("-----------------------------------Unused Methods-----------------------------------\n");
my %allSelectors = map{$_=>1} @methodList;
my %refSelectors = map{$_=>1} @methodrefsList;
#difference set
my @unusedSelectorListWithProperty = grep {!$refSelectors{$_}} @methodList;
my @unusedSelectorList = ();
foreach my $item (@unusedSelectorListWithProperty) {
    if (! isProperty ($item, @unusedSelectorListWithProperty)) {
     push (@unusedSelectorList, $item);
    }
}

foreach my $item (@unusedSelectorList) {
    printf("symbol = %s\n", $item);
}


my %allSelectorsAddress = map{$_=>1} @methodAddressList;
my %refSelectorsAddress = map{$_=>1} @methodrefsAddressList;
#difference set
my @unusedSelectorAddressList = grep {!$refSelectorsAddress{$_}} @methodAddressList;
foreach my $item (@unusedSelectorAddressList) {
    #printf("address = %s\n", $item);
}


printf("-----------------------------------Property-----------------------------------\n");
my @propertyList = ();

foreach my $item (@unusedSelectorListWithProperty)
{
    if  ($item =~ /^_/)
    {
         my $propertyName = substr($item, 1);
         my $propertyGetter = $propertyName;
         my $firstC = substr($propertyName, 0,1);
         my $restC = substr($propertyName, 1);
         my $propertySetter = "set".uc($firstC).$restC.":";
         #if ($propertyGetter ~~ @methodList) {
         # printf ("find getter\n");
         #}
         my $findGetter = 0;
         my $findSetter = 0;
         if(grep { $propertyGetter eq $_ } @methodList )
         {
          $findGetter = 1;
         }
         if(grep { $propertySetter eq $_ } @methodList )
         {
          $findSetter = 1;
         }
         
         if ($findGetter && $findSetter) {
          push(@propertyList, $propertyName);
         }
     
    }
}


foreach my $item (@propertyList) {
    printf("unused  property = %s\n", $item);
}


open(SYMBOL, "symbol.txt") or die "linkmap symbol file not exist!, $!";
while (<SYMBOL>) {
 chomp();
 my ($symbolAddress,  $symbolSize, $symbolObjectFile,$symbolName) = /(0x.{8,})\s(.+)\s(.+)\s([+|-].+\s.+)/
 
}
close (SYMBOL);

sub isProperty($@) {
 my ($item, @list) = @_;
 if  ($item =~ /^_/)
    {
         my $propertyName = substr($item, 1);
         my $propertyGetter = $propertyName;
         my $firstC = substr($propertyName, 0,1);
         my $restC = substr($propertyName, 1);
         my $propertySetter = "set".uc($firstC).$restC.":";
         #if ($propertyGetter ~~ @methodList) {
         # printf ("find getter\n");
         #}
         my $findGetter = 0;
         my $findSetter = 0;
         if(grep { $propertyGetter eq $_ } @list )
         {
          $findGetter = 1;
         }
         if(grep { $propertySetter eq $_ } @list )
         {
          $findSetter = 1;
         }
         
         return $findGetter && $findSetter;
     
    }
    else
    {
     return 0;
    }
}


