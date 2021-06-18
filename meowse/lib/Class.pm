package Class;

use strict;
use warnings;
use FindBin;
use lib "/home/user/v.kotelnik/meowse/lib";
use Meowse;

extends("Parent");

has(rw_req => (is => 'rw', required => 1));
has(rw_not_req => (is => 'rw', required => 0));
has(ro_req => (is => 'ro', required => 1));
has(ro_not_req => (is => 'ro', required => 0));
has(bare_req => (is => 'bare', required => 1));
has(bare_not_req => (is => 'bare', required => 0));

sub parent_sub_override {
    return "parent_sub_override_in_childs";
}

1;