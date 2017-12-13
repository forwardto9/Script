package Object;
sub new {
  my $class = shift;
  my $property =  {
    "name" => undef,
    "index" => undef,
    "symbols" => undef #only scalar
    };
  
  return bless($property, $class);
};

sub setProperty($$@) {
    my $self = shift;
    #array ref is a scalar
    my ($name, $index, $symbols) = @_;
    $self->{"name"} = $name;
    $self->{"index"} = $index;
    $self->{"symbols"} = $symbols;
}

sub getName {
    my $self = shift;
    return $self->{"name"};
}

sub getIndex {
    my $self = shift;
    return $self->{"index"};
}

sub getSymbols {
    my $self = shift;
    #get pointer to array(ref)
    return $self->{"symbols"};
}

1;