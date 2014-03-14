use strict;
use warnings;

use Test::More;
BEGIN { use_ok('ITMATRIX::AppDeployer::Test') }

eval { my $test = ITMATRIX::AppDeployer::Test->new(); };
is( $@ =~ m/Undefined user/, 1, 'fail OK' );

eval { my $test = ITMATRIX::AppDeployer::Test->new( user => 'devtest' ); };
is( $@ =~ m/Undefined dir/, 1, 'fail OK' );

eval { my $test = ITMATRIX::AppDeployer::Test->new( user => 'devtest', dir => 't/TEST' ); };
is( $@ =~ m/Directory does not exist/, 1, 'fail dir OK' );

# my $test = q();

# my $path = `pwd`;
# $path =~ s/[\n\r\t]//g;

# $test = ITMATRIX::AppDeployer::Test->new( user => 'devtest', dir => $path.'/t/TEST_failed' );
# is( ref $test, 'ITMATRIX::AppDeployer::Test', 'created OK' );
# is( ref $test->can('run'), 'CODE', 'method OK' );
# $test->run();
# is( !$test->status->is_success, 1, 'failed OK' );
# is( $test->status->result_as_string =~ m/Failed/, 1, 'failed OK' );

# $test = ITMATRIX::AppDeployer::Test->new( user => 'devtest', dir => $path.'/t/TEST_success' );
# $test->run();
# is( $test->status->is_success,       1,   'success OK' );
# is( $test->status->result_as_string, q(), 'success OK' );

done_testing;
