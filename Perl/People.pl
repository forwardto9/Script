package MyPackage;
sub new {
    my $class = shift;
    my $property = {
      "name" => undef,
      "age" => undef
    };
  return bless($property, $class);
}

sub setPackage {
  my $self = shift;
  my ($name, $age) = @_;
  $self->{"name"} = $name;
  $self->{"age"} = $age;
};

sub getPackage {
    $self = shift;
   while (($key, $value) = each(%$self)) {
    printf "result $key:$value\n";
   }
}
1;