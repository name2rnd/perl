package ITMATRIX::AppDeployer::Core;

=pod

=encoding utf8

=head1 NAME

ITMATRIX::AppDeployer::Core

=head1 SYNOPSIS

Базовый класс для всех из этого пакета

=head1 DESCRIPTION

Предоставляет только интерфейс для работы со статусом последней выполненной операции (см. ITMATRIX::AppDeployer::Status)

	my $success = $deploy->status->is_success();
	if (! $success)
	{
		$result = $deploy->result_as_string;
	}

=head1 METHODS

=cut

use 5.008009;
use strict;
use warnings;
use ITMATRIX::AppDeployer::Status;

our $VERSION = 0.01;

sub new
{
  my $class = shift;
  my $self = bless { @_ }, $class;
  $self->{ _status } = ITMATRIX::AppDeployer::Status->new();
  return $self;
}

sub status
{
  my $this = shift;
  return $this->{ _status };
}

1;

=pod

=head1 AUTHOR

Copyright 2013 Savenkova Natalya.

=cut
