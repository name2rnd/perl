package ITMATRIX::Mutex::Memcached;
use ITMATRIX::Mutex;
use 5.008009;
use strict;
use warnings;

require Exporter;

our @ISA = qw(Exporter ITMATRIX::Mutex);

# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.

# This allows declaration	use ITMATRIX::Mutex::Memcached ':all';
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
	
  my $self = 'ITMATRIX::Mutex'->new($params);
	bless($self, $this);
	$self->{ _key } = ''; # по-умолчанию не может быть никакого ключа для блокировки
	
	my $io_app = 'io_app'->new();
	$self->{ _memcached_object } = $io_app->{ memcached }; # берем соединение с memcached из app
	$self->init($params);
	return($self);
}

# ============================================================================
sub init
{
	my $this = shift @_;
	my $params = shift @_;
	
	$this->SUPER::init($params); # сначала вызываем init родителя, потому что эта функция расширяет базовую инициализацию
	$this->set_key($params->{ key });
	return;
}

# ============================================================================
sub set_key
{
	my $this = shift @_;
	my $key = shift @_;
	if ($key)
	{
		$this->{ _key } = $key;
	}
	return;
}

# функция для переопределения объекта, по умолчанию берется из app
# ============================================================================
sub set_memcached_object
{
	my $this = shift @_;
	my $object_ref = shift @_;
	if ($object_ref)
	{
		$this->{ _memcached_object } = $object_ref;
	}
	return;
}

# ============================================================================
sub get_key
{
	my $this = shift @_;
	return $this->{ _key };
}


# ============================================================================
sub get_handler
{
	my $this = shift @_;
	return $this->{ _memcached_object };
}
# ============================================================================
sub is_locked
{
	my $this = shift @_;
	my $locked = $this->get_handler()->get_param($this->get_key());
	return $locked ? 1 : 0;
}

# ============================================================================
sub _lock
{
	my $this = shift @_;
	$this->get_handler()->set_param_timed($this->get_key(), 1, $this->get_livetime());
	return 'accepted';
}

# ============================================================================
sub _unlock
{
	my $this = shift @_;
	$this->get_handler()->delete_param($this->get_key());
	return;
}
1;
__END__

=encoding utf8

=head1 NAME

ITMATRIX::Mutex::Memcached - Класс для использования мьютексов, хранящихся в memcached

=head1 SYNOPSIS

	use ITMATRIX::Mutex::Memcached; 
	my $mut = 'ITMATRIX::Mutex::Memcached'->new([$params])
	
	В io_memcached необходимо добавить функцию
	# ==================================================================
	# delete_param
	# удаление параметра по ключу.
	# возвращает true, если ключ найден и удален, иначе false
	# ==================================================================
	sub delete_param()
	{
		my $this = shift @_;
		my $param = shift @_; # название тега, строка
		return $this->{ memcached_obj }->delete($param);
	}

=head1 DESCRIPTION

Класс для управления мьютексами, хранящимися в memcached

=head1 EXAMPLE

	Простая установка блокировки
	
	my $mem = 'io_memcached'->new({servers => ["127.0.0.1:11211"], namespace => "d2099.test_space:", compress_threshold => 10000, no_rehash =>0, debug => 0}); 
	my $mut = 'ITMATRIX::Mutex::Memcached'->new({key=>'debug_lock', memcached_object=>$mem});
	if ($mut->is_locked())
	{
		$mut->wait();
		делаем что-нибудь, если заблокирован ключ, например
	}
	else
	{
		$mut->lock();
		# ... делаем свои дела
		$mut->unlock();
	}

=head1 FUNCTIONS

=head2 new

	Создает объект

	my $mut = 'ITMATRIX::Mutex::Memcached'->new([$options_hash_ref]);

	$options_hash - необязательный параметр для инициализации объекта. Если он не задан, будут использованы значения по умолчанию.
	Допустимые значения:
	livetime - время жизни в секундах для блокировки (уничтожается по истечении заданного периода), по умолчанию 10 сек.
	wait_timeout - время ожидания освобождения блокировки в секундах, по умолчанию 1 сек
	max_prolong - максимальное количество продлений блокировки одним процессом, по умолчанию 3 раза
	key - имя ключа, который проверяется и устанавливается при блокировке
	memcached_object - ссылка на объект, работающий с memcached. Все обращения к хранилищу идут через этот объект

=head2 init

	Установка параметров объекта для уже созданного ранее объекта. Можно создать объект с параметрами по умолчанию, а потом вызывать init отдельно
	$mut->init($options_hash_ref);
	Для установки параметров используются отдельные функции set_livetime($p), set_wait_timeout($p), set_max_prolong($p), set_key('key_name'), set_memcached_object($obj_ref)

=head2 set_livetime

	$mut->set_livetime($sec)
	Установить время жизни блокировки

=head2 set_wait_timeout

	$mut->set_wait_timeout($sec)
	Установить время ожидания освобождения блокировки

=head2 set_max_prolong

	$mut->set_max_prolong($times)
	Установить количество продлений блокировки (если процесс не успел завершиться за отведенное время, можно продлить блокировку, но ограниченное количество раз)

=head2 set_key

	$mut->set_key('name')
	Установить имя ключа блокировки

=head2 set_memcached_object

	$mut->set_memcached_object($obj_ref)
	Установить объект, работающий с memcached

=head2 get_livetime

	my $sec = $mut->get_livetime();
	Возвращает текущее время жизни блокировки

=head2 get_wait_timeout

	my $sec = $mut->get_wait_timeout();
	Возвращает установленное время ожидания освобождения блокировки

=head2 get_max_prolong

	my $times = $mut->get_max_prolong();
	Возвращает максимальное допустимое количество раз продления блокировки

=head2 get_key

	my $key_name = $mut->get_key();
	Возвращает имя текущего ключа

=head2 is_locked

	my $status = $mut->is_locked()
	Возвращает признак, заблокирован этот ключ или нет

=head2 lock

	$mut->lock()
	Установить блокировку

=head2 unlock

	$mut->unlock();
	Снять блокировку

=head2 prolong

	my $result = $mut->prolong();
	Попытка продлить блокировку ключа, если блокировка продлена, возвращает accepted, если запрещена - refused. Количество продлений ограничено параметром max_prolong.

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

Убрана передача io_app в конструкторе. io_app подключается самим модулем, io_app должен быть одиночкой и делать load_globals в new

=head1 SEE ALSO

ITMATRIX::Mutex

=head1 AUTHOR

User Natalya Savenkova, <natali@itmatrix.ru>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012 by Natalya Savenkova

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.9 or,
at your option, any later version of Perl 5 you may have available.


=cut

