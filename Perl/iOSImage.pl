#!/usr/local/bin/perl
use diagnostics;
use strict;
use constant SPACE => " ";
my $imageFIlePath = "";
my $otoolPipe = "otool -s";
my $dataSegment = "__DATA";
my $textSegment = "__TEXT";
my $classlistSection = "__objc_classlist";
my $classrefsSection = "__objc_classrefs";
my $classListPipe = $otoolPipe.SPACE.$dataSegment.SPACE.$classlistSection.$imageFIlePath;
my @classList = ();
open(OTOOIMAGE, $classListPipe);
while(<OTOOIMAGE>) {
    chomp();
    s/\s+//;
    my ($firstAddress, $secondAddress) = /.+\s(([A-F|0-9]){8})(([A-F|0-9]){8})/;
    # delete whitespace
    $firstAddress =~ s/\s+//g;
    $secondAddress =~ s/\s+//g;
    # reverse
    reverse($firstAddress);
    reverse($secondAddress);
    # push into array
    push(@classList, $firstAddress);
    push(@classList, $secondAddress);
}