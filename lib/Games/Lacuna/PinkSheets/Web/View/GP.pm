package Games::Lacuna::PinkSheets::Web::View::GP;

use strict;
use base 'Catalyst::View::Graphics::Primitive';

__PACKAGE__->config(
    driver       => 'Cairo',
    driver_args  => { format => 'png' },
    content_type => 'image/png',
);

