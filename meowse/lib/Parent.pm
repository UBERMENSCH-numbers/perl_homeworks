package Parent;
use strict;
use warnings;
use Meowse;
use lib "/home/user/v.kotelnik/meowse/lib";

has parent_attr => (is => 'rw');
has parent_attr2 => (is => 'ro');

sub parent_sub {
    return "parent_sub";
}

sub parent_sub_override {
    return "parent_sub_override_in_parent";
}

1;