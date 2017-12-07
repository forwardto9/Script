#!/usr/local/bin/perl
print "hi perl\n";

format EMPLOYEE =
===================================
@<<<<<<<<<<<<<<<<<<<<<< @<< 
$name, $age
@#####.##
$salary
===================================
.
 
select(STDOUT);
$~ = EMPLOYEE;
 
@n = ("Ali", "Runoob", "Jaffer");
@a  = (20,30, 40);
@s = (2000.00, 2500.00, 4000.000);
%hashMap = (
    "k1" => "V1",
    "k2" => "V2",
    "k3" => "V3",
    "k4" => "V4"
            );
 
$i = 0;
while (($key, $value) =  each(%hashMap)) {
    $name = $key;
    $age = $value;
    write;
    #printf ("%s:%s\n", $key, $value);
}

