package Pidgeon::Model::Price;
our $VERSION = '0.01';
use Moose;
use namespace::autoclean;

use MooseX::Types::DateTime qw(DateTime);

has timestamp => (
    isa     => DateTime,
    is      => 'ro',
    default => { DateTime->now },
);

has commodity => (
    isa      => 'Str',
    is       => 'ro',
    required => 1,
);

has price => (
    isa      => 'Num',
    is       => 'ro',
    required => 1,
);

1;
__END__
