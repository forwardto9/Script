package Me;
use strict;
use warnings;

our @ISA=qw(Exporter);
our @EXPORT_OK=qw(hello goodbye);

sub hello {
    my $name = shift;
    printf "Hi $name\n";
}

sub goodbye {
    my $name = shift;
    printf "goodbye $name\n";
}

sub doNothing {
    printf "Do nothing\n";
}

1;