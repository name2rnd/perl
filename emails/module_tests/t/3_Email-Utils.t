use strict;
use warnings;
use autouse 'Data::Dumper' => qw(Dumper);

BEGIN {
    my $path = "/usr/home/vzv/data/tmp/emails/app/lib/";
    unshift @INC, $path;
}

use Test::More;
use_ok('Email::Utils');

use utf8;

use Email::Utils qw/chomp_email check_valid extract_domain/;

is( chomp_email(q()),              q(),            'chomp OK' );
is( chomp_email(undef),            q(),            'chomp OK' );
is( chomp_email('     '),          q(),            'chomp OK' );
is( chomp_email('info@mail.ru'),   'info@mail.ru', 'chomp OK' );
is( chomp_email(' info@mail.ru '), 'info@mail.ru', 'chomp OK' );
is(chomp_email( '
  иван@иванов.рф
' ), 'иван@иванов.рф', 'chomp OK');

is( check_valid(q()),                 0, 'invalid OK' );
is( check_valid(undef),               0, 'invalid OK' );
is( check_valid('     '),             0, 'invalid OK' );
is( check_valid('info@mail.ru'),      1, 'info@mail.ru valid OK' );
is( check_valid('example@localhost'), 0, 'example@localhost invalid OK' );
my $email = 'иван@иванов.рф';
utf8::encode($email);
is( check_valid('иван@иванов.рф'), 0, $email . ' invalid OK' );
is( check_valid('ivan@xn--c1ad6a.xn--p1ai'),   1, 'ivan@xn--c1ad6a.xn--p1ai valid OK' );
is( check_valid('sdfsdf@@@@@rdfdf'),           0, 'sdfsdf@@@@@rdfdf invalid OK' );
is( check_valid('my.name@domain.com'),         1, 'my.name@domain.com valid OK' );

is( extract_domain('info@mail.ru'),               'mail.ru', 'mail.ru domain OK' );
is( extract_domain('support@vk.com'),             'vk.com',  'vk.com domain OK' );
is( extract_domain('example@localhost'),          q(),       'undef domain OK' );
is( extract_domain('иван@иванов.рф'), q(),       'undef domain OK' );
my $domain = 'рег.рф';
utf8::encode($domain);
is( extract_domain('ivan@xn--c1ad6a.xn--p1ai'), 'рег.рф', $domain . ' OK' );

done_testing();
