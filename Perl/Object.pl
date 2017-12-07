package Object;
sub new {
  my $class = shift;
  my $property =  {
    "name" => undef,
    "index" => undef,
    "symbols" => undef
    };
  bless($property, $class);
  return $property;
};

sub setProperty($$@) {
    my $self = shift;
    my ($name, $index, @symbols) = @_;
    $self->{"name"} = $name;
    $self->{"index"} = $index;
    $self->{"symbols"} = @symbols;
}

sub getName {
    my $self = shift;
    return $self ->{"name"};
}

sub getIndex {
    my $self = shift;
    return $self ->{"index"};
}

sub getSymbols {
    my $self = shift;
    return $self ->{"symbols"};
}

1;