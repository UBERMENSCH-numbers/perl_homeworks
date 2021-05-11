package Local::Source::FileHandle;

use strict;
use warnings;

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

sub new {
    my $self = shift;
    my %hash = @_;
    $hash{pos} = 0;
    return bless \%hash, $self;
}

sub remain {
    return "+inf";
}

1;