package MyPackage;
sub new {
	my $class = shift;
	my $property = {
	  "name" => undef,
	  "age" => undef,
	  "array" => undef
	};
  return bless($property, $class);
}

sub setPackage {
  my $self = shift;
  my ($name, $age, $arr) = @_;
  $self->{"name"} = $name;
  $self->{"age"} = $age;
  $self->{"array"} = $arr;
};

sub getPackage {
	my $self = shift;
   while (my($key, $value) = each(%$self)) {
		if(ref($value) eq "ARRAY") {
			printf "result $key:";
			my @v = @{$value};
			#$#v得到的是数组最后一个索引，不是数组的大小
			my $count = @v;
			for (my $i = 0; $i < $count; $i++) {
				printf("value[%d] = %s ", $i, $$value[$i]);
			}
			printf ("\n");
		} else {
			printf "result $key:$value\n";
		}
   }
}
1;
