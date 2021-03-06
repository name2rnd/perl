package ITMATRIX::Page::Articles;

=pod

=head1 NAME

ITMATRIX::Page::Articles - My author was too lazy to write an abstract

=head1 SYNOPSIS

  my $object = ITMATRIX::Page::Articles->new(
      foo  => 'bar',
      flag => 1,
  );
  
  $object->dummy;

=head1 DESCRIPTION

The author was too lazy to write a description.

=head1 METHODS

=cut

use 5.008009;
use strict;
use warnings;

use base 'ITMATRIX::Page';

our $VERSION = '0.01';

=pod

=head2 new

  my $object = ITMATRIX::Page::Articles->new(
      foo => 'bar',
  );

The C<new> constructor lets you create a new B<ITMATRIX::Page::Articles> object.

So no big surprises there...

Returns a new B<ITMATRIX::Page::Articles> or dies on error.

=cut

sub new {
	my $class = shift;
	my $self  = bless { @_ }, $class;
	$self->{ class } = 'article';
	return $self;
}



1;

=pod

=head1 SUPPORT

No support is available

=head1 AUTHOR

Copyright 2012 Savenkova Natalya.

=cut
