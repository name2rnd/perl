use strict;
use warnings;

use Test::More;
BEGIN { use_ok('ITMATRIX::AppDeployer::VCS::Git') };
BEGIN { use_ok('Git::Repository') };

eval
{
	my $dep = ITMATRIX::AppDeployer::VCS::Git->new();
};
is($@ =~ m/Undefined user or dir/, 1, 'croak OK');

# ==================================================================
# здесь должна быть ошибка, так как репозитория нет в указанном месте
my $dir = '/usr/home/foo';
my $dep = ITMATRIX::AppDeployer::VCS::Git->new(user => 'foo', dir => $dir);
is($dep->status->is_success, 0, 'fail OK');
is($dep->status->result_as_string =~ m/directory not found/, 1, 'fail OK');

done_testing;