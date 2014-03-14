package ITMATRIX::AppDeployer::Status;

=pod

=encoding utf8

=head1 NAME

ITMATRIX::AppDeployer::Status

=head1 SYNOPSIS

  my $object = ITMATRIX::AppDeployer::Status->new();
  $object->set_fail('msg');
  $object->set_success('msg');
  my $result = $object->result_as_string;

=head1 DESCRIPTION

Объект, содержащий статус текущего работающего модуля. Данные о последней завершенной операции

=head1 METHODS

=cut

use 5.008009;
use strict;
use warnings;

our $VERSION = 0.01;

=pod

=head2 new

  my $object = ITMATRIX::AppDeployer::Status->new();

=cut

sub new
{
  my $class = shift;
  my $self = bless { @_ }, $class;

  $self->{ _is_success } = q();
  $self->{ _result }     = q();

  return $self;
}

sub set_success
{
  my $this = shift;
  my $res  = shift;
  $this->{ _is_success } = 1;
  $this->{ _result } = $res ? $res : q();
  return;
}

sub set_fail
{
  my $this = shift;
  my $res  = shift;
  $this->{ _is_success } = 0;
  $this->{ _result } = $res ? $res : q();
  return;
}

=pod

=head2 is_success

Возвращает признак, была ли операция успешна. Значения успех/не успех выставляются внутри сами функций самим объектом

	my $is_success = $status->is_success;

=cut

sub is_success
{
  my $this = shift;
  return $this->{ _is_success };
}

=pod

=head2 result_as_string

Возвращает результат операции в виде строки

	my $res = $status->result_as_string;

=cut

sub result_as_string
{
  my $this = shift;
  return $this->{ _result } ? $this->{ _result } : q();
}

1;

=pod

=head1 AUTHOR

Copyright 2013 Savenkova Natalya.

=cut
