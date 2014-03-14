use strict;
use warnings;

use Test::More;
BEGIN { use_ok('ITMATRIX::AppDeployer::Core') }

my $core = ITMATRIX::AppDeployer::Core->new();
is( ref $core, 'ITMATRIX::AppDeployer::Core', 'created OK' );
is( ref $core->status, 'ITMATRIX::AppDeployer::Status', 'created status OK' );

done_testing;