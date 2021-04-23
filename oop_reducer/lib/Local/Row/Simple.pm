package Local::Row::Simple;

use strict;
use warnings;

use parent 'Local::Row::RowAbstract';

sub new {
    my $self = shift;
    my %hash = @_;
    my %data;
    for my $pair (split ",", $hash{str}) {
        my @items = split ":", $pair;
        return undef if @items != 2;
        $data{$items[0]} = $items[1];
    }

    return bless \%data, $self;
}

1;