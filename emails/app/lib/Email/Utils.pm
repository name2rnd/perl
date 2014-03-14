package Email::Utils;
use strict;
use warnings;
use utf8;

require Exporter;
our @ISA       = qw(Exporter);
our @EXPORT_OK = qw(check_valid chomp_email extract_domain);

our $VERSION = 0.01;

=pod

=encoding utf8

=head1 NAME

Email::Utils Набор утилит для работы с email

=head1 SYNOPSIS

    use Email::Utils qw/check_valid chomp_email extract_domain/;
    my $email = chomp($email);
    my $valid = check_valid($email);
    my $domain = extract_domain($email);

=head1 METHODS

=head2 chomp_email

Вырезает лишние символы из потенциального email-адреса

    my $email = chomp($email);

=cut

sub chomp_email {
    my $email = shift;

    if ($email) {
        $email =~ s/^\s+//;
        $email =~ s/\s+$//;
        chomp($email);
        return $email;
    }
    return q();
}

=pod

=head2 check_valid

Валидация email. Использует модуль Email::Valid L<http://search.cpan.org/~rjbs/Email-Valid-1.192/lib/Email/Valid.pm>

    my $is_valid = check_valid($email);

=cut

sub check_valid {
    my $email = shift;

    my $valid = 0;
    if ($email) {
        require Email::Valid;
        my $correct_email = 'Email::Valid'->address($email);
        $valid = $correct_email ? 1 : 0;
    }
    else {
        $valid = 0;
    }
    return $valid;
}

=pod

=head2 extract_domain

Возвращает имя домена, который указан в email. Использует модуль Domain::Utils

  my $domain = extract_domain($email);

=cut

sub extract_domain {
    my $email = shift;

    $email = chomp_email($email);
    if ( check_valid($email) ) {
        # получаем имя домена из email (все, что после @)
        $email =~ /@(.+)/;
        require Domain::Utils;
        my $domain = Domain::Utils::decode_punycode($1);
        return $domain;
    }
    return q();
}

=pod

=head1 AUTHOR

Savenkova Natalya

=cut

1;
