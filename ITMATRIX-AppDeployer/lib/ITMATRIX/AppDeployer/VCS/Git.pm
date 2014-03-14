package ITMATRIX::AppDeployer::VCS::Git;

=pod

=encoding utf8

=head1 NAME

ITMATRIX::AppDeployer::VCS::Git

=head1 DESCRIPTION

Класс для работы с гитом при выкатке релиза

=head1 METHODS

=cut

use 5.008009;
use strict;
use warnings;
use Carp qw/croak/;

use base q/ITMATRIX::AppDeployer::Core/;

our $VERSION = 0.04;

=pod

=head2 new

Создание объекта. Работает как со строкой, так и с полным путем к файлу.

	my $git = ITMATRIX::AppDeployer::VCS::Git->new(user => $name, dir => '/usr/home/foo/data');
	user - имя пользователя, которого будем выкатывать
	dir - его директория, которая находится под гитом
	чтобы он работал, у пользователя должен быть ssh-ключ для гитлаба, то есть, если вручную из пользователя нельзя сделать git pull, то и это работать тоже не будет

=cut

sub new
{
  my $class = shift;
  my $self  = $class->SUPER::new();
  bless $self, $class;

  $self->_init(@_);
  return $self;
}

sub _init
{
  my $this = shift;
  my $opt  = { @_ };
  if ( $opt->{ user } && $opt->{ dir } )
  {
    $this->{ _user } = $opt->{ user };
    $this->{ _dir }  = $opt->{ dir };
  }
  else
  {
    croak 'Undefined user or dir';
  }

  my $rep = q();
  eval {
    require Git::Repository;
    $rep = Git::Repository->new( work_tree => $this->{ _dir } );
  };
  if ($@)
  {
    $this->status->set_fail($@);
  }
  else
  {
    $this->status->set_success();
  }
  $this->{ _rep } = $rep;

  return;
}

=pod

=head2 pull

Инициирует слив проекта из гита

	$git->pull;
	# если попытка неудачна, тогда весь результат будет записан в result_as_string
	if (! $git->status->is_success)
	{
		$result = $git->status->result_as_string; 
	}

=cut

sub pull
{
  my $this = shift;

  my $command = "su - ".$this->{ _user }." -c 'cd ".$this->{ _dir }." && git pull'";

  my @result = `$command`;
  my @success_msg = ( 'up\-to\-date', 'Fast\-forward' );

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

=head2 CHANGES

	Version 0.04
	Savenkova Natalya, simple modify

	Version 0.03
	Savenkova Natalya, переведен на ITMATRIX::AppDeployer::Core
	
	Version 0.02
	Savenkova Natalya, pull command fixed

=head1 AUTHOR

Copyright 2012 Savenkova Natalya.

=cut
