package Domain::Utils;
use strict;
use warnings;
use utf8;

require Exporter;
our @ISA       = qw(Exporter);
our @EXPORT_OK = qw(decode_punycode);

our $VERSION = 0.01;

=pod

=encoding utf8

=head1 NAME

Domain::Utils - Набор утилит для работы с доменными именами

=head1 SYNOPSIS

    use Domain::Utils qw/decode_punycode/;
    my $domain = decode_punycode($domain)

=cut

=pod

=head1 METHODS

=head2 decode_punycode

Декодирует punycode. Использует Net::IDN::Encode

    my $domain = decode_punycode($domain);

=cut

sub decode_punycode {
    my $domain = shift;

    require Net::IDN::Encode;
    local $Net::IDN::Encode::IDNA_prefix = 'XN--';
    my $unicode_domain = Net::IDN::Encode::domain_to_unicode($domain);
    return $unicode_domain;
}

=pod

=head1 AUTHOR

Savenkova Natalya

=cut

1;
