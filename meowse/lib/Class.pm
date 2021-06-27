package Class;

use strict;
use warnings;
use Meowse;

extends "Parent";

has rw_req => (is => 'rw', required => 1);
has rw_not_req => (is => 'rw', required => 0);
has ro_req => (is => 'ro', required => 1);
has ro_not_req => (is => 'ro', required => 0);
has bare_req => (is => 'bare', required => 1);
has bare_not_req => (is => 'bare', required => 0);
has lazy_not_req => (is => "rw", lazy_build => 1);
has lazy_req => (is => "rw", required => 1, lazy_build => 1);
has before_rw_req => (is => "rw");

sub _build_lazy_not_req {
    return "calcualated lazy_not_req attr";
}

sub _build_lazy_req {
    return "calcualated lazy_req attr";
}

sub parent_sub_override {
    return "parent_sub_override_in_childs";
}

sub multiply_2 {
    my $arg = shift;
    return $arg * 2;
}

after('parent_sub_override' => sub {
    my $self = shift;
    # $self = 'Class';
    $self->before_rw_req("after_parent_sub_override");
});

after('parent_sub' => sub {
    my $self = shift;
    $self->before_rw_req("after_parent_sub");
});

before('before_rw_req' => sub {
    my $self = shift;
    $self->rw_req(10);
    
});

around('multiply_2' => sub {
    my ($orig, $self, $arg) = @_;
    return ref \$arg ne "SCALAR" ? "arg must be scalar" : $orig->($arg);
});


no Meowse;

1;