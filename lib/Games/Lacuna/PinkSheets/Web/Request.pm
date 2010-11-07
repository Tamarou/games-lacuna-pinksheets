package Games::Lacuna::PinkSheets::Web::Request;
use Moose;
use namespace::autoclean;

BEGIN { extends qw(Catalyst::Request::REST::ForBrowsers) }

around data => sub {
    my $next = shift;
    my $self = shift;
    return $self->$next(@_) || $self->params;
};

1;
__END__
