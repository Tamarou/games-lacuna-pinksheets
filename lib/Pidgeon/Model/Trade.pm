package Pidgeon::Model::Trade;
our $VERSION = '0.01';
use Moose;
use namespace::autoclean;

use MooseX::Types::DateTime qw(DateTime);

with qw(
  KiokuDB::Role::ID
  KiokuDB::Role::Immutable
);

sub kiokudb_object_id { shift->id }

has id                => ( isa => 'Str',     is => 'ro' );
has empire            => ( isa => 'HashRef', is => 'ro' );
has ask_quantity      => ( isa => 'Str',     is => 'ro' );
has offer_description => ( isa => 'Str',     is => 'ro' );
has offer_type        => ( isa => 'Str',     is => 'ro' );
has body              => ( isa => 'HashRef', is => 'ro' );
has ask_description   => ( isa => 'Str',     is => 'ro' );
has ask_type          => ( isa => 'Str',     is => 'ro' );
has date_offered      => ( isa => 'Str',     is => 'ro' );
has offer_quantity    => ( isa => 'Str',     is => 'ro' );

1;
__END__
