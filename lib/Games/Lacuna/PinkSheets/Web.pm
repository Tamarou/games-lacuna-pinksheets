package Games::Lacuna::PinkSheets::Web;
our $VERSION = '0.01';

use Catalyst qw(
    
  ConfigLoader
  Static::Simple
  Unicode::Encoding

  Authentication
  Authorization::Roles

  Session
  Session::Store::FastMmap
  Session::State::Cookie
);

use Games::Lacuna::PinkSheets::Web::Request;

use Catalyst::Log::Log4perl;

__PACKAGE__->config(
    name                   => 'Games::Lacuna::PinkSheets::Web',
    'Plugin::ConfigLoader' => { file => 'conf/catalyst.yml' },

    # 'Plugin::Authentication' => {
    #     default_realm => 'user',
    #     use_session   => 1,
    #     user          => {
    #         credential => {
    #             class         => 'Password',
    #             password_type => 'self_check'
    #         },
    #         store => {
    #             class      => 'Model::KiokuDB',
    #             model_name => 'Kioku',
    #         }
    #     }
    # },
);

__PACKAGE__->request_class('Games::Lacuna::PinkSheets::Web::Request');
__PACKAGE__->log( Catalyst::Log::Log4perl->new('conf/catalyst_logging.conf') );

__PACKAGE__->setup();
1;
__END__

