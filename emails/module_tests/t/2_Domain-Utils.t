use strict;
use warnings;
use autouse 'Data::Dumper' => qw(Dumper);

BEGIN {
    my $path = "/usr/home/vzv/data/tmp/emails/app/lib/";
    unshift @INC, $path;
}
use utf8;

use Test::More;
use_ok('Domain::Utils');

use Domain::Utils qw/decode_punycode/;

is( decode_punycode('mail.ru'),   'mail.ru',   'mail.ru decode_punycode OK' );
is( decode_punycode('vk.com'),    'vk.com',    'vk.com decode_punycode OK' );
is( decode_punycode('localhost'), 'localhost', 'localhost decode_punycode OK' );
my $domain = 'иванов.рф';
utf8::encode($domain);
is( decode_punycode('иванов.рф'), 'иванов.рф', $domain . ' decode_punycode OK' );

$domain = 'рег.рф';
utf8::encode($domain);
is( decode_punycode('xn--c1ad6a.xn--p1ai'), 'рег.рф', $domain . ' decode_punycode OK' );

done_testing();
