package Pidgeon::Cmd::Command::query_expanse;
use 5.12.0;
use Moose;
our $VERSION = '0.01';
use namespace::autoclean;

use XML::Toolkit::Loader;
use MooseX::Types::Path::Class qw(File);
use Pidgeon::KiokuDB;
use Pidgeon::ExpanseClient;

use DateTime;
use Try::Tiny;

extends qw(MooseX::App::Cmd::Command);

with qw(
  Pidgeon::Cmd::Common
);

sub usage_desc { "query_expanse %o " }

has dsn => (
    isa           => "Str",
    is            => "ro",
    required      => 1,
    documentation => 'KiokuDB DSN',
);

has le_config => (
    isa           => 'Str',
    is            => 'ro',
    required      => 1,
    documentation => 'Lacuna Expanse Client Config',
);

has _namespace => (
    isa     => 'Str',
    reader  => 'namespace',
    default => 'Pidgeon::Model::XML',
);

has _dir => (
    isa        => 'Pidgeon::KiokuDB',
    reader     => 'dir',
    lazy_build => 1,
    handles    => [ 'new_scope', 'store', 'lookup', 'txn_do' ]
);

sub _build__dir {
    Pidgeon::KiokuDB->new(
        dsn        => shift->dsn,
        extra_args => { create => 1 }
    );
}

has _le_client => (
    isa        => 'Pidgeon::ExpanseClient',
    lazy_build => 1,
    handles    => [ 'session_id', 'trade_ministries' ],
);

sub _build__le_client {
    my $self = shift;
    Pidgeon::ExpanseClient->new(
        config => $self->le_config,
        debug  => $self->verbose,
    );
}

use aliased 'Pidgeon::Model::Trade';

sub save_trades {
    my ( $self, $trades ) = @_;
    for my $trade (@$trades) {
        my $obj = $self->lookup( $trade->{id} ) || Trade->new($trade);
        $obj->last_seen( DateTime->now );
        $self->txn_do( sub { $self->store($obj); } );
    }
}

sub execute {
    my ( $self, $opt, $args ) = @_;
    my $scope = $self->new_scope;
    for ( $self->trade_ministries ) {
        my ( $id, $building ) = @$_;
        warn "working on building $id" if $self->verbose;
        my $data = $building->view_available_trades();
        $self->save_trades( $data->{trades} );

        my $count = $data->{trade_count} - scalar @{ $data->{trades} };
        while ( $count > 0 ) {
            state $page = 2;
            warn "Checking page $page" if $self->verbose;
            my $data = $building->view_available_trades( $page++ );
            last unless scalar @{ $data->{trades} };
            $self->save_trades( $data->{trades} );
            $count -= scalar @{ $data->{trades} };
            warn $count if $self->verbose;
        }
    }
}

1;
__END__
