package Local::Source::FileHandle;

use strict;
use warnings;

sub new {
    my $self = shift;
    my %hash = @_;
    $hash{pos} = 0;
    return bless \%hash, $self;
}

sub next {
    my $self = shift;
    my $fh = $self->{fh};

    return undef if ($self->{end}); 

    while (my $line = <$fh>) {
        $self->{end} = 1 if (eof); 
        if ($. == $self->{pos}+1) {
            $self->{pos} ++;
            chomp $line;
            return $line;
        }
    }
}

1;