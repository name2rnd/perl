package hubrus_pixel;
use strict;
use warnings;
use autouse 'Data::Dumper' => qw(Dumper);
my $singleton = undef;

sub new
{
  my $class = shift;
  if ( !$singleton )
  {
    my $opt  = { @_ };
    my $self = {};
    bless $self, $class;
    $self->_init();
    $singleton = $self;
  }
  return $singleton;
}

sub _init
{
  my $this = shift;
  # вместо $PIXELID будет поставлен ID нужного пикселя
  # пиксели первого типа
  $this->{ _code_type1 } = '<!-- HUBRUS RTB Segments Pixel V2.3 -->
<script type="text/javascript" src="http://track.hubrus.com/pixel?id=$PID&type=js"></script>';

  # пиксели второго типа. Для них нужна еще дополнительная информация извне
  $this->{ _code_type2 } = '<!-- HUBRUS RTB Segments Pixel V2.3 -->
<script type="text/javascript" async="async" src="http://track.hubrus.com/pixel?id=$PID&type=js&varname1=1236_vi&value1=$ID"></script>"';

  # настройки пикселей по типам страниц
  # для каталога ID пикселя зависит еще и от конкретной рубрики

  $this->{ _pixels } = {
    'page_index'    => { pid => '20576', type => 1 },
    'form_callback' => { pid => '20578', type => 1 },
    'form_register' => { pid => '20579', type => 1 },
    # статья с id 23
    'articles_23' => { pid => '20580', type => 1 },
    'form_basket' => { pid => '20581', type => 1 },
    # catalog pages with ID
    'catalog_8176' => { pid => '20582', type => 1 },
    'catalog_3166' => { pid => '20583', type => 1 },
    'catalog_4146' => { pid => '20584', type => 1 },
    'catalog_4153' => { pid => '20585', type => 1 },
    'catalog_5778' => { pid => '20586', type => 1 },
    'catalog_5776' => { pid => '20587', type => 1 },
    'catalog_6339' => { pid => '20588', type => 1 },
    'catalog_6340' => { pid => '20589', type => 1 },
    'catalog_6585' => { pid => '20597', type => 1 },
    'catalog_6588' => { pid => '20590', type => 1 },
    'catalog_6587' => { pid => '20592', type => 1 },
    'catalog_6400' => { pid => '20593', type => 1 },
    'catalog_6401' => { pid => '20594', type => 1 },
    'catalog_9493' => { pid => '20595', type => 1 },
    'catalog_9505' => { pid => '20596', type => 1 },
    'catalog_6747' => { pid => '20591', type => 1 },
    # goods page
    'goods_card' => { pid => '20598', type => 2 },
    # goods in basket
    'goods_in_basket' => { pid => '20599', type => 2 },
    # goods bought by user
    'goods_bought' => { pid => '20600', type => 2 },
    };

  return;
}

=pod

Return pixel id

  my $pid = 'hubrus_pixel'->get_pid_for( type => 'catalog_10' );

=cut

sub get_pid_for
{
  my $this = shift;
  my $opt  = { @_ };
  $this = ref($this) ? $this : $this->new();
  my $pixel = $this->{ _pixels }->{ $opt->{ type } };
  return $pixel->{ pid } ? $pixel->{ pid } : 0;
}

sub get_pixel_for
{
  my $this = shift;
  my $opt  = { @_ };
  $this = ref($this) ? $this : $this->new();

  # transform logic for different interfaces support
  # prepare pixels group. it must be array always
  my $pixels = $opt->{ pixels } || [];
  if ( scalar @$pixels == 0 )
  {
    push @$pixels, { type => $opt->{ type }, id => $opt->{ id } };
  }
  # /// end of transform logic
  my $code = '';
  for my $pixel (@$pixels)
  {
    my $name = $pixel->{ type };
    my $id   = $pixel->{ id };

    # convert into array if scalar for different interfaces support
    my $ids = [];
    if ($id)
    {
      $ids = ref $id eq 'ARRAY' ? $id : [$id];
    }
    else
    {
      # просто фейковый массив, чтобы цикл отработал хотя бы один раз
      $ids = [0];
    }

    my $_pixel = $this->{ _pixels }->{ $name };
    my $_PID   = $_pixel->{ pid };
    my $_type  = $_pixel->{ type } || q();
    for my $_id (@$ids)
    {
      my $_code = $this->{ '_code_type'.$_type };
      if ($_code)
      {
  			# replace special symbols
        $_code =~ s/\$PID/$_PID/;
        $_code =~ s/\$ID/$_id/;
        $code .= $_code."\n";
      }
    }
  }
  return $code;
}

=pod

Для вставки кода пикселя в шаблон, в шаблоне нужно указать спец код

<!--hubrus_pixel-->

В программе вызывать

	'hubrus_pixel'->insert(html => 'code', type => 'page_index');
	'hubrus_pixel'->insert(html => 'code', type => 'goods_in_basket', id=>[1,2,3]);

Это немного другой вид пикселя, который привязан к конкретной странице

 'hubrus_pixel'->insert(html => 'code', type => 'articles_23');

Это для каталога (для каталога заданные пиксели распространяются на вложенные рубрики, 
поэтому в публикации есть дополнительный просчет пикселей)

	'hubrus_pixel'->insert(html => 'code', type => 'catalog_23');

Группа пикселей, если на странице нужно выводить несколько

	my $pixels = [{type => 'page_index'}, {type=>'goods_in_basket', id => 10}];
	my $pixels = [{type => 'page_index'}, {type=>'goods_in_basket', id => [10, 11, 12]}];
	'hubrus_pixel'->insert(html => 'code', pixels => $pixels);

=cut

sub insert
{
  my $this = shift;
  my $opt  = { @_ };
  $this = ref($this) ? $this : $this->new();
  my $html = $opt->{ html };

  my $pixel = $this->get_pixel_for( type => $opt->{ type }, id => $opt->{ id }, pixels => $opt->{ pixels } );
  if ($pixel)
  {
    $html =~ s/\<\!\-\-hubrus_pixel\-\-\>/$pixel/;
  }
  return $html;
}
1;
