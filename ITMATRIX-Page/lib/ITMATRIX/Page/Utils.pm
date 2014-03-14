package ITMATRIX::Page::Utils;

=pod

=head1 NAME

ITMATRIX::Page::Utils - My author was too lazy to write an abstract

=head1 SYNOPSIS

  my $object = ITMATRIX::Page::Utils->new(
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
use base 'ITMATRIX::Page';
use ITMATRIX::MYSQL::TableRow;
use autouse 'Data::Dumper' => qw(Dumper);
use Readonly;
Readonly my $current_deep => 0;
Readonly my $max_deep => 3;
=pod

=head2 new

  my $object = ITMATRIX::Page::Utils->new(
      foo => 'bar',
  );

The C<new> constructor lets you create a new B<ITMATRIX::Page::Utils> object.

So no big surprises there...

Returns a new B<ITMATRIX::Page::Utils> or dies on error.

=cut

sub new
{
  my $class = shift;
  my $self = bless { @_ }, $class;
  return $self;
}

# ==================================================================
sub get_articles_loop_simple
{
  my $this  = shift;
  my $type  = shift;
  my $level = shift;
  if ( !$level )
  {
    $level = 1;
  }
  my $table = 'ITMATRIX::MYSQL::TableRow'->new( table_name => 'articles' );
  my $parent_id = $table->select_field( 'id', where => { class_name => $type } );

  my @loop = ();
  
	require ITMATRIX::ObjEditor;
  my $obj = ITMATRIX::ObjEditor->new();
  
	my $ev_data = {};
	$ev_data->{ obj } = 'menu_top_articles';    # 'gen_goods_main';
	$ev_data->{ in_template } = 1;              # Передаем значения параметров в указанный шаблон
  $ev_data->{ action }      = 'edit_show';    # Выбираем товары, которые нужно показывать
  $ev_data->{ show }        = 1;              # Атрибуты показываются в режиме отображения
  
  # Выбираем товары из этого каталога
  my $io_dbi_sth = 'io_app'->db();
  my $sql        = $obj->get_sql($ev_data);
  die $sql;
    # $sql .= " LEFT JOIN  $this->{ rubricator } AS r ON r.goods_id=g.id
						# WHERE r.catalog_id=? AND "
      # .$this->get_all_goods_where_fields()." ORDER BY g.goods_status_sort_weight, r.sort_weight DESC, rand()
						# LIMIT ".( $this->{ main_page_catalog_limit } || 0 );
    # $ev_data->{ io_dbi_sth } = $io_dbi_sth;
    # $io_dbi_sth->prepare($sql);
    # $io_dbi_sth->bind( 1, $catalog_id, SQL_INTEGER );
    # $io_dbi_sth->execute();

    # while ( $obj->get_values_from_sql($ev_data) )
    


  # my $first_level = $table->select_array_hash( fields => [qw(title link_url page_name_server)],
																													# where_string => "parent_id=? AND obsolete=0", 
																													# binds => [$parent_id, 'int'] );
  # if ($level )
  # # foreach my $row (@$array_ref)
  # # {
    # # my ( $id, $title, $link_url, $page_name_server ) = @$row;
    # # push( @loop, { TITLE => $title, page_name => ( $link_url || $page_name_server ) } );
  # # }

  return \@loop;
}

1;

=pod

=head1 SUPPORT

No support is available

=head1 AUTHOR

Copyright 2012 Savenkova Natalya.

=cut
