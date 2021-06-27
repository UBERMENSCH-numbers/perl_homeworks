
package Meowse;

use strict;
use warnings;
use Exporter 'import';
use Carp ();
our @EXPORT = qw(has new extends before after around);
local $SIG{__DIE__} = \&Carp::confess;

my %attr;
my %inst;

sub has {
    my $field = shift;
    my $self = caller;

    die "field $field already exists" if ($attr{$self}{$field});
    die "incorrect args\n" if (ref $field || @_ % 2 || !@_ || !($field =~ /^[_a-zA-Z]\w*$/));
    my %params = @_;
    $attr{$self}{$field} = \%params;

    no strict 'refs';
    if ($params{lazy_build}) {
        $attr{$self}{$field}{lazy} = 1;
        $attr{$self}{$field}{builder} = "_build_$field";
        $attr{$self}{$field}{clearer} = "clear_$field";
        *{"${self}::clear_${field}"} = sub { delete $_[0]->{$field} };
        $attr{$self}{$field}{predicate} = "has_$field";
        *{"${self}::has_${field}"} = sub { exists ($_[0]->{$field}) ? 1 : 0};
    }

    *{"${self}::$field"} = sub {
        my ($self, $val) = @_;
        my $package = ref $self;
        my $builder = $attr{$package}{$field}{builder};
        my $predicate = $attr{$package}{$field}{predicate};

        $self->{$field} = $self->$builder() if ($attr{$package}{$field}{lazy} && ! $self->$predicate());
        die "attr $field is bare\n" if ($attr{$package}{$field}{is} eq "bare");
        die "attr $field is immutable\n" if (@_ > 1 && $attr{$package}{$field}{is} ne "rw");
        $self->{$field} = $val if (@_ > 1);

        return $self->{$field};
    }

}

sub extends {
    die "parent name must be SCALAR\n" if (ref $_[0] || @_ > 1);
    my $parent = $_[0];
    my $package = caller;

    no strict 'refs';
    eval "require $parent";
    die "cant compile $parent\n" if ($@);
    @{"${package}::ISA"} = ($parent);

    my @attr = keys %{$attr{$parent}};
    for (@attr) {
        $attr{$package}{$_} = $attr{$parent}{$_};
    }
}

sub new {
    my $self = shift;
    die "parameter must be hash or hashref\n" unless ((!ref $_[0] && !(@_ % 2)) || ref $_[0] eq "HASH");

    my %params = ref $_[0] eq "HASH" ? %{$_[0]} : @_;
    for my $key (keys %params) {
        die "unexpected $key\n" if (!defined $key || !defined $attr{$self}{$key});
    }

    my @required = grep {$attr{$self}{$_}{required}} keys %{$attr{$self}};
    for (@required) {
        die "$_ is required at $self\n" if (!exists $params{$_} && !$attr{$self}{$_}{lazy});
    }
    
    return $inst{$self} = bless \%params, $self;
}

sub before {
    die "first argument must be scalar, second - sub" if (ref $_[0] or ref $_[1] ne "CODE");
    my ($name, $before_sub) = @_;
    my $package = caller;
    no strict 'refs';
    my $func = $package->can($name);
    die "no such function ${package}::${name}" unless ($func);
    *{"${package}::$name"} = sub {
        $before_sub->($package);
        return $func->(@_);
    }
}

sub after {
    die "first argument must be scalar, second - sub" if (ref $_[0] or ref $_[1] ne "CODE");
    my ($name, $after_sub) = @_;
    my $package = caller;
    no strict 'refs';
    my $func = $package->can($name);
    die "no such function ${package}::${name}" unless ($func);
    *{$package . "::" . $name} = sub {
        my $ret = $func->(@_);
        $after_sub->($package);
        return $ret;
    }
}

sub around {
    die "first argument must be scalar, second - sub" if (ref $_[0] or ref $_[1] ne "CODE");
    my ($name, $around_sub) = @_;
    my $package = caller;
    no strict 'refs';
    my $func = $package->can($name);
    die "no such function ${package}::${name}" unless ($func);
    *{"${package}::$name"} = sub {
        shift @_;
        return $around_sub->($func, $package, @_);
    }
}

1;