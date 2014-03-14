package EmailParser;
use strict;
use warnings;
use utf8;

use Carp qw/croak/;
use Readonly;
Readonly my $INVALID_DOMAIN_NAME => 'INVALID';

require Exporter;
our @ISA       = qw(Exporter);
our @EXPORT_OK = qw(count_by_domains);

our $VERSION = 0.01;

=pod

=head1 NAME

=encoding utf8

EmailParser - модуль для разбора файла с email адресами

=head1 SYNOPSIS

    use EmailParser qw/count_by_domains/;
    my $result = count_by_domains($file_path);

=head1 METHODS

=head2 count_by_domains

Подсчитывает количество email в различных доменах (с проверкой валидности email)

    my $result = count_by_domains($filepath);

Выходные данные в формате { domain1 => count1, domain2 => count2 }. Для невалидных адресов создается общий ключ INVALID.

=cut

sub count_by_domains {
    my $filepath = shift;

    my $emails = _prepare_data($filepath);
    my $result = {};
    require Email::Utils;
    require Domain::Utils;
    for my $email (@$emails) {
        my $domain = Email::Utils::extract_domain($email);
        if ($domain) {
            $domain = Domain::Utils::decode_punycode($domain);
        }
        else {
            $domain = $INVALID_DOMAIN_NAME;
        }
        utf8::encode($domain);
        $result->{ $domain }++;
    }
    return $result;
}

sub _prepare_data {
    my $filepath = shift;

    if ( -e $filepath ) {
        my $file = undef;
        open $file, "<:utf8", $filepath or croak "cannot open < $filepath: $!";
        my @data = <$file>;
        close $file;
        return \@data;
    }
    else {
        return [];
    }
}

=pod

=head1 AUTHOR

Savenkova Natalya

=cut

1;
