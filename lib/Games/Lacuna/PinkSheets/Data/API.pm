package Games::Lacuna::PinkSheets::Data::API;
use Moose::Role;
our $VERSION = '0.01';
use namespace::autoclean;
use Data::Stream::Bulk::Util qw(bulk);
with qw(
  KiokuDB::Role::API
);

sub get_object_by_id {
    my ( $self, $id ) = @_;
    my $wtf = $self->directory->search( { id => $id } );
    my @list = $wtf->all;
    confess "couldn't find object for $id" unless scalar @list;

    return @list if wantarray;
    return shift @list;
}

sub store_objects {
    my ( $self, @objs ) = @_;
    return $self->directory->txn_do( sub { $self->directory->store(@objs) } );
}

sub ask_items {
    my $self = shift;
    $self->_sth_stream(
        'select distinct ask_type from entries order by ask_type');
}

sub offer_items {
    my $self = shift;
    $self->_sth_stream(
        'select distinct offer_type from entries order by offer_type');
}

sub _sth_stream {
    my ( $self, $sql, @bind ) = @_;

    $self->directory->backend->schema->storage->dbh_do(
        sub {
            my ( $storage, $dbh ) = @_;
            my $sth = $dbh->prepare_cached( $sql, {}, 3 );
            $sth->execute(@bind);
            Data::Stream::Bulk::DBI->new( sth => $sth );
        }
    );
}

sub recent_items {
    my $self   = shift;
    my $schema = $self->directory->backend->schema;
    my @entries =
      $schema->resultset('entries')
      ->search_rs( {}, { order_by => { -desc => 'date_offered' } } )
      ->get_column('id')->all;

    my $stream = bulk(@entries);
    $stream->filter(
        sub {
            [ map { $self->directory->lookup($_) } @$_ ];
        }
    );
}

sub essentia_values {
    my $self = shift;
    my $rs   = $self->directory->backend->schema->resultset('entries');

}

1;
__END__
