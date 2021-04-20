package Local::Row::RowAbstract;

use strict;
use warnings;

sub get {
    my ($self, $name, $default) = @_;
    return $self->{$name} || $default;
}

1;