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
        q[select distinct ask_type from entries order by ask_type]);
}

sub offer_items {
    my $self = shift;
    $self->_sth_stream(
        q[
    select offer_type, count(offer_type) count
    from entries 
    where ask_type = 'essentia' 
    group by offer_type
    having count(offer_type) > 1
    order by offer_type
]
      )->filter(
        sub {
            {
                [ map { $_->[0] } @$_ ]
            }
        }
      );
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

sub top_resources {
    my $self   = shift;
    my $stream = $self->_sth_stream(
        qq{
        SELECT count(offer_type) count, offer_type 
        FROM entries 
        WHERE ask_type = 'essentia' 
        GROUP BY offer_type 
        HAVING COUNT(offer_type) > 1 
        ORDER BY count DESC
        LIMIT 3
    }
    );

    $stream->filter(
        sub {
            [ map { $_->[1] } @$_ ];
        }
    );
}

sub essentia_trades {
    my ( $self, $type ) = @_;
    my $search = { ask_type => 'essentia' };
    if ($type) { $search->{offer_type} = $type }
    my $stream = $self->directory->search($search);
    $stream->filter(
        sub {
            [ grep { $_->offer_quantity } @$_ ];
        }
    );
}

1;
__END__
