use strict;
use lib qw(lib);
use Games::Lacuna::PinkSheets::Web;

Games::Lacuna::PinkSheets::Web->setup_engine('PSGI');
my $app = sub { Games::Lacuna::PinkSheets::Web->run(@_) };
