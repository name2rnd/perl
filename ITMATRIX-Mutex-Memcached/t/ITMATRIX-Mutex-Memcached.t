use Test::More tests => 20;

# ==================================================================
sub set_waited_success
{
  my $_data = shift @_;
  $_data->{ waited_success } = 1;
  return;
}

# ==================================================================
sub set_waited_failed
{
  my $_data = shift @_;
  $_data->{ waited_failed } = 1;
  return;
}

# ==================================================================
sub set_prolong_failed
{
  my $_data = shift @_;
  $_data->{ prolong_failed } = 1;
  return;
}

BEGIN { use_ok('ITMATRIX::Mutex::Memcached') }

my $devtest_path = '/usr/home/devtest/data/www';    # настройки приложения
require $devtest_path.'/admin.devtest.itmatrix.ru/cgi-bin/io_lib/io_app.pl';

# ==================================================================
my $mut = 'ITMATRIX::Mutex::Memcached'->new();

is( ref($mut), 'ITMATRIX::Mutex::Memcached', 'object created' );

$mut = 'ITMATRIX::Mutex::Memcached'->new( { livetime => 180 } );
is( $mut->get_livetime(),     180, 'livetime is 180 seconds' );
is( $mut->get_wait_timeout(), 1,   'wait_timeout is 1 seconds' );

$mut = 'ITMATRIX::Mutex::Memcached'->new( { livetime => 8, key => 'debug_lock' } );
is( $mut->get_key(),            'debug_lock',   'key = debug_lock' );
is( ref( $mut->get_handler() ), 'io_memcached', 'handler ok' );

$mut->lock();
is( $mut->is_locked(), 1, 'is locked' );

$mut->unlock();
is( $mut->is_locked(), 0, 'is not locked' );

# auto unlock
$mut->lock();
for ( 1 .. 5 )
{
  $mut->wait(1);
  print $mut->is_locked() ? 'locked' : 'unlocked';
  print "\n";
}

$mut->unlock();
is( $mut->is_locked(), 0, 'is not locked' );

# prolongation
$mut->lock();
is( $mut->is_locked(),                 1, 'is locked' );
is( $mut->_is_prolongation_accepted(), 1, 'prolong accepted' );
is( $mut->get_prolong_counter(),       0, 'get_prolong_counter = 1' );
for ( 1 .. 3 )
{
  # print "\n";
  $mut->prolong();
  # print "\n";
  $mut->get_prolong_counter();
}

$mut->unlock();
is( $mut->is_locked(), 0, 'is not locked' );

# ==================================================================
my $data = {};
# тестируем ожидание - время жизни ключа меньше, чем время ожидания
$mut->init( { key => 'debug_lock', livetime => 2 } );
is( $mut->get_livetime(), 2, 'livetime is 2 sec' );
$mut->lock();    # предполагается, что заблокировал ключ другой процесс

is( $mut->is_locked(), 1, 'is locked' );
if ( $mut->is_locked() )
{
  $mut->wait_unlock(
    { 'callback_wait_success' => sub { set_waited_success($data) },
      'callback_wait_failed'  => sub { set_waited_failed($data) }
    } );
}
$mut->unlock();

is( $data->{ waited_success }, 1 );
is( $data->{ waited_failed },  undef );

# # тестируем ожидание - время жизни ключа больше, чем время ожидания (так по умолчанию)
$mut->init( { key => 'debug_lock', livetime => 10 } );
$mut->lock();    # предполагается, что заблокировал ключ другой процесс
$data = {};
if ( $mut->is_locked() )
{
  $mut->wait_unlock(
    { 'callback_wait_success' => sub { set_waited_success($data) },
      'callback_wait_failed'  => sub { set_waited_failed($data) }
    } );
}
$mut->unlock();

is( $data->{ waited_success }, undef );
is( $data->{ waited_failed },  1 );

# prolong
$mut->lock();
for ( 1 .. 3 )
{
  sleep(1);
  $mut->prolong(
    {
      callback_prolong_refused => sub {
        $mut->unlock();
        die 'cant prolong '.$_;
        }
    } );
}

$mut->prolong(
  { callback_prolong_failed => sub { set_prolong_failed($data) }
  } );
is( $data->{ prolong_failed }, 1 );
$mut->unlock();
