package Games::Lacuna::PinkSheets::Web::Controller::Root;
use Moose;
BEGIN { extends 'Catalyst::Controller::REST' }

#
# Sets the actions in this controller to be registered with no prefix
# so they function identically to actions created in MyApp.pm
#
__PACKAGE__->config(
    default => 'text/html',
    map     => {
        'text/html' => [ 'View', 'TT' ],
        'text/xml'  => undef
    },
    namespace => '',
);

sub index : Path('/') ActionClass('REST') {
}

sub index_GET {
    my ( $self, $c ) = @_;
    my $ask_items =
      $c->model('Kioku')->directory->backend->schema->storage->dbh_do(
        sub {
            my ( $storage, $dbh ) = @_;
            my $ref = $dbh->selectall_arrayref(
                'select distinct ask_type from entries order by ask_type');
            return [ map { @$_ } @$ref ];
        }
      );

    my $offer_items =
      $c->model('Kioku')->directory->backend->schema->storage->dbh_do(
        sub {
            my ( $storage, $dbh ) = @_;
            my $ref = $dbh->selectall_arrayref(
                'select distinct offer_type from entries order by offer_type');
            return [ map { @$_ } @$ref ];
        }
      );

    my $recent = $c->model('Kioku')->all_objects;
    $self->status_ok(
        $c,
        entity => {
            ask_items   => $ask_items,
            offer_items => $offer_items,
            recent      => $recent
        }
    );
}

sub default {
    my ( $self, $c ) = @_;
    $c->response->body('Page not found');
    $c->response->status(404);

}

sub auto : Private {
    my ( $self, $c, @args ) = @_;

    # if ( my $sid = $c->req->params->{SID} ) {
    #     if ( my $session_data = $c->get_session_data("session:$sid") ) {
    #         if ( my $user_data = $session_data->{__user} ) {
    #             delete $c->req->params->{SID};
    #             $c->authenticate(
    #                 {
    #                     username => $user_data->{email},
    #                     password => $user_data->{password}
    #                 }
    #             );
    #         }
    #     }
    # }

    return 1;
}
1;
__END__
