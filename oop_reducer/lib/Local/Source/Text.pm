package Local::Source::Text;

use strict;
use warnings;

use parent 'Local::Source::SourceAbstract';

sub new {
    my $self = shift;
    my %hash = @_;
    $hash{array} = [split $hash{delimiter} || "\n", $hash{text}];
    $hash{pos} = 0;
    delete $hash{text};
    return bless \%hash, $self;
}

1;