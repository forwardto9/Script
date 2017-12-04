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

printf ("\@INC is @INC \n");

foreach my $key (keys(%ENV)){
printf "$key\n";
}
printf "Your login name is $ENV{'LOGNAME'}\n";

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
0x00006480	0x000001A8	[  3] -[MXGJceInputStream readFloat:]
0x0000C44C	0x00000084	[ 11] -[MXGSetting init]
0x0000C4D0	0x00000048	[ 11] +[MXGSetting getInstance]
0x0000C518	0x0000003C	[ 11] -[MXGSetting enableDebug:]
0x0000C554	0x0000002C	[ 11] -[MXGSetting isEnableDebug]
0x0000C580	0x00000078	[ 11] -[MXGSetting changeToDebugServer]
0x00006480	0x000001A8	[  3] -[MXGJceInputStream readFloat:]
0x00006628	0x00000194	[  3] -[MXGJceInputStream readDouble:]
0x000067BC	0x00000054	[  3] -[MXGJceInputStream readFloat]
0x00006810	0x00000060	[  3] -[MXGJceInputStream readDouble]
0x00006870	0x00000150	[  3] -[MXGJceInputStream readBytes:]
0x000069C0	0x00000038	[  3] -[MXGJceInputStream skip:]
0x000069F8	0x00000040	[  3] -[MXGJceInputStream readDataWithSize:]
0x00006A38	0x0000032C	[  3] -[MXGJceInputStream readNumber:required:]
0x00006D64	0x0000024C	[  3] -[MXGJceInputStream readString:required:]
0x00006FB0	0x00000230	[  3] -[MXGJceInputStream readData:required:]
0x000071E0	0x0000049C	[  3] -[MXGJceInputStream readObject:required:description:]
0x0000767C	0x00000204	[  3] -[MXGJceInputStream readArray:required:description:]
0x00007880	0x00000254	[  3] -[MXGJceInputStream readDictionary:required:description:]
0x00007AD4	0x00000278	[  3] -[MXGJceInputStream readAnything:required:description:]
0x00007D4C	0x00000010	[  3] -[MXGJceInputStream headType]
0x00007D5C	0x00000010	[  3] -[MXGJceInputStream setHeadType:]
0x00007D6C	0x00000010	[  3] -[MXGJceInputStream headTag]
0x00007D7C	0x00000010	[  3] -[MXGJceInputStream dataHolders]
0x00007D8C	0x0000001C	[  3] -[MXGJceInputStream setDataHolders:]
0x00007DA8	0x000001A4	[  4] +[MXGJceObject jcePropertiesWithEncodedTypes]