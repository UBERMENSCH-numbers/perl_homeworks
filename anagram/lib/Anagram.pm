package Anagram;
# vim: noet:

use 5.016;
use warnings;
use Data::Dumper;

=encoding UTF8


=head1 SYNOPSIS

Поиск анаграмм

=head1 anagram($arrayref)

Функция поиска всех множеств анаграмм по словарю.

Входные данные для функции: ссылка на массив - каждый элемент которого - слово на русском языке в кодировке utf8

Выходные данные: Ссылка на хеш множеств анаграмм.

Ключ - первое встретившееся в словаре слово из множества
Значение - ссылка на массив, каждый элемент которого слово из множества, в том порядке в котором оно встретилось в словаре в первый раз.

Множества из одного элемента не должны попасть в результат.

Все слова должны быть приведены к нижнему регистру.
В результирующем множестве каждое слово должно встречаться только один раз.
Например

anagram(['пятак', 'ЛиСток', 'пятка', 'стул', 'ПяТаК', 'слиток', 'тяпка', 'столик', 'слиток'])

должен вернуть ссылку на хеш


{
	'пятак'  => ['пятак', 'пятка', 'тяпка'],
	'листок' => ['листок', 'слиток', 'столик'],
}

=cut

sub anagram {

	my @words_list = @{+shift};
	for (@words_list) { $_ = lc $_ };
	my %uniq;
	@words_list = grep { !$uniq{lc $_}++ } @words_list;

	my %result = map { (join '', sort split //) => [] } @words_list;

	my %anagram;
	for (@words_list) {
		my $sorted = join '', sort split //;
		if ($result{$sorted}) { push(@{$result{$sorted}}, $_) };
	}

	for (keys %result) {
		my $val = delete $result{$_};
		if (scalar @$val > 1) { $result{$val->[0]} = $val };
	}

	return \%result;
}

1;
