use strict;
use warnings;
use autouse 'Data::Dumper' => qw(Dumper);

BEGIN {
    unshift @INC, "/usr/home/vzv/data/tmp/emails/app/lib/";
}
use utf8;

use Test::More;
use_ok('EmailParser');

use EmailParser qw/count_by_domains/;
my $path = "/usr/home/vzv/data/tmp/emails/module_tests/";

my $file_path = $path . 't/undef.txt';
my $result    = EmailParser::_prepare_data($file_path);
is( scalar( @{ $result } ), 0, 'parse nonexistent file OK' );

$file_path = $path . 't/data.txt';
$result    = EmailParser::_prepare_data($file_path);

my $file = undef;
open $file, "<:utf8", $file_path or die "cannot open < $file_path: $!";
my $i = 0;
while (<$file>) {
    is( $result->[$i], $_, 'line OK' );
    $i++;
}
close($file);
is( scalar @{ $result }, $i, 'elems OK' );

$result = count_by_domains($file_path);
is( scalar keys %{ $result }, 4, 'domains OK' );

my $reg_ref = 'рег.рф';
utf8::encode($reg_ref);

my $domains = { 'mail.ru' => 1,
                'vk.com'  => 1,
                $reg_ref  => 1,
                'INVALID' => 2,
                };

for my $name ( keys %{ $domains } ) {
    is( $domains->{ $name }, $result->{ $name }, $name." OK" );
}

done_testing();
