package Local::Reducer::MaxDiff;

use strict;
use warnings;
use Scalar::Util qw(looks_like_number);

use parent 'Local::Reducer';

sub reduce_n {
    my ($self, $n) = @_;
    my $source = $self->{source};
    my $accum = 0;
    my $i = 0;
    my ($top, $bottom) = ("-inf", "+inf");
    while ($i < $n) {
        my $next_line = $source->next();
        last unless (defined $next_line); ## is empty string defined ? #ACHTUNG
        my $row_obj = $self->{row_class}->new(str => $next_line);
        unless (defined $row_obj) {
            $i ++;
            next;
        }

        my $top_temp = $row_obj->{$self->{top}};
        my $bottom_temp = $row_obj->{$self->{bottom}};
        next if ( !(defined $top_temp && looks_like_number($top_temp)) 
                && !(defined $bottom_temp && looks_like_number($bottom_temp)));

        $top = $top_temp if ($top_temp > $top && defined $top_temp && looks_like_number($top_temp));
        $bottom = $bottom_temp if ($bottom_temp < $bottom && defined $bottom_temp && looks_like_number($bottom_temp));
        $i ++;
    }
    $self->{reduced} = $top - $bottom > $self->{reduced} ? $top - $bottom : $self->{reduced};
    ## negative value ? ##ACHTUNG
}

1;