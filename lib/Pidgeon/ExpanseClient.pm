package Pidgeon::ExpanseClient;
our $VERSION = '0.01';
use Moose;
use namespace::autoclean;
use Games::Lacuna::Client;
use MooseX::Types::Path::Class qw(File);

has config => (
    isa      => File,
    is       => 'ro',
    required => 1,
    coerce   => 1,
);

has debug => (
    isa     => 'Bool',
    is      => 'ro',
    default => 0,
);

has client => (
    isa        => 'Games::Lacuna::Client',
    is         => 'ro',
    lazy_build => 1,
);

sub _build_client {
    my $self = shift;
    Games::Lacuna::Client->new(
        cfg_file => $self->config->stringify,
        debug    => $self->debug,
    );
}

has empire => (
    is         => 'ro',
    lazy_build => 1,
);

sub _build_empire {
    my ($self) = @_;
    $self->client->empire;
}

has empire_data => (
    isa        => 'HashRef',
    is         => 'ro',
    lazy_build => 1
);

sub _build_empire_data {
    my $self = shift;
    $self->empire->view_species_stats();
}

has planets => (
    is         => 'ro',
    isa        => 'HashRef',
    traits     => ['Hash'],
    lazy_build => 1,
    handles    => { 'planet_ids' => ['keys'], }
);

sub _build_planets {
    my ($self) = @_;
    $self->empire_data->{status}->{empire}->{planets};
}

sub get_buildings_for {
    my ( $self, $pid ) = @_;
    $self->client->body( id => $pid )->get_buildings()->{buildings};
}

has trade_ministries => (
    isa        => 'HashRef',
    traits     => ['Hash'],
    lazy_build => 1,
    handles    => { trade_ministries => ['kv'], },
);

sub _build_trade_ministries {
    my $self = shift;
    my @tm;
    for my $pid ( $self->planet_ids ) {
        my $buildings = $self->get_buildings_for($pid);
        push @tm, grep { $buildings->{$_}->{url} eq '/trade' } keys %$buildings;
    }
    return { map { $_ => $self->client->building( id => $_, type => 'Trade' ) }
          @tm };
}

1;
__END__
