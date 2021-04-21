package Local::Source::FileHandle;

use strict;
use warnings;

use parent 'Local::Source::SourceAbstract';

sub next {
    my $self = shift;
    my $fh = $self->{fh};

    while (my $line = <$fh>) {
        if ($. == $self->{pos}+1) {
            $self->{pos} ++;
            chomp $line;
            return $line;
        }
    }
    return undef;
}

1;