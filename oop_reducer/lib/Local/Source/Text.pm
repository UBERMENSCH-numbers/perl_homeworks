package Local::Source::Text;

use strict;
use warnings;

use parent 'Local::Source::SourceAbstract';

sub new {
    my $self = shift;
    my %hash = @_;
    $hash{array} = [ split defined $hash{delimiter} ? delete $hash{delimiter} : "\n", delete $hash{text} ];
    return $self->SUPER::new(%hash);
}

1;