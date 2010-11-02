package Pidgeon::Cmd::Command::query_expanse;
use 5.12.0;
use Moose;
our $VERSION = '0.01';
use namespace::autoclean;

use XML::Toolkit::Loader;
use MooseX::Types::Path::Class qw(File);
use Pidgeon::KiokuDB;
use Pidgeon::ExpanseClient;

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
    handles    => [ 'new_scope', 'store' ]
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
    handles    => ['trade_ministries'],
);

sub _build__le_client {
    my $self = shift;
    Pidgeon::ExpanseClient->new( config => $self->le_config, );
}

use aliased 'Pidgeon::Model::Trade';

sub execute {
    my ( $self, $opt, $args ) = @_;
    my $scope = $self->new_scope;
    for ( $self->trade_ministries ) {
        my ( $id, $tm ) = @$_;
        my $data = $tm->view_available_trades( building => $id );
        my $count = $data->{trades} - scalar @{ $data->{trades} };
        $self->store( map { Trade->new($_) } @{ $data->{trades} } );
        while ( $count > 0 ) {
            state $page = 2;
            my $data = $tm->view_available_trades(
                building    => $id,
                page_number => $page++,
            );
            $count -= scalar @{ $data->{trades} };
        }
    }
}

1;
__END__
