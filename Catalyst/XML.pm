package Smotri::Controller::XML;
use uni::perl qw/:dumper/;

use Moose;
use namespace::autoclean;

use List::Util qw(shuffle);
BEGIN { extends 'Catalyst::Controller' }

sub base : Chained('') : PathPart('xml') : Args(1) {
    my ( $self, $c, $block ) = @_;
    $block =~ s/(\.xml)//;
    $self->$block($c);
    $c->stash( current_view => 'RSS' );
}

=pod

=head2 channels_censored

По ссылке /xml/channels_censored.xml/ отдает XML

=cut

sub channels_censored {
    my ( $self, $c ) = @_;

    my $params = { width     => 55,
                   height    => 55,
                   moderated => 'public',
                   age_max   => 17,
                   without   => ['video', 'tags'],
                   order     => '-ctime',
                 };

    # Исключаем категории: 18+, Детям, Стиль жизни, Природа
    my @exclude_caterories = ( 11, 15, 8, 14 );

    my $limit_for_iter = 30;
    my @channels       = ();
    my $max_iter       = 3;
    my $iter           = 0;
    my $max_channels   = 30;
    while ( scalar @channels < $max_channels && $iter < $max_iter ) {
        my $channels = $c->pgc_interface->channels->list( %{ $params },
                                                          limit  => $limit_for_iter,
                                                          offset => $limit_for_iter * $iter
                                                        )->{ list };
        for my $ch (@$channels) {
            unless ( grep( $ch->{ genre }->{ category_id } eq $_, @exclude_caterories ) ) {
                push @channels, $ch;
                last if scalar @channels >= $max_channels;
            }
        }
        $iter++;
    }
    $self->_output( $c, $params, \@channels );
    return;
}

=pod

=head2 channels_erotic

По ссылке /xml/channels_erotic.xml/ отдает XML для раздела Эротики

=cut

sub channels_erotic {
    my ( $self, $c ) = @_;

    my $params = { width     => 55,
                   height    => 55,
                   moderated => 'public',
                   without   => ['video', 'tags'],
                   order     => '-ctime',
                 };

    # Выбираем из категорий 18+, Увлечения, Спорт, События
    my @channels = ();
    for my $cat ( 11, 12, 16, 40 ) {
        push @channels, @{ $c->pgc_interface->channels->list( %{ $params }, category => $cat, limit => 10 )->{ list } };
    }

    $self->_output( $c, $params, \@channels );
    return;
}

sub _output {
    my ( $self, $c, $params, $channels ) = @_;

    @$channels = shuffle(@$channels);
    @$channels = splice( @$channels, 0, 10 );

    my $suffix = '?utm_source=oldvideo&utm_medium=cpc&utm_campaign=overlay';
    my $domain = $c->req->uri->host;
    my $data   = [];
    for my $ch (@$channels) {

        # Обрезаем первые 100 символов
        $ch->{ description } = substr( $ch->{ description }, 0, 100 ) . '...';

        my $elem = {
             title  => [$ch->{ name }],
             desc   => [$ch->{ description }],
             domain => [$domain],
             url    => [
                 $c->uri_for_action( '/items/switch',
                                    [$ch->{ genre }->{ category_alias }, $ch->{ genre }->{ alias }, 'c' . $ch->{ id }] )
                   ->as_string . $suffix
             ],
             img => { src => $ch->{ cover }, width => $params->{ width }, height => $params->{ height } }
        };
        push @$data, $elem;
    }
    $c->stash->{ view_rss } = { begun => [{ banner => $data }] };
}
__PACKAGE__->meta->make_immutable;

1;
