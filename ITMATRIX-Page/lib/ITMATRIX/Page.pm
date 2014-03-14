package ITMATRIX::Page;

=pod

=head1 NAME

ITMATRIX::Page - My author was too lazy to write an abstract

=head1 SYNOPSIS

  my $object = ITMATRIX::Page->new(
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

use base qw(Class::Accessor);
__PACKAGE__->follow_best_practice;
__PACKAGE__->mk_accessors(qw(entity templater page_class));

use English qw( -no_match_vars );

our $VERSION = '0.01';

use Carp qw(croak);

use Readonly;
Readonly my $max_recursion_deep => 10;
my $recursion_deep = 0;

use autouse 'Data::Dumper' => qw(Dumper);

use Memoize;
memoize('get_settings_obj');
memoize('get_utils');

=pod

=head2 new

  my $object = ITMATRIX::Page->new(
      foo => 'bar',
  );

The C<new> constructor lets you create a new B<ITMATRIX::Page> object.

So no big surprises there...

Returns a new B<ITMATRIX::Page> or dies on error.

=cut

sub new
{
  my $class = shift;
  my $self = bless { @_ }, $class;
  return $self;
}

sub init_templater
{
  my $this = shift;
  require ITMATRIX::Page::Templater;

  my $obj = ITMATRIX::Page::Templater->new( page_object => $this );
  $this->set_templater($obj);
  return;
}

sub _draw
{
  my $this = shift;

  $this->inc_recursion();
  $this->die_if_overrecursion();

  $this->init_templater();

  my $templater = $this->get_templater;

  my $elements = $templater->parse();

  my $includes = $elements->{ include };
  $this->_draw_includes($includes);

  my $meta = $elements->{ meta };
  $this->_draw_meta($meta);

  my $pageparam = $elements->{ pageparam };
  $this->_draw_page_params($pageparam);

  my $values = $elements->{ value };
  $this->_draw_entity_values($values);

  # $this->_prepare_output();

  my $content = $templater->get_content();

  $this->dec_recursion();
  return $content;
}

sub _draw_includes
{
  my $this     = shift;
  my $elements = shift;

  $this->_draw_elements( $elements, 'Include' );
  return;
}

sub _draw_meta
{
  my $this     = shift;
  my $elements = shift;

  $this->_draw_elements( $elements, 'Meta' );
  return;
}

sub _draw_elements
{
  my $this     = shift;
  my $elements = shift;
  my $type     = shift;

  for my $inc ( @{ $elements } )
  {
    my $class = 'ITMATRIX::Page::'.$type.'::'.lc($inc);
    eval "require $class";
    if ($EVAL_ERROR)
    {
      $class = 'ITMATRIX::Page::'.$type;
      eval "require $class";
    }
    my $object = $class->new( name => $inc, page_class => $this->get_page_class );
    $object->set_entity( $this->get_entity );
    my $content = $object->_draw();

    $this->get_templater->set_value( lc($type) => $inc, content => $content );
  }
  return;
}

sub _draw_page_params
{
  my $this   = shift;
  my $params = shift;

  for my $param ( @{ $params } )
  {
    my $func = 'get_param_'.lc($param);
    if ( $this->can($func) )
    {
      my $value = $this->$func();
      $this->get_templater->set_value( lc('PageParam') => $param, content => $value );
    }
  }
  return;
}

sub _draw_entity_values { my $this = shift;
  return;
}

sub get_param_metatitle
{
  my $this = shift;
  return $this->get_settings_obj->get_param('meta_title');
}

sub get_param_metakeywords
{
  my $this = shift;
  return $this->get_settings_obj->get_param('meta_keywords');
}

sub get_param_metadescription
{
  my $this = shift;
  return $this->get_settings_obj->get_param('meta_description');
}

sub get_settings_obj
{
  my $this = shift;
  require ITMATRIX::Entity::ShopSetting;
  return ITMATRIX::Entity::ShopSetting->new();
}

sub inc_recursion
{
  my $this = shift;
  $recursion_deep++;
  return;
}

sub dec_recursion
{
  my $this = shift;
  $recursion_deep--;
}

sub die_if_overrecursion
{
  my $this = shift;
  croak('Deep recursion') if $recursion_deep > $max_recursion_deep;
  return;
}

sub _prepare_output
{
  my $this = shift;

  return;
}

sub _write_to_file
{
  my $this     = shift;
  my $filepath = shift;
  my $content  = shift;
  require ITMATRIX::File;
  'ITMATRIX::File'->write( filepath => $filepath, content => $content );
  return;
}

sub get_utils { my $this = shift;
	require ITMATRIX::Page::Utils;
  return 'ITMATRIX::Page::Utils'->new();
}
1;

=pod

=head1 SUPPORT

No support is available

=head1 AUTHOR

Copyright 2012 Savenkova Natalya.

=cut
