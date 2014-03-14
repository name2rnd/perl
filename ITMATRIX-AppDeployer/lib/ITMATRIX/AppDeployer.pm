package ITMATRIX::AppDeployer;

=pod

=encoding utf8

=head1 NAME

ITMATRIX::AppDeployer

=head1 SYNOPSIS

  my $deploy = ITMATRIX::AppDeployer->new(config_string => $string);
  my $deploy = ITMATRIX::AppDeployer->new(config_file => $path);

  $deploy->run();
  
  # OR
  $deploy->vcs_release();
  $deploy->test();
  
  my $success = $deploy->is_success();
  if (!$success)
  {
    my $result = $deploy->result_as_string();
  }

=head1 DESCRIPTION

Модуль для выкатки приложения. Работает с конфигурацией в формате ITMATRIX::AppDeployer::Config

=head1 METHODS

=cut

use 5.008009;
use strict;
use warnings;
use Carp qw/croak/;
use autouse 'Data::Dumper' => qw(Dumper);
our $VERSION = 0.09;
use base q/ITMATRIX::AppDeployer::Core/;

sub new
{
  my $class = shift;

  my $self = $class->SUPER::new();
  $self->{ _config }      = q();
  $self->{ _vcs_handler } = q();
  bless $self, $class;
  $self->_init(@_);
  return $self;
}

sub _init
{
  my $this = shift;

  $this->{ _config } = $this->create_config_handler(@_);
  return;
}

=pod

=head2 get_config

Возвращает объект конфигурации (см. подробнее ITMATRIX::AppDeployer::Config)

  my $conf = $deploy->get_config

=cut

sub get_config
{
  my $this = shift;
  return $this->{ _config };
}

=pod

=head2 vcs_release

Запускает процесс выкатки из репозитория

  $dep->vcs_release;

=cut

sub vcs_release
{
  my $this    = shift;
  my $vcs     = $this->create_vcs_handler();
  my $actions = $this->get_config->get_vcs_actions();
  if ( scalar @{ $actions } )
  {
    # будем считать, что операция успешна
    $this->status->set_success();
    for my $action ( @{ $actions } )
    {
      $vcs->$action;

      if ( !$vcs->status->is_success() )
      {
        # прерываем выполнение
        $this->status->set_fail( $vcs->status->result_as_string );
        last;
      }
    }
  }
  else
  {
    croak 'No actions found in VCS to release';
  }
  return;
}

=pod

=head2 test

Запускает процесс тестирования по всем указанным тестам

  $dep->test;

=cut

sub test
{
  my $this = shift;

  my $user  = $this->get_config->get_user();
  my $tests = $this->get_config->get_tests_for_run();

  if ( scalar @{ $tests } )
  {
    # будем считать, что операция успешна
    $this->status->set_success();
    for my $test ( @{ $tests } )
    {
      my $test_dir = $this->get_config->get_test_folder($test);
      my $tester = $this->create_test( user => $user, dir => $test_dir );
      $tester->run();
      if ( !$tester->status->is_success() )
      {
        # прерываем выполнение
        $this->status->set_fail( "TEST $test FAILED: " . $tester->status->result_as_string );
        last;
      }
    }
  }
  else
  {
    croak 'No test found in Config';
  }
  return;
}

=pod

=head2 create_vcs_handler

Возвращает объект для управления VCS (например, ITMATRIX::AppDeployer::VCS::Git), в зависимости от того, что задано в конфиге

  mt $vcs = $deploy->create_vcs_handler();

=cut

sub create_vcs_handler
{
  my $this = shift;
  if ( !$this->{ _vcs_handler } )
  {
    my $vcs_name = $this->get_config->get_vcs();
    my $user     = $this->get_config->get_user();
    my $vcs_dir  = $this->get_config->get_vcs_dir();
    if ( $vcs_name && $user && $vcs_dir )
    {
      $vcs_name = ucfirst($vcs_name);

      my $class = "ITMATRIX::AppDeployer::VCS::" . $vcs_name;
      eval "require $class";
      $this->{ _vcs_handler } = eval { $class }->new( user => $user, dir => $vcs_dir );
    }
    else
    {
      croak 'Undefined vcs_name or user or vcs_dir';
    }
  }
  return $this->{ _vcs_handler };
}

sub create_config_handler
{
  my $this = shift;
  my $opt  = { @_ };

  require ITMATRIX::AppDeployer::Config;
  my $config = q();
  if ( $opt->{ config_string } || $opt->{ config_file } )
  {

    if ( $opt->{ config_string } )
    {
      $config = ITMATRIX::AppDeployer::Config->new( string => $opt->{ config_string } );
    }
    elsif ( $opt->{ config_file } )
    {
      $config = ITMATRIX::AppDeployer::Config->new( file => $opt->{ config_file } );
    }
  }
  else
  {
    croak 'Undefined config: no config_string, no config_file';
  }
  return $config;
}

=pod

=head2 create_test

Возвращает объект для работы с тестами (ITMATRIX::AppDeployer::Test)

  mt $tester = $deploy->create_test( user => 'user', dir => '/usr/home/user/data/tests');

=cut

sub create_test
{
  my $this = shift;
  my $opt  = { @_ };

  require ITMATRIX::AppDeployer::Test;
  my $tester = ITMATRIX::AppDeployer::Test->new( user => $opt->{ user }, dir => $opt->{ dir } );
  return $tester;
}

1;

=pod

=head2 CHANGES

  Version 0.09
  Savenkova Natalya, скорректированы тесты

  Version 0.08
  Savenkova Natalya, добавлен метод create_test
  
  Version 0.07
  Savenkova Natalya, ITMATRIX::AppDeployer::Test updated
  
  Version 0.06
  Savenkova Natalya, tests modified
  
  Version 0.05
  Savenkova Natalya, добавлен класс ITMATRIX::AppDeployer::Test для запуска тестов, указанных в конфигурации
  Добавлен класс ITMATRIX::AppDeployer::Status, вся работа с отслеживанием текущего статуса последней выполенной операции перенесена в него.
  Добавлен базовый класс ITMATRIX::AppDeployer::Core, который содержит объект статуса

  Version 0.04
  Savenkova Natalya, добавлены методы vcs_release, create_vcs_handler, is_success, result_as_string
  
  Version 0.03
  Savenkova Natalya, ITMATRIX::AppDeployer::VCS::Git modified

=head1 AUTHOR

Copyright 2012 Savenkova Natalya.

=cut
