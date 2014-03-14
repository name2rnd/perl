package ITMATRIX::Page::Include;

=pod

=head1 NAME

ITMATRIX::Page::Include - My author was too lazy to write an abstract

=head1 SYNOPSIS

  my $object = ITMATRIX::Page::Include->new(
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

  my $object = ITMATRIX::Page::Include->new(
      foo => 'bar',
  );

The C<new> constructor lets you create a new B<ITMATRIX::Page::Include> object.

So no big surprises there...

Returns a new B<ITMATRIX::Page::Include> or dies on error.

=cut

sub new
{
  my $class = shift;
  my $self = bless { @_ }, $class;
  return $self;
}

sub get_name
{
  my $this = shift;
  return $this->{ name } ? $this->{ name } : undef;
}

=pod

=head2 dummy

This method does something... apparently.

=cut

# sub _draw {
# my $self = shift;

# # require ITMATRIX::Page::Templater;
# # my $templater = ITMATRIX::Page::Templater->new();

# # $this->set_tmpl($templater);

# # Do something here

# return 1;
# }

1;

=pod

=head1 SUPPORT

No support is available

=head1 AUTHOR

Copyright 2012 Savenkova Natalya.

=cut
