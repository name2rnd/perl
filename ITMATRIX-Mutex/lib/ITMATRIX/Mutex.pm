package ITMATRIX::Mutex;

use 5.008009;
use strict;
use warnings;
use Time::HiRes qw(gettimeofday tv_interval);

require Exporter;

our @ISA = qw(Exporter);

# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.

# This allows declaration	use ITMATRIX::Mutex ':all';
# If you do not need this, moving things directly into @EXPORT or @EXPORT_OK
# will save memory.
our %EXPORT_TAGS = ( 'all' => [ qw(
	
) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = qw(
	
);

our $VERSION = '0.02';

sub new 
{
	my $this = shift @_;
	my $params = shift @_;
  my $self = {};
	bless($self, $this);
	# значения по умолчанию
	$self->{ _livetime } = 10; # время жизни блокировки в секундах
	$self->{ _wait_timeout } = 1; # максимальное время ожидания снятия блокировки по умолчанию
	$self->{ _max_lock_prolong } = 3; # максимальное количество пролонгации блокировки
	$self->{ _prolong_counter } = 0; # общее количество пролонгации блокировки
	$self->{ _timer_start } = 0; # время начало работы блокировки
	$self->init($params);
	return($self);
}

# ============================================================================
sub init
{
	my $this = shift @_;
	my $params = shift @_;
	
	$this->set_livetime($params->{ livetime });
	$this->set_wait_timeout($params->{ wait_timeout });
	$this->set_max_prolong($params->{ max_prolong });
	return;
}

# ============================================================================
sub set_livetime
{
	my $this = shift @_;
	my $livetime = shift @_;
	if ($livetime && $livetime =~ m/^\d+$/) # время жизни должно быть установлено и должно быть целыми числом
	{
		$this->{ _livetime } = $livetime;
	}
	return;
}

# ============================================================================
sub set_wait_timeout
{
	my $this = shift @_;
	my $wait_timeout = shift @_;
	if ($wait_timeout && $wait_timeout =~ m/^\d+$/) # время жизни должно быть установлено и должно быть целыми числом
	{
		$this->{ _wait_timeout } = $wait_timeout;
	}
	return;
}

# ============================================================================
sub set_max_prolong
{
	my $this = shift @_;
	my $plolong = shift @_;
	if ($plolong && $plolong =~ m/^\d+$/) # время жизни должно быть установлено и должно быть целыми числом
	{
		$this->{ _max_lock_prolong } = $plolong
	}
	return;
}

# ============================================================================
sub get_livetime
{
	my $this = shift @_;
	return $this->{ _livetime };
}	

# ============================================================================
sub get_wait_timeout
{
	my $this = shift @_;
	return $this->{ _wait_timeout };
}	

# ============================================================================
sub get_max_prolong
{
	my $this = shift @_;
	return $this->{ _max_lock_prolong };
}

# ============================================================================
sub lock
{
	my $this = shift @_;
	$this->_lock();
	return;
}

# ============================================================================
sub unlock
{
	my $this = shift @_;
	$this->_reset_prolong_counter();
	$this->_unlock();
	return;
}
# ============================================================================
sub _prolong
{
	my $this = shift @_;
	if ($this->_is_prolongation_accepted())
	{
		$this->_increase_prolong_counter();
		$this->_lock();
		return 'accepted';
	}
	else
	{
		return 'refused';
	}	
}

# ============================================================================
sub _is_prolongation_accepted
{
	my $this = shift @_;
	return ($this->get_prolong_counter() < $this->get_max_prolong() ) ? 1 : 0;
}

# ============================================================================
sub get_prolong_counter
{
	my $this = shift @_;
	return $this->{ _prolong_counter };
}

# ============================================================================
sub _increase_prolong_counter
{
	my $this = shift @_;
	$this->{ _prolong_counter }++;
	return;
}

# ============================================================================
sub _reset_prolong_counter
{
	my $this = shift @_;
	$this->{ _prolong_counter } = 0;
	return;
}

# ============================================================================
sub wait
{
	my $this = shift @_;
	my $seconds = shift @_ || $this->get_wait_timeout();
	sleep($seconds);
	return;
}

# ============================================================================
sub timer_start
{
	my $this = shift @_;
	$this->{ _timer_start } = [gettimeofday];
	return;
}

# ============================================================================
sub get_time_period
{
	my $this = shift @_;
	return tv_interval($this->{ _timer_start });
}

# ============================================================================
sub wait_unlock
{
	my $this = shift @_;
	my $params = shift @_;
	# use Data::Dumper;
	# die Dumper $params;
	# предпринимаем попытки ожидания завершения блокировки - либо она завершилась, либо кол-во попыток превышено
	my $max_times = 3; 
	while ($this->is_locked())
	{
	# print 1;
		$this->wait();
		$max_times--;
		last if $max_times <= 0;
	}
	
	# если блокировка снята
	if ($this->is_unlocked())
	{
	# print 'unlock';
		# если есть функция, которую нужно выполнить после успешного завершения
		if ($params->{ callback_wait_success })
		{
			my $func = $params->{ callback_wait_success };
			$func->(); # вызов функции callback после завершения одижания
			return;
		}
	}
	else # не дождались
	{
	# print "lock\n";
		# если есть функция, которую нужно выполнить, если не дождались
		if ($params->{ callback_wait_failed })
		{
			my $func = $params->{ callback_wait_failed };
			# print $func."\n";
			$func->(); # вызов функции callback после завершения одижания
		}
		else
		{
			die 'cant wait more'; # аварийная ситуация - не дождались разблокировки и не обработчика на этот случай
		}
	}
	return;
}

# ============================================================================
sub is_locked
{
	my $this = shift @_;
	die 'Cant use abstract function';
	return;
}

# ============================================================================
sub is_unlocked
{
	my $this = shift @_;
	return not $this->is_locked();
}

# ============================================================================
sub prolong
{
	my $this = shift @_;
	my $params = shift @_;
	
	my $prolong_status = $this->_prolong();
	if ($prolong_status eq 'accepted')
	{
		$this->timer_start(); # перезапускам таймер
		return;
	}
	elsif ($prolong_status eq 'refused')
	{
		if ($params->{ callback_prolong_failed })
		{
			my $func = $params->{ callback_prolong_failed };
			$func->(); # вызов функции, если так и не дождались разблокировки
		}
		else
		{
			die 'cant prolong more'; # это аварийная ситуация - завершаем программу
		}
	}
}

1;
__END__

=encoding utf8

=head1 NAME

ITMATRIX::Mutex - Базовый класс для работы с мьтексом

=head1 SYNOPSIS

  use ITMATRIX::Mutex; 
  my $mut = 'ITMATRIX::Mutex'->new();

=head1 DESCRIPTION

Абстрактный класс, используется как родитель, нужен класс, определяющий механизмы хранения мьтексов (например, ITMATRIX::Mutex::Memcached)

=head1 FUNCTIONS

=head2 new
Создает объект

my $mut = 'ITMATRIX::Mutex'->new([$options_hash_ref]);

$options_hash - необязательный параметр для инициализации объекта. Если он не задан, будут использованы значения по умолчанию.
Допустимые значения:
livetime - время жизни в секундах для блокировки (уничтожается по истечении заданного периода), по умолчанию 10 сек.
wait_timeout - время ожидания освобождения блокировки в секундах, по умолчанию 1 сек
max_prolong - максимальное количество продлений блокировки одним процессом, по умолчанию 3 раза

=head2 init

	Установка параметров объекта для уже созданного ранее объекта. Можно создать объект с параметрами по умолчанию, а потом вызывать init отдельно
	$mut->init($options_hash_ref);
	Для установки параметров используются отдельные функции set_livetime($p), set_wait_timeout($p), set_max_prolong($p)

=head2 set_livetime

	$mut->set_livetime($sec)
	Установить время жизни блокировки

=head2 set_wait_timeout

	$mut->set_wait_timeout($sec)
	Установить время ожидания освобождения блокировки

=head2 set_max_prolong

	$mut->set_max_prolong($times)
	Установить количество продлений блокировки (если процесс не успел завершиться за отведенное время, можно продлить блокировку, но ограниченное количество раз)

=head2 get_livetime

	my $sec = $mut->get_livetime();
	Возвращает текущее время жизни блокировки

=head2 get_wait_timeout

	my $sec = $mut->get_wait_timeout();
	Возвращает установленное время ожидания освобождения блокировки

=head2 get_max_prolong

	my $times = $mut->get_max_prolong();
	Возвращает максимальное допустимое количество раз продления блокировки

=head2 lock

	$mut->lock()
	Установить блокировку

=head2 unlock

	$mut->unlock();
	Снять блокировку

=head2 prolong

	my $result = $mut->prolong();
	Попытка продлить блокировку ключа, если блокировка продлена, возвращает accepted, если запрещена - refused

=head2 wait

	$mut->wait();
	Ждет указанный при создании мьютекса период

=head2 timer_start

	$mut->timer_start();
	Перезапускает таймер времени

=head2 get_time_period

	my $sec = $this->get_time_period();
	Возвращает количество секунд, прошедших со времени перезапуска таймера, используется для отслеживания процессов, которым нужно продлить время блокировки, если время работы у процесса дольше, чем время жизни блокировки

=head1 Changes

В конструкторе убрана передача io_app. Теперь создавать просто my $mut = 'ITMATRIX::Mutex'->new();

=head1 SEE ALSO

ITMATRIX::Mutex::Memcached



=head1 AUTHOR

User Natalya Savenkova, <natali@itmatrix.ru>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012 by Natalya Savenkova

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.9 or,
at your option, any later version of Perl 5 you may have available.


=cut
