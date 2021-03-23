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
	my $orig = shift;
	my $cloned;

	if (ref $orig eq "ARRAY") {
		my @copy = @$orig;
		for (@copy) {
			if ($_ == $orig) { $_ = \@copy}; 
		}
		$cloned = \@copy;
	} elsif (ref $orig eq "HASH") {
		my %copy = %$orig;
		for (keys %copy) { 
			# if ( $copy{$_} != $orig ) {
			# 	$copy{$_} = clone($copy{$_});
			# } else { $copy{$_} = \%copy };
		}
		$cloned = \%copy;
	} elsif (ref $orig eq "CODE") {
		$cloned = undef;
	} else {
		$cloned = $orig;
	}

	return $cloned;
}

1;