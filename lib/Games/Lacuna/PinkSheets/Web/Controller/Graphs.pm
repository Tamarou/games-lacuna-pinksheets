package Games::Lacuna::PinkSheets::Web::Controller::Graphs;
use Moose;
BEGIN { extends qw(Catalyst::Controller); }

use Chart::Clicker;
use Chart::Clicker::Context;
use Chart::Clicker::Data::DataSet;
use Chart::Clicker::Data::Marker;
use Chart::Clicker::Data::Series;
use Chart::Clicker::Renderer::Point;
use Chart::Clicker::Axis::DateTime;

sub index : Path('/graph/essentia') {
    my ( $self, $c ) = @_;
    my $data  = $c->request->data;
    my @types = split ',', $data->{types};
    my $cc    = Chart::Clicker->new( width => 800, height => 240 );
    for my $type (@types) {
        my @trades =
          sort { $a->date_offered_as_datetime <=> $b->date_offered_as_datetime }
          grep { $_->offer_type eq $type }
          $c->model('Kioku')->essentia_trades->all;

        my @dates =
          map { $_->date_offered_as_datetime->epoch } @trades;

        my @values = map { $_->offer_quantity / $_->ask_quantity } @trades;

        my $series = Chart::Clicker::Data::Series->new(
            name   => $type,
            keys   => \@dates,
            values => \@values,
        );

        my $ds = Chart::Clicker::Data::DataSet->new( series => [$series] );
        $cc->add_to_datasets($ds);
    }

    $cc->legend->visible(1);

    #    $cc->padding(0);

    my $defctx = $cc->get_context('default');

    my $dtaxis = Chart::Clicker::Axis::DateTime->new(
        format      => '%m/%d',
        position    => 'bottom',
        orientation => 'horizontal'
    );
    $defctx->domain_axis($dtaxis);

    $defctx->range_axis->fudge_amount(.1);
    $defctx->renderer->shape(
        Geometry::Primitive::Circle->new( { radius => 3, } ) );

    $defctx->range_axis->label('Essentia');
    $defctx->domain_axis->label('Date');

    $c->stash->{graphics_primitive} = $cc;
}

sub end : Private {
    my ( $self, $c ) = @_;
    return if $c->res->body;    # already have a response
    $c->forward('Games::Lacuna::PinkSheets::Web::View::GP');
}

1;
__END__
