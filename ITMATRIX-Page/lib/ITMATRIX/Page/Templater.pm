package ITMATRIX::Page::Templater;

=pod

=head1 NAME

ITMATRIX::Page::Templater - My author was too lazy to write an abstract

=head1 SYNOPSIS

  my $object = ITMATRIX::Page::Templater->new(
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
use autouse 'Data::Dumper' => qw(Dumper);
our $VERSION = '0.01';
use Carp qw(croak);

=pod

=head2 new

  my $object = ITMATRIX::Page::Templater->new(
      foo => 'bar',
  );

The C<new> constructor lets you create a new B<ITMATRIX::Page::Templater> object.

So no big surprises there...

Returns a new B<ITMATRIX::Page::Templater> or dies on error.

=cut

sub new
{
  my $class = shift;
  my $self = bless { @_ }, $class;
  $self->load();

  $self->{ parsed_keys } = [qw/meta include pageparam/];
  return $self;
}

sub load
{
  my $this = shift;
  my ( $path, $name ) = $this->_get_path_and_name();
  my $tmpl = HTML::Template->new( path => [$path], filename => $name, loop_context_vars => 1 );
  $this->{ _tmpl } = $tmpl;
  return;
}

sub _get_base_path
{
  my $this = shift;
  return 'io_app'->get_app_param('generate_templates');
}

sub _get_path_and_name
{
  my $this = shift;

  my $class = ref $this->{ page_object };
  $class =~ s/ITMATRIX::Page:://;
  $class = lc($class);

  if ($class)
  {
    my $path = $this->_get_base_path;
    my $tmpl = undef;

    if ( $class =~ m/include/ || $class =~ m/meta/ )
    {
      my $name = $this->{ page_object }->get_name;

      if ($name)
      {
        if ( $name eq 'content' )
        {
          ( $path, $name ) = $this->_get_path_and_name_for_content();
        }
        elsif ( $class eq 'meta' )
        {
          $path .= 'meta/';
        }
        else
        {
          $path .= 'include/';
        }
        return $path, $name.'.html';
      }
      else
      {
        croak('undefined NAME for include');
      }
    }
    else
    {
      return $path, 'page.html';
    }
  }
  else
  {
    croak('class not exists');
  }
  return;
}

sub _get_path_and_name_for_content
{
  my $this = shift;

  my $path = $this->_get_base_path;
  $path .= 'include/content/';
  my $name = $this->{ page_object }->get_page_class();
  # если такого не существует, то нужно использовать content.html
  if ( !-e $path.$name.'.html' )
  {
    $name = 'content';
  }
  return $path, $name;
}

sub parse
{
  my $this = shift;

  my $elements        = {};
  my @parameter_names = $this->{ _tmpl }->param();
  for (@parameter_names)
  {
    for my $key ( @{ $this->{ parsed_keys } } )
    {
      if ( $_ =~ s/$key:// )
      {
        push @{ $elements->{ $key } }, $_;
      }
    }
  }
  return $elements;
}

sub set_value
{
  my $this = shift;
  my $opt  = { @_ };

  for my $key ( keys %$opt )
  {
    if ( $key ne 'content' )
    {
      $this->{ _tmpl }->param( $key.':'.$opt->{ $key } => $opt->{ content } );
    }
  }

  # if ($opt->{ include })
  # {
  # $this->{ _tmpl }->param( 'include:'.$opt->{ include } => $opt->{ content } );
  # }
  # elsif ($opt->{ meta })
  # {
  # $this->{ _tmpl }->param( 'meta:'.$opt->{ meta } => $opt->{ content } );
  # }
  return;
}

sub get_content
{
  my $this = shift;
  return $this->{ _tmpl }->output();
}

1;

=pod

=head1 SUPPORT

No support is available

=head1 AUTHOR

Copyright 2012 Savenkova Natalya.

=cut
