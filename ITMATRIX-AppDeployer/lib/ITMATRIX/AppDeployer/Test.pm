package ITMATRIX::AppDeployer::Test;

=pod

=encoding utf8

=head1 NAME

ITMATRIX::AppDeployer::Test

=head1 SYNOPSIS

  my $object = ITMATRIX::AppDeployer::Test->new();
  

=head1 DESCRIPTION

Модуль для запуска тестов.
Тесты должны находится в одной директории и иметь такую структуру

/module_tests
--Makefile.PL
--/t
----my_test1.t
----my_test2.t

В конфиге прописывается список директорий, из которых будут запущены тесты. Подробнее смотреть ITMATRIX::AppDeployer::Config

В Makefile.PL по сути можно написать что-то в этом роде:

	use ExtUtils::MakeMaker;
	WriteMakefile( NAME => 'App::foo');

Запуск тестов этим модулем заключается в выполнении:

	perl Makefile.PL;
	make test;
	make clean;

=head1 METHODS

=cut

use 5.008009;
use strict;
use warnings;

use Carp qw/croak/;

use base q/ITMATRIX::AppDeployer::Core/;

our $VERSION = 0.02;

=pod

=head2 new

  my $object = ITMATRIX::AppDeployer::Test->new(dir => '/usr/home/vzv/data/module_tests');

=cut

sub new
{
  my $class = shift;
  my $self  = $class->SUPER::new(@_);

  if ( !$self->{ user } )
  {
    croak 'Undefined user for tests';
  }
  if ( !$self->{ dir } )
  {
    croak 'Undefined dir with tests';
  }
  if ( !( -d $self->{ dir } ) )
  {
    croak 'Directory does not exist';
  }
  bless $self, $class;
  return $self;
}

sub run
{
  my $this = shift;
  my $command = "su - ".$this->{ user }." -c 'cd ".$this->{ dir }." && perl Makefile.PL && make test && make clean'";
  my @result = `$command`;
  my @success_msg = ('All tests successful');

  # по умолчанию считаем, что неудачно
  $this->status->set_fail();

  for my $line (@result)
  {
    for my $msg (@success_msg)
    {
      if ( $line =~ m/$msg/ )
      {
        $this->status->set_success();
        last;
      }
    }
    if ( $this->status->is_success )
    {
      last;
    }
  }
  # если неудачно, тогда уже устанавливаем ошибку
  if ( !$this->status->is_success )
  {
    my $str = join( q(), @result );
    $this->status->set_fail($str);
  }

  return;
}

1;

=pod

=head1 CHANGES

	Version 0.02
	Savenkova Natalya, запуск тестов теперь проводится от имени заданного пользователя

=head1 AUTHOR

Copyright 2013 Savenkova Natalya.

=cut
