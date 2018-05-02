#!/usr/local/bin/perl
print "hi perl\n";


my $name, my $age, my $salary;

format myformat =
===================================
@<<<<<<<<<<<<<<<<<<<<<< @<<
$name, $age
@#####.##
$salary
===================================
.

select(STDOUT);
$~ = "myformat";

my @n = ("Ali", "Runoob", "Jaffer");
my @a  = (20,30, 40);
my @s = (2000.00, 2500.00, 4000.000);
my %hashMap = (
    "k1" => "V1",
    "k2" => "V2",
    "k3" => "V3",
    "k4" => "V4"
            );

my $i = 0;
while (my ($key, $value) =  each(%hashMap)) {
    $name = $key;
    $age = $value;
    write;
    #printf ("%s:%s\n", $key, $value);
}

my $testString = "hi Atom";
printf($testString);
printf($testString);
