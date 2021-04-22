package Local::Source::SourceAbstract;

use strict;
use warnings;

sub new {
    my $self = shift;
    my %hash = @_;
    $hash{pos} = 0;
    return bless \%hash, $self;
}

1;