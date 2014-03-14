package ITMATRIX::Page::Include::menu_top_articles;

=pod

=head1 NAME

ITMATRIX::Page::Include::menu_top_articles - My author was too lazy to write an abstract

=head1 SYNOPSIS

  my $object = ITMATRIX::Page::Include::menu_top_articles->new(
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
use autouse 'Data::Dumper' => qw(Dumper);
=pod

=head2 new

  my $object = ITMATRIX::Page::Include::menu_top_articles->new(
      foo => 'bar',
  );

The C<new> constructor lets you create a new B<ITMATRIX::Page::Include::menu_top_articles> object.

So no big surprises there...

Returns a new B<ITMATRIX::Page::Include::menu_top_articles> or dies on error.

=cut

sub new {
	my $class = shift;
	my $self  = bless { @_ }, $class;
	return $self;
}

sub _draw_entity_values
{
  my $this = shift;

	my $utils = $this->get_utils();
	my $deep_level = 2; # уровень вложенности, сколько статей вернуть
	my $articles = $utils->get_articles_loop_simple('top_menu', $deep_level);
my @values = $this->get_templater->{ _tmpl }->param();
die Dumper @values;
	
  return 1;
}

1;

=pod

=head1 SUPPORT

No support is available

=head1 AUTHOR

Copyright 2012 Savenkova Natalya.

=cut
