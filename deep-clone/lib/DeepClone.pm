package DeepClone;
# vim: noet:

use 5.016;
use warnings;

=encoding UTF8

=head1 SYNOPSIS

Клонирование сложных структур данных

=head1 clone($orig)

Функция принимает на вход ссылку на какую либо структуру данных и отдаюет, в качестве результата, ее точную независимую копию.
Это значит, что ни один элемент результирующей структуры, не может ссылаться на элементы исходной, но при этом она должна в точности повторять ее схему.

Входные данные:
* undef
* строка
* число
* ссылка на массив
* ссылка на хеш
Элементами ссылок на массив и хеш, могут быть любые из указанных выше конструкций.
Любые отличные от указанных типы данных -- недопустимы. В этом случае результатом клонирования должен быть undef.

Выходные данные:
* undef
* строка
* число
* ссылка на массив
* ссылка на хеш
Элементами ссылок на массив или хеш, не могут быть ссылки на массивы и хеши исходной структуры данных.

=cut

sub clone {
	my ($orig, $call_history) = @_;

	my $cloned;
	if (ref $orig eq "ARRAY") {
		my @copy = @$orig;
		for (@copy) {
			if (defined $_ && $call_history->{$_}) {
				$_ = $call_history->{$_};
			} else {
				$call_history->{$orig} = \@copy;
				$_ = clone($_, $call_history);
			}
		}
		$cloned = \@copy;
	} elsif (ref $orig eq "HASH") {
		my %copy = %$orig;
		for (keys %copy) {
			if (defined $copy{$_} && $call_history->{$copy{$_}}) {
				$copy{$_} = $call_history->{$copy{$_}};
			} else {
				$call_history->{$orig} = \%copy;
				$copy{$_} = clone($copy{$_}, $call_history);
			}
		}
		$cloned = \%copy;
	} elsif(not ref $orig) {
		$cloned = $orig;
	} else {
		$cloned = undef;
	}
	return $cloned;
}

1;