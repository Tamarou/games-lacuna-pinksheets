package Games::Lacuna::PinkSheets::Model::Trade;
our $VERSION = '0.01';
use Moose;
use namespace::autoclean;

use MooseX::Types::DateTime qw(DateTime);
use DateTime::Format::Strptime;

with qw(
  KiokuDB::Role::ID
);

sub kiokudb_object_id { shift->id }

has id => ( isa => 'Str', is => 'ro', required => 1 );
has body => ( isa => 'HashRef', is => 'ro' );

has empire => (
    isa     => 'HashRef',
    traits  => ['Hash'],
    is      => 'ro',
    handles => {
        'empire_id'   => [ 'get', 'id' ],
        'empire_name' => [ 'get', 'name' ],
    },
);

has ask_quantity      => ( isa => 'Str', is => 'ro', required => 1 );
has ask_description   => ( isa => 'Str', is => 'ro', required => 1 );
has ask_type          => ( isa => 'Str', is => 'ro', required => 1 );
has date_offered      => ( isa => 'Str', is => 'ro', required => 1 );
has offer_quantity    => ( isa => 'Str', is => 'ro', required => 1 );
has offer_description => ( isa => 'Str', is => 'ro', required => 1 );
has offer_type        => ( isa => 'Str', is => 'ro', required => 1 );
has building          => ( isa => 'Str', is => 'ro', required => 1 );

sub date_offered_as_datetime {
    my $self = shift;
    DateTime::Format::Strptime->new(
        pattern => '%d %m %Y %H:%M:%S %z',

    )->parse_datetime( $self->date_offered );
}

has date_recorded => (
    isa     => DateTime,
    is      => 'ro',
    default => sub { DateTime::->now }
);

has last_seen => (
    isa     => DateTime,
    is      => 'rw',
    default => sub { DateTime::->now }
);

1;
__END__
