use Test::More;
BEGIN { use_ok('ITMATRIX::AppDeployer::Config') };
BEGIN { use_ok('Config::ApacheFormat') };
BEGIN { use_ok('ITMATRIX::File 0.026') };

use strict;
use warnings;

my $config = '
run release test

user devtest
use_vcs git
use_tests module performance

<vcs git>
	dir /usr/home/devtest/data
	action pull
	on_fail break report
</vcs>
<vcs svn>
	dir /usr/home/devtest/data
	action checkout
	on_fail break report
</vcs>
<test module>
	folder /module_tests
	on_fail rollback report
</test>
<test performance>
	folder /performance_tests
	on_fail report
</test>';

# Здесь должна быть ошибка, так как не задан конфиг
eval
{
	my $cnf = ITMATRIX::AppDeployer::Config->new();
};
if ($@)
{
	is($@ =~ m/Undefined config/, 1, 'croak OK');
}

# Проверяем деструктор
my $tmp_file = q();
eval
{
	my $cnf = ITMATRIX::AppDeployer::Config->new(string => $config);
	is(ref $cnf, 'ITMATRIX::AppDeployer::Config', 'created OK');
	is($cnf->{ _file } =~ m/temp_/, 1, 'config from string OK');
	$tmp_file = $cnf->{ _file };
	is($cnf->{ _need_remove_file }, 1, 'need remove OK');
};
 is($tmp_file =~ m/temp_/, 1, 'config OK');
 is(! -e $tmp_file, 1, 'file not exists');


# загрузка из файла
my $file = '/t/deploy.conf';
my $cnf = ITMATRIX::AppDeployer::Config->new(file => $file);
is(ref $cnf, 'ITMATRIX::AppDeployer::Config', 'created OK');
is($cnf->{ _file }, '/t/deploy.conf', 'config from file OK');

# тестирование методов

$cnf = ITMATRIX::AppDeployer::Config->new(string => $config);
is($cnf->{ _file } =~ m/temp_/, 1, 'config from string OK');
is(-e $cnf->{ _file }, 1, 'config from string OK');

my $actions = $cnf->get_actions_for_run();
is(scalar @$actions, 2, 'actions list OK');
is($actions->[0], 'release', 'actions 1 OK');
is($actions->[1], 'test', 'actions 2 OK');

is($cnf->get_user(), 'devtest', 'user OK');
is($cnf->get_vcs(), 'git', 'vcs OK');

my $tests = $cnf->get_tests_for_run();
is(scalar @$tests, 2, 'tests list OK');
is($tests->[0], 'module', 'test 1 OK');
is($tests->[1], 'performance', 'test 2 OK');

is($cnf->get_vcs_dir, '/usr/home/devtest/data', 'dir OK');
my $vcs_actions = $cnf->get_vcs_actions();
is(scalar @$vcs_actions, 1, 'vcs actions OK');
is($vcs_actions->[0], 'pull', 'actions OK');

my $vcs_action_on_fail = $cnf->get_actions_on_fail_vcs();
is(scalar @$vcs_action_on_fail, 2, 'vcs actions on fail OK');
is($vcs_action_on_fail->[0], 'break', 'vcs actions on fail OK');
is($vcs_action_on_fail->[1], 'report', 'vcs actions on fail OK');

my $test = 'module';
my $folder = $cnf->get_test_folder($test);
is($folder, '/module_tests', 'test folder OK');

my $test_action_on_fail = $cnf->get_actions_on_fail_test($test);
is(scalar @$test_action_on_fail, 2, 'test actions on fail OK');
is($test_action_on_fail->[0], 'rollback', 'test actions on fail OK');
is($test_action_on_fail->[1], 'report', 'test actions on fail OK');

$test = 'performance';
$folder = $cnf->get_test_folder($test);
is($folder, '/performance_tests', 'test folder OK');

$test_action_on_fail = $cnf->get_actions_on_fail_test($test);
is(scalar @$test_action_on_fail, 1, 'test actions on fail OK');
is($test_action_on_fail->[0], 'report', 'test actions on fail OK');

sleep(1);

# конфиг, где только по одному элементу, а не список
$config = '
run test

user devtest
use_vcs git
use_tests module';

# тестирование методов
my $cnf2 = ITMATRIX::AppDeployer::Config->new(string => $config);
is($cnf2->{ _file } =~ m/temp_/, 1, 'config from string OK');
is(-e $cnf2->{ _file }, 1, 'config from string OK');

$actions = $cnf2->get_actions_for_run();
is(scalar @$actions, 1, 'actions list OK');
is($actions->[0], 'test', 'actions 2 OK');

is($cnf2->get_user(), 'devtest', 'user OK');
is($cnf2->get_vcs(), 'git', 'vcs OK');

$tests = $cnf2->get_tests_for_run();
is(scalar @$tests, 1, 'tests list OK');
is($tests->[0], 'module', 'test 1 OK');

done_testing;