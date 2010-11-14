package Games::Lacuna::PinkSheets::Web::Controller::Graphs;
use 5.10.0;
use Moose;

BEGIN { extends qw(Catalyst::Controller); }

use Chart::Clicker;
use Chart::Clicker::Context;
use Chart::Clicker::Data::DataSet;
use Chart::Clicker::Data::Marker;
use Chart::Clicker::Data::Series;
use Chart::Clicker::Renderer::Area;
use Chart::Clicker::Axis::DateTime;

sub trade_per_essentia {
    my ( $self, $trade ) = @_;
    given ( $trade->ask_type ) {
        when ('essentia') {
            return $trade->offer_quantity / $trade->ask_quantity
        };
        default { return 0 }
    };
}

sub index : Path('/graph/essentia') {
    my ( $self, $c ) = @_;
    my $data = $c->request->data;
    my @types = split ',', $data->{types};

    my $cc = Chart::Clicker->new(
        width  => ( $data->{width}  // 640 ),
        height => ( $data->{height} // 300 )
    );

    for my $type (@types) {
        my @trades =
          sort { $a->date_offered_as_datetime <=> $b->date_offered_as_datetime }
          $c->model('Kioku')->essentia_trades($type)->all;

        my @dates =
          map { $_->date_offered_as_datetime->epoch } @trades;

        my @values = map { $self->trade_per_essentia($_) } @trades;

        my $series = Chart::Clicker::Data::Series->new(
            name   => $type,
            keys   => \@dates,
            values => \@values,
        );

        my $ds = Chart::Clicker::Data::DataSet->new( series => [$series] );
        $cc->add_to_datasets($ds);
    }

    my $defctx = $cc->get_context('default');
    my $dtaxis = Chart::Clicker::Axis::DateTime->new(
        label            => 'Date',
        format           => '%m/%d',
        position         => 'bottom',
        orientation      => 'vertical',
        tick_label_angle => .7853981625,
    );
    my $area = Chart::Clicker::Renderer::Area->new( fade => 1, opacity => .6 );
    $area->brush->width(2);
    $defctx->renderer($area);
    $defctx->domain_axis($dtaxis);

    $cc->legend->visible(1);
    $cc->legend->border->width(0);
    $cc->border->width(0);

    $cc->title->text('Quantity per Essentia');

    $c->stash->{graphics_primitive} = $cc;
}

sub end : Private {
    my ( $self, $c ) = @_;
    return if $c->res->body;    # already have a response
    $c->forward('Games::Lacuna::PinkSheets::Web::View::GP');
}

1;
__END__
