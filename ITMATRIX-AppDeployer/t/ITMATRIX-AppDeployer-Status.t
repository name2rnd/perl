use strict;
use warnings;

use Test::More;
BEGIN { use_ok('ITMATRIX::AppDeployer::Status') }

my $status = ITMATRIX::AppDeployer::Status->new();
is( ref $status, 'ITMATRIX::AppDeployer::Status', 'created OK' );

is( !$status->is_success, 1, 'fail OK' );

$status->set_success('ok');
is( $status->is_success, 1, 'success OK' );
is($status->result_as_string, 'ok', 'status OK');

$status->set_fail('error');
is(! $status->is_success, 1, 'fail OK' );
is($status->result_as_string, 'error', 'error OK');

$status->set_success('ok2');
is( $status->is_success, 1, 'success 2 OK' );
is($status->result_as_string, 'ok2', 'status 2 OK');

done_testing;
