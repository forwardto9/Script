#!/usr/local/bin/perl
use diagnostics;
use strict;
use utf8;
use Carp;
use CGI;
use lib ("/Users/uwei/WorkSpace/ScriptProject/Perl");
use Me qw(hello goodbye);
require "People.pl";

printf "ARGV: @ARGV\n";
printf ("argv count is %d\n", $#ARGV + 1);
printf ("Process name is %s\n", $0);
my $argvIndex = 0;
foreach my $argv (@ARGV) {
    $argvIndex++;
    printf ("argv[%d] is %s\n", $argvIndex, $argv);
}

#while(<>) {
#    print "$.\t$_";
#    if (eof){
#    print "-" x 30, "\n"; }
#    close(ARGV);
#}



Me::hello("Perl");

my $pkg = new MyPackage();
$pkg->setPackage("uwei", "29");
$pkg->getPackage;

my $int = 9;
print $int,"\n";
my $string = "uwei";
print $string,"\n";
my @array = qw("123" "456");
foreach my $number (@array) {
    print $number, "\n";
}
#print @array,"\n";
my %map = (
    "key1" => "value1",
    "key2" => "value2"
);
print %map,"\n";
print $map{"key1"}, "\n";

sub function1 {
    my  ($name, $age) = @_;
    my $info = "Your name is:".$name." age is:"."$age";
    print $info, "\n";
    my $isOlder = 0;
    if ($age > 0)  {
        $isOlder = 1;
    } else {
        $isOlder = 0;
    }
    return $isOlder;
    };

my $howold = function1("uwei", 29);
if ($howold != 0) {
    my $info = ($howold > 0) ?  "YES"  :  "NO";
    printf ("this man is %s \n",  $info);
}

my $pointer1 = \%map;
print $pointer1->{"key1"}, "\n";

#反引号用来执行shell命令
print `pwd`, "\n";

printf "please input y to exit:";
while (my $isExist = <STDIN>) {
    chomp($isExist);
    if ($isExist  eq "y") {
        printf "Exit by user!\n";
        last;
    } else {
        printf( "Current input  is %s\n", $isExist);
        printf "please input y to exit:";
    }
    
}

#while (<DATA>) {
#    my @lines = split('\t');
#    printf ("this line count is %-10d\n", $#lines);
#    for (my $i = 0; $i < $#lines; $i++) {
#        print $lines[$i] ;
#    }
#    printf "\n";
#}

while (<DATA>) {
    chomp();
    my ($findex, $name) = /\[\s*(\d{1,})]\s.+\/(.+o$)/;
    if (length($findex) > 0) {
        printf ("index =%s, name =%s\n", $findex, $name);    
    }
    
}

while (<DATA>) {
    chomp();
    #方法一：
    #my($address, $size, $index, $symble) = /(.+\t)(.+\t)(.+]\s)([+|-].+\s.+)/;
    #printf ("address =%s, size =%s, index =%s, symble =%s\n", $address, $size, $index, $symble);
    
    #方法二：
    my($address, $size, $index, $symble) = /(0x.{8})\t(0x.{8})\t\[\s*(\d{1,})]\s([+|-].+\s.+)/;
    printf ("Address is hex\n") if $address =~ /\p{IsXDigit}/;
    printf ("address =%s, size =%s, index =%s, symble =%s\n", $address, $size, $index, $symble);
}

open(MYPIPE, "| wc -w");
print MYPIPE "who uwei zheng";
close(MYPIPE);

open (INPIPE, "pwd |");
my $currentPath = <INPIPE>;
printf ("Current path is %s", $currentPath);
close(INPIPE);



__DATA__
[  1] /Users/uwei/Library/Developer/Xcode/DerivedData/XG-SDK-ggsxhibkpfjpaxaxgokulacxmrjb/Build/Intermediates/XG-SDK.build/Release-iphoneos/XG-SDK.build/Objects-normal/arm64/CocoaJCE.o
[  2] /Users/uwei/Library/Developer/Xcode/DerivedData/XG-SDK-ggsxhibkpfjpaxaxgokulacxmrjb/Build/Intermediates/XG-SDK.build/Release-iphoneos/XG-SDK.build/Objects-normal/arm64/JceEnumHelper.o
[  3] /Users/uwei/Library/Developer/Xcode/DerivedData/XG-SDK-ggsxhibkpfjpaxaxgokulacxmrjb/Build/Intermediates/XG-SDK.build/Release-iphoneos/XG-SDK.build/Objects-normal/arm64/JceInputStream.o
[  4] /Users/uwei/Library/Developer/Xcode/DerivedData/XG-SDK-ggsxhibkpfjpaxaxgokulacxmrjb/Build/Intermediates/XG-SDK.build/Release-iphoneos/XG-SDK.build/Objects-normal/arm64/JceObject.o
[  5] /Users/uwei/Library/Developer/Xcode/DerivedData/XG-SDK-ggsxhibkpfjpaxaxgokulacxmrjb/Build/Intermediates/XG-SDK.build/Release-iphoneos/XG-SDK.build/Objects-normal/arm64/JceObjectV2.o
[  6] /Users/uwei/Library/Developer/Xcode/DerivedData/XG-SDK-ggsxhibkpfjpaxaxgokulacxmrjb/Build/Intermediates/XG-SDK.build/Release-iphoneos/XG-SDK.build/Objects-normal/arm64/JceOutputStream.o
[  7] /Users/uwei/Library/Developer/Xcode/DerivedData/XG-SDK-ggsxhibkpfjpaxaxgokulacxmrjb/Build/Intermediates/XG-SDK.build/Release-iphoneos/XG-SDK.build/Objects-normal/arm64/JceStream.o
[  8] /Users/uwei/Library/Developer/Xcode/DerivedData/XG-SDK-ggsxhibkpfjpaxaxgokulacxmrjb/Build/Intermediates/XG-SDK.build/Release-iphoneos/XG-SDK.build/Objects-normal/arm64/XGBaseModel.o
[  9] /Users/uwei/Library/Developer/Xcode/DerivedData/XG-SDK-ggsxhibkpfjpaxaxgokulacxmrjb/Build/Intermediates/XG-SDK.build/Release-iphoneos/XG-SDK.build/Objects-normal/arm64/XGTpnsPushClickRsp.o
[ 10] /Users/uwei/Library/Developer/Xcode/DerivedData/XG-SDK-ggsxhibkpfjpaxaxgokulacxmrjb/Build/Intermediates/XG-SDK.build/Release-iphoneos/XG-SDK.build/Objects-normal/arm64/XGSqlite.o
0x00005D98	0x00000008	[  2] +[MXGJceEnumHelper etos:]
0x00005DA0	0x00000008	[  2] +[MXGJceEnumHelper stoe:]
0x00005DA8	0x00000094	[  2] +[MXGJceEnumHelper eto_s:]
0x00005E3C	0x0000008C	[  2] +[MXGJceEnumHelper _stoe:]
0x00005EC8	0x000000A8	[  3] +[MXGJceInputStream streamWithData:]
0x00005F70	0x00000058	[  3] -[MXGJceInputStream init]
0x00005FC8	0x00000038	[  3] -[MXGJceInputStream data]