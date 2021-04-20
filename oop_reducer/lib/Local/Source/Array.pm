package Local::Source::Array;

use strict;
use warnings;

use parent 'Local::Source::SourceAbstract';

sub new {
    my $self = shift;
    my %hash = @_;
    $hash{pos} = 0;
    return bless \%hash, $self;
}

1;