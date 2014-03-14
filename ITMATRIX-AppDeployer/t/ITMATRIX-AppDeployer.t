use strict;
use warnings;

use Test::More;
BEGIN { use_ok('ITMATRIX::AppDeployer') }

my $config = '
run test

user devtest
use_vcs git
use_tests module

<vcs git>
	dir /usr/home/devtest/data
	action pull
</vcs>
';

my $dep = ITMATRIX::AppDeployer->new( config_string => $config );
is( ref $dep,                   'ITMATRIX::AppDeployer',         'created OK' );
is( ref $dep->get_config,       'ITMATRIX::AppDeployer::Config', 'config OK' );
is( $dep->get_config->get_user, 'devtest',                       'config read OK' );

my $vcs_handler = $dep->create_vcs_handler('git');
is( ref $vcs_handler, 'ITMATRIX::AppDeployer::VCS::Git', 'create vcs handler OK' );

my $status_object = $dep->status();
is( ref $status_object, 'ITMATRIX::AppDeployer::Status', 'status object OK' );

my $config_handler = $dep->create_config_handler( config_string => $config );
is( ref $config_handler, 'ITMATRIX::AppDeployer::Config', 'create config handler OK' );

$dep->vcs_release();
is( !$dep->status->is_success, 1, 'fail OK' );


my $config_path = 't/deploy.conf';
$dep = ITMATRIX::AppDeployer->new( config_file => $config_path );
is( ref $dep,                   'ITMATRIX::AppDeployer',         'created OK' );
is( ref $dep->get_config,       'ITMATRIX::AppDeployer::Config', 'config OK' );
is( $dep->get_config->get_user, 'devtest',                       'config read OK' );

my $tester = $dep->create_test( user => 'devtest', dir => '/usr/home/devtest/data' );
is( ref $tester, 'ITMATRIX::AppDeployer::Test', 'created test OK' );

$dep->test();

eval { my $dep = ITMATRIX::AppDeployer->new(); };
is( $@ =~ m/Undefined config/, 1, 'error ok' );

done_testing;
