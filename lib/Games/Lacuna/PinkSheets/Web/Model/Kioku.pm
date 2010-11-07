package Games::Lacuna::PinkSheets::Web::Model::Kioku;
use Moose;
use Games::Lacuna::PinkSheets::KiokuDB;
BEGIN { extends qw(Catalyst::Model::KiokuDB) }

has '+model' => ( handles => 'Games::Lacuna::PinkSheets::Data::API', );

has '+model_class' => ( default => 'Games::Lacuna::PinkSheets::KiokuDB' );

1;
__END__
