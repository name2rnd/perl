package ITMATRIX::Page::Include::content;

=pod

=head1 NAME

ITMATRIX::Page::Include::content - My author was too lazy to write an abstract

=head1 SYNOPSIS

  my $object = ITMATRIX::Page::Include::content->new(
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

our $VERSION = '0.01';
use base 'ITMATRIX::Page::Include';

=pod

=head2 new

  my $object = ITMATRIX::Page::Include::ontent->new(
      foo => 'bar',
  );

The C<new> constructor lets you create a new B<ITMATRIX::Page::Include::content> object.

So no big surprises there...

Returns a new B<ITMATRIX::Page::Include::content> or dies on error.

=cut

sub new {
	my $class = shift;
	my $self  = bless { @_ }, $class;
	return $self;
}

1;

=pod

=head1 SUPPORT

No support is available

=head1 AUTHOR

Copyright 2012 Savenkova Natalya.

=cut
