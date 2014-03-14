# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl ITMATRIX-Mutex.t'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';
use Time::HiRes qw(gettimeofday tv_interval);

use Test::More tests => 14;
BEGIN { use_ok('ITMATRIX::Mutex') };

my $mut = 'ITMATRIX::Mutex'->new();

is (ref($mut), 'ITMATRIX::Mutex', 'object created');

$mut = 'ITMATRIX::Mutex'->new({livetime => 180});
is ($mut->get_livetime(), 180, 'livetime is 180 seconds');
is ($mut->get_wait_timeout(), 1, 'wait_timeout is 1 seconds');

$mut = 'ITMATRIX::Mutex'->new({wait_timeout => 120});
is ($mut->get_livetime(), 10, 'livetime is 10 seconds');
is ($mut->get_wait_timeout(), 120, 'wait_timeout is 120 seconds');

my $start = [gettimeofday];	
$mut->wait(2);
$time = tv_interval($start);
is (int($time), 2, 'sleep during 2 seconds');

$mut->set_wait_timeout(5);
$start = [gettimeofday];	
$mut->wait();
$time = tv_interval($start);

is (int($time), 5, 'sleep during 5 seconds');

is($mut->get_prolong_counter(), 0, 'prolong counter = 0');

$mut->_increase_prolong_counter();
is($mut->get_prolong_counter(), 1, 'prolong counter = 1');

is($mut->_is_prolongation_accepted(), 1, 'prolong accepted');
$mut->_increase_prolong_counter();
$mut->_increase_prolong_counter();
$mut->_increase_prolong_counter();
is($mut->get_prolong_counter(), 4, 'prolong counter = 4');
is($mut->_is_prolongation_accepted(), 0, 'prolong not accepted');

$mut->_reset_prolong_counter();
is($mut->get_prolong_counter(), 0, 'prolong counter = 0');


#########################

# Insert your test code below, the Test::More module is use()ed here so read
# its man page ( perldoc Test::More ) for help writing this test script.