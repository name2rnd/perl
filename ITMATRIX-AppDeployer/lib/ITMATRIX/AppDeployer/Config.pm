package ITMATRIX::AppDeployer::Config;

=pod

=encoding utf8

=head1 NAME

ITMATRIX::AppDeployer::Config

=head1 DESCRIPTION

Класс для работы с файлом конфигурации системы деплоя.
Конфиг-файл представляет собой файл в формате Config::ApacheFormat 
Содержит инструкции для запуска деплоя:

Пример содержания файла:

	run release test

	user foo
	use_vcs foo
	use_tests foo1 foo2

	<vcs foo>
		action pull
		on_fail break report
	</vcs>
	
	<test foo>
		folder /foo
		on_fail rollback report
	</test>
	<test foo2>
		folder /foo2
		on_fail report
	</test>

Описание:

run release test - release и test это действия, которые нужно выполнить. Можно указывать что-то одно.

user foo - foo это имя пользователя на сервере, которого будем выкатывать
use_vcs foo - foo это название системы контроля версий (например, git), которая используется. Для нее должен быть определен блок <vcs foo> c описанием, чего делать 
use_tests foo[ foo2 ...] - foo и foo2 это наборы тестов, которые нужно запустить после релиза. Для каждого из них нужен блок с описанием

<vcs foo>
	action - указание действия, которое нужно сделать для релиза из системы контроля версий
	on_fail - перечень действий, которые нужно предпринять в случае неудачи
</vcs>

<test foo>
	folder /path - путь, где лежат тесты
	on_fail - список перечень действий, которые нужно предпринять в случае неудачи
</test>

Действия:

break - вообще прервать деплой
report - вернуть отчет
rollback - откатиться на предыдущую стабильную версию

=head1 METHODS

=cut

use 5.008009;
use strict;
use warnings;
use Carp qw/croak/;
our $VERSION = 0.03;

=pod

=head2 new

Создание объекта. Работает как со строкой, так и с полным путем к файлу.

	my $cnf = ITMATRIX::AppDeployer::Config->new(string => $config);
	my $cnf = ITMATRIX::AppDeployer::Config->new(file => $file);

=cut

sub new
{
  my $class = shift;
  my $self  = {};
  bless $self, $class;
  # признак, что после окончания работы файл нужно удалить
  $self->{ _need_remove_file } = 0;
  # конфиг уже был разобран и загружен
  $self->{ _parsed_conf } = 0;
  $self->_init(@_);
  return $self;
}

sub _init
{
  my $this = shift;
  my $opt  = { @_ };
  if ( !$opt->{ file } && !$opt->{ string } )
  {
    croak 'Undefined config: no file, no string';
  }
  my $file = $opt->{ file } ? $opt->{ file } : q();
  if ( $opt->{ string } )
  {
    $file = $this->_make_tmp_file( $opt->{ string } );
    $this->{ _need_remove_file } = 1;
  }
  $this->{ _file } = $file;
  return;
}

sub _make_tmp_file
{
  my $this    = shift;
  my $content = shift;
  require ITMATRIX::File;
  my $temp = 'ITMATRIX::File'->new();
  my $path = $temp->write_temp( content => $content, not_delete => 1 );
  return $path;
}

sub _cnf
{
  my $this = shift;
  if ( !$this->{ _parsed_conf } )
  {
    require Config::ApacheFormat;
    $this->{ _parsed_conf } = Config::ApacheFormat->new();
    $this->{ _parsed_conf }->read( $this->{ _file } );
  }
  return $this->{ _parsed_conf };

}

=pod

=head2 get_actions_for_run

Возвращает ссылку на массив, где перечислены действия, которые надо выполнить для деплоя (для 'run release test' вернет ['release', 'test']

	my $actions = $cnf->get_actions_for_run();

=cut

sub get_actions_for_run
{
  my $this    = shift;
  my @actions = $this->_cnf->get('run');
  return scalar @actions ? \@actions : [];
}

=pod

=head2 get_tests_for_run

Возвращает ссылку на массив со списком наборов тестов, которые нужно запустить  (для 'use_tests module performance' вернет ['module', 'performance'])

	my $tests = $cnf->get_tests_for_run();

=cut

sub get_tests_for_run
{
  my $this  = shift;
  my @tests = $this->_cnf->get('use_tests');
  return scalar @tests ? \@tests : [];
}

=pod

=head2 get_user

Возвращает имя пользователя, которого деплоим (для 'user devtest' вернет devtest)

	my $user = $cnf->get_user();

=cut

sub get_user
{
  my $this = shift;
  my $user = $this->_cnf()->get('user');
  return $user ? $user : q();
}

=pod

=head2 get_vcs

Возвращает имя системы контроля версий, которую нужно использовать (для 'use_vcs git' вернет git)

	my $vcs = $cnf->get_vcs();

=cut

sub get_vcs
{
  my $this = shift;
  my $vcs  = $this->_cnf()->get('use_vcs');
  return $vcs ? $vcs : q();
}

=pod

=head2 get_vcs_actions

Возвращает массив действий, которые нужно выполнить в системе контроля версий, чтобы слить из нее последнюю версию.
Для блока 

	<vcs git>
		action pull
		on_fail break report
	</vcs>

вернет ['pull'] (из action pull)
Система контроля версий определяется автоматически с помощью метода get_vcs и из директивы 'use_vcs git'

	my $vcs_actions = $cnf->get_vcs_actions();

=cut

sub get_vcs_actions
{
  my $this  = shift;
  my $vcs   = $this->get_vcs();
  my $block = $this->_get_block( type => 'vcs', name => $vcs );

  my @actions = $block->get("action");
  return scalar @actions ? \@actions : [];
}

=pod

=head2 get_vcs_dir

Возвращает рабочую директорию, где находится наш проект, под контролем гита
Для блока 

	<vcs git>
		dir /usr/home/devtest/data
	</vcs>

вернет '/usr/home/devtest/data'
Система контроля версий определяется автоматически с помощью метода get_vcs и из директивы 'use_vcs git'

	my $vcs_dir = $cnf->get_vcs_dir();

=cut

sub get_vcs_dir
{
  my $this  = shift;
  my $vcs   = $this->get_vcs();
  my $block = $this->_get_block( type => 'vcs', name => $vcs );

  my $dir = $block->get("dir");
  return $dir ? $dir : q();
}

=pod

=head2 get_actions_on_fail_vcs

Возвращает список действий, которые нужно выполнить, если загрузка последней версии не удалась
Для блока 

	<vcs git>
		action pull
		on_fail break report
	</vcs>

вернет ['break', 'report'] (из on_fail break report)
Система контроля версий определяется автоматически с помощью метода get_vcs и из директивы 'use_vcs git'

	my $vcs_action_on_fail = $cnf->get_actions_on_fail_vcs();

=cut

sub get_actions_on_fail_vcs
{
  my $this    = shift;
  my $vcs     = $this->get_vcs();
  my $block   = $this->_get_block( type => 'vcs', name => $vcs );
  my @on_fail = $block->get("on_fail");
  return scalar @on_fail ? \@on_fail : [];
}

=pod

=head2 get_actions_on_fail_test

Возвращает список действий, которые нужно выполнить, если заданный тест не прошел
Для блока 

	<test foo>
		folder /foo
		on_fail rollback report
	</test>

вернет ['rollback', 'report'] (из on_fail rollback report)

	my $test_action_on_fail = $cnf->get_actions_on_fail_test('foo');

=cut

sub get_actions_on_fail_test
{
  my $this = shift;
  my $name = shift;
  if ($name)
  {
    my $block = $this->_get_block( type => 'test', name => $name );
    my @on_fail = $block->get("on_fail");
    return scalar @on_fail ? \@on_fail : [];
  }
  else
  {
    croak 'Undefined test name';
  }
  return;
}

=pod

=head2 get_test_folder

Возвращает папку, где лежит заданный набор тестов (каким образом написать эти тесты, расскажу где-нибудь в другом месте)

Для блока

	<test foo>
		folder /foo
		on_fail rollback report
	</test>

Вернет '/foo'

	my $folder = $cnf->get_test_folder('foo');

=cut

sub get_test_folder
{
  my $this = shift;
  my $name = shift;
  if ($name)
  {
    my $block = $this->_get_block( type => 'test', name => $name );
    my $folder = $block->get("folder");
    return $folder ? $folder : q();
  }
  else
  {
    croak 'Undefined test name';
  }
  return;
}

sub _get_block
{
  my $this = shift;
  my $opt  = { @_ };
  my $type = $opt->{ type };
  my $name = $opt->{ name };
  if ( $type && $name )
  {
    my $block = $this->_cnf->block( $type => $name );
    return $block;
  }
  else
  {
    croak 'undefined block reciever options: no type or no name';
  }
  return;
}

sub DESTROY
{
  my $this = shift;

  if ( $this->{ _need_remove_file } )
  {
    require ITMATRIX::File;
    'ITMATRIX::File'->delete( filepath => $this->{ _file } );
  }
  return;
}
1;

=pod

=head2 CHANGES

	Version 0.03
	Savenkova Natalya, добавлена функция get_vcs_dir

	Version 0.02
	Savenkova Natalya, добавлен pod к new

=head1 AUTHOR

Copyright 2012 Savenkova Natalya.

=cut
