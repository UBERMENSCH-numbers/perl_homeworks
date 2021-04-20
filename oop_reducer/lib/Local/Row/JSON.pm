package Local::Row::JSON;

use strict;
use warnings;
use JSON qw(decode_json);

sub new {
    my $self = shift;
    my %hash = @_;
    my $json;
    eval {
        $json = decode_json($hash{str});
        die unless ref $json eq "HASH";
        return bless $json, $self;
    } or return undef;  # ACHTUNG key:
}

sub get {
    my ($self, $name, $default) = @_;
    return $self->{$name} || $default;
}

1;
