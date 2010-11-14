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
    my $k = $c->model('Kioku');
    $self->status_ok(
        $c,
        entity => {
            ask_items     => $k->ask_items,
            offer_items   => $k->offer_items,
            top_resources => [ $k->top_resources->all ],
        }
    );
}

sub ask : Path('/ask') ActionClass('REST') {
}

sub ask_GET {
    my ( $self, $c, $type ) = @_;
    my $k = $c->model('Kioku');
    $self->status_ok(
        $c,
        entity => {
            ask_items   => $k->ask_items,
            offer_items => $k->offer_items,
            type        => $type,
        }
    );
}

sub offer : Path('/offer') ActionClass('REST') {
}

sub offer_GET {
    my ( $self, $c, $type ) = @_;
    my $k = $c->model('Kioku');
    $self->status_ok(
        $c,
        entity => {
            ask_items   => $k->ask_items,
            offer_items => $k->offer_items,
            type        => $type,
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
