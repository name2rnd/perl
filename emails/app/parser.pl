#!/usr/bin/perl

=pod

Утилита для подсчета количества email по каждому домену

    perl parser.pl -file list.txt

Входные данные:
Текстовый файл с email-адресами (разделитель — перевод строки). Пример:
    info@mail.ru
    support@vk.com
    ddd@rambler.ru
    roxette@mail.ru
    sdfsdf@@@@@rdfdf
    example@localhost
    иван@иванов.рф
    ivan@xn--c1ad6a.xn--p1ai

С проверкой валидности email-адреса. Если адрес не валиден, тогда данные группируются по ключу INVALID
Punycode декодируется в *.рф

Формат выходных данных (данные сортируются по количеству адресов в домене в порядке убывания):

    INVALID 3
    mail.ru 2
    vk.com  1
    rambler.ru  1
    рег.рф 1

=cut

BEGIN
{
    my $path = "/usr/home/nat/data/tmp/emails/app/lib/";
    unshift @INC, $path;
}

use utf8;
use strict;
use warnings;

use autouse 'Data::Dumper' => qw(Dumper);

use Getopt::Long;
my $filename = q();
GetOptions( "file=s" => \$filename );

if ( $filename && -e $filename ) {
    my $domains = parse($filename);
    for my $domain (@$domains) {
        my $name = $domain->{ name };
        printf( "%s %s \n", $name, $domain->{ value } );
    }
}
else {
    print "\nFile $filename doesn't exists\n";
}


sub parse {
    my $filename = shift @_;

    require EmailParser;
    my $domains  = EmailParser::count_by_domains($filename);

    # преобразовываем полученный хеш в массив хешей вида 
    # { name => 'domain', value => 'count'} для последующей сортировки
    my @domains  = map +{ name => $_, value => $domains->{ $_ } }, keys %{ $domains };

    # сортируем по убыванию по value
    @domains = sort { $b->{ value } <=> $a->{ value } } @domains;
    return \@domains;
}
exit(0);
