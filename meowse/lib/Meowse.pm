package Meowse;

use strict;
use warnings;
use Exporter 'import';
use feature 'say';
use Carp ();
our @EXPORT = qw(has new extends __fields__ before after around);
$SIG{__DIE__} = \&Carp::confess;

my %attr;
my $inst;

sub has {
    my $field = shift;
    die "incorrect args\n" if (ref \$field ne 'SCALAR' || @_ % 2 != 0 || @_ < 2);
    my %params = @_;
    $attr{$field} = \%params;
    my $self = caller;

    no strict 'refs';
    if ($params{lazy_build}) {
        $attr{$field}{lazy} = 1;
        $attr{$field}{builder} = "_build_$field";
        $attr{$field}{clearer} = "clear_$field";
        *{$self . "::clear_$field"} = sub { delete $_[0]->{$field} };
        $attr{$field}{predicate} = "has_$field";
        *{$self . "::has_$field"} = sub { defined ($_[0]->{$field}) ? 1 : 0};
    }

    my $sub = $self . '::' . $field;
    *$sub = sub {
        my ($self, $val) = @_;
        my $builder = $attr{$field}{builder};
        my $predicate = $attr{$field}{predicate};

        $self->{$field} = $self->$builder() if ($attr{$field}{lazy} && ! $self->$predicate());

        die "attr $field is bare\n" if ($attr{$field}{is} eq "bare");
        die "attr $field is immutable\n" if (defined $val && $attr{$field}{is} ne "rw");
        $self->{$field} = $val if (defined $val);

        return $self->{$field};
    }

}

sub extends {
    die "parent name must be SCALAR\n" if (ref \$_[0] ne "SCALAR" || @_ > 1);
    my $parent = $_[0];
    my ($package, undef, undef) = caller;

    no strict 'refs';
    eval "require $parent";

    my @methods = grep { defined &{$parent . "::" . $_} && !defined  &{$package . "::" . $_}} keys %{$parent . "::"};
    for (@methods) {
        *{$package . "::" . $_} = \&{$parent . "::" . $_};
    }
}

sub __fields__ {
    return %attr;
}

sub new {
    my $self = shift;

    die "parameter must be hash or hashref\n" unless ((ref \$_[0] eq "SCALAR" and @_ % 2 == 0) or ref $_[0] eq "HASH");
    my %params = ref $_[0] eq "HASH" ? %{$_[0]} : @_;

    for my $key (keys %params) {
        die "undexpected $key\n" if (!defined $attr{$key});
    }

    my @required = grep { $attr{$_}{required} } keys %attr;
    for (@required) {
        die "$_ is required at $self\n" if (!$params{$_} && !$attr{$_}{lazy});
    }
    return $inst = bless \%params, $self;
}

sub before {
    die "first argument must be scalar, second - sub" if (ref \$_[0] ne "SCALAR" or ref $_[1] ne "CODE");
    my ($name, $before_sub) = @_;
    my ($package, undef, undef) = caller;
    no strict 'refs';
    *{$package . "::_OLD_" . $name} = *{$package."::$name"}{CODE};
    *{$package . "::" . $name} = sub {
        &$before_sub($inst);
        return &{$package . "::_OLD_" . $name}(@_);
    }
}

sub after {
    die "first argument must be scalar, second - sub" if (ref \$_[0] ne "SCALAR" or ref $_[1] ne "CODE");
    my ($name, $after_sub) = @_;
    my ($package, undef, undef) = caller;
    no strict 'refs';
    *{$package . "::_OLD_" . $name} = *{$package."::$name"}{CODE};
    *{$package . "::" . $name} = sub {
        my $ret = &{$package . "::_OLD_" . $name}(@_);
        &$after_sub($inst);
        return $ret;
    }
}

sub around {
    die "first argument must be scalar, second - sub" if (ref \$_[0] ne "SCALAR" or ref $_[1] ne "CODE");
    my ($name, $around_sub) = @_;
    my ($package, undef, undef) = caller;
    no strict 'refs';
    *{$package . "::_OLD_" . $name} = *{$package."::$name"}{CODE};
    *{$package . "::" . $name} = sub {
        my $orig = \&{$package . "::_OLD_" . $name};
        shift @_;
        return &$around_sub($orig, $inst, @_);
    }
}

1;