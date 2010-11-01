package Pidgeon::KiokuDB;
use Moose;
use namespace::autoclean;

use SQL::Abstract;
use KiokuDB::TypeMap::Entry::Set;

extends qw(KiokuX::Model);

with qw(Pidgeon::Data::API);

has columns => (
    isa        => 'ArrayRef',
    is         => 'ro',
    lazy_build => 1,
);

sub _build_columns {
    [

    ];
}

around _build__connect_args => sub {
    my $next = shift;
    my $self = shift;
    my $args = $self->$next(@_);
    push @$args, columns => $self->columns;
    return $args;
};

1;

__END__
