package ITMATRIX::Page::Main_page;

=pod

=head1 NAME

ITMATRIX::Page::Main_page - My author was too lazy to write an abstract

=head1 SYNOPSIS

  my $object = ITMATRIX::Page::Main_page->new(
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

use ITMATRIX::Page;
use base 'ITMATRIX::Page';

our $VERSION = '0.01';

=pod

=head2 new

  my $object = ITMATRIX::Page::Main_page->new(
      foo => 'bar',
  );

The C<new> constructor lets you create a new B<ITMATRIX::Page::Main_page> object.

So no big surprises there...

Returns a new B<ITMATRIX::Page::Main_page> or dies on error.

=cut

sub new
{
  my $class = shift;

  my $self = bless { @_ }, $class;
  $self->{ page_class } = 'main_page';
  return $self;
}

=pod

=head2 dummy

This method does something... apparently.

=cut

sub draw_to_file
{
  my $this = shift;
  my $filename = shift || 'index.html';

  my $content = $this->_draw();
  $filename = 'io_app'->get_app_param('fo_root_path').$filename;
  $this->_write_to_file( $filename, $content );
  return;
}

1;

=pod

=head1 SUPPORT

No support is available

=head1 AUTHOR

Copyright 2012 Savenkova Natalya.

=cut
