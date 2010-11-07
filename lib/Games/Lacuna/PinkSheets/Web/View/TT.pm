package Games::Lacuna::PinkSheets::Web::View::TT;
use Moose;
BEGIN { extends 'Catalyst::View::TT' }

__PACKAGE__->config(
    {
        CATALYST_VAR => 'c',
        INCLUDE_PATH => [
            Games::Lacuna::PinkSheets::Web->path_to( 'root', 'src' ),
            Games::Lacuna::PinkSheets::Web->path_to( 'root', 'lib' )
        ],
        TEMPLATE_EXTENSION => '.tt2',
        ERROR              => 'error.tt2',
        TIMER              => 0,
        PLUGIN_BASE        => ['Games::Lacuna::PinkSheets::Template::Plugin']
    }
);

1;
