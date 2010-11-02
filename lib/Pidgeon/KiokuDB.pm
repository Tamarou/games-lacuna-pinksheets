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

        ask_quantity => {
            data_type   => "varchar",
            is_nullable => 1,
            extract     => sub {
                my $obj = shift;
                return $obj->ask_quantity
                  if $obj->can('ask_quantity');
            },
        },
        ask_type => {
            data_type   => "varchar",
            is_nullable => 1,
            extract     => sub {
                my $obj = shift;
                return $obj->ask_type
                  if $obj->can('ask_type');
            },
        },
        offer_quantity => {
            data_type   => "varchar",
            is_nullable => 1,
            extract     => sub {
                my $obj = shift;
                return $obj->offer_quantity
                  if $obj->can('offer_quantity');
            },
        },
        offer_type => {
            data_type   => "varchar",
            is_nullable => 1,
            extract     => sub {
                my $obj = shift;
                return $obj->offer_type
                  if $obj->can('offer_type') && $obj->offer_type;
            },
        },
        empire_id => {
            data_type   => "varchar",
            is_nullable => 1,
            extract     => sub {
                my $obj = shift;
                return $obj->empire_id
                  if $obj->can('empire_id') && $obj->empire_id;
            },
        },
        empire_name => {
            data_type   => "varchar",
            is_nullable => 1,
            extract     => sub {
                my $obj = shift;
                return $obj->empire_name
                  if $obj->can('empire_name') && $obj->empire_name;
            },
        },
        date_offered => {
            data_type   => "varchar",
            is_nullable => 1,
            extract     => sub {
                my $obj = shift;
                return $obj->date_offered_as_datetime
                  if $obj->can('date_offered_as_datetime')
                      && $obj->date_offered_as_datetime;
            },
        },
        last_seen => {
            data_type   => "varchar",
            is_nullable => 1,
            extract     => sub {
                my $obj = shift;
                return $obj->last_seen
                  if $obj->can('last_seen')
                      && $obj->last_seen;
            },
        },
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
