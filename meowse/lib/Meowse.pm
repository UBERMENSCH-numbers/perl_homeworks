package Meowse;

use strict;
use warnings;
use Data::Dumper;
use Exporter 'import';
use Scalar::Util qw(looks_like_number);
our @EXPORT = qw(has new extends __fields__);

my %attr;

sub has {
    my ($name, %params) = @_;
    $attr{$name} = \%params;
}

sub extends {
    my $parent = $_[0];
    my ($package, undef, undef) = caller;

    no strict 'refs';
    eval "require $parent";

    my @methods = grep { defined &{$parent . "::" . $_} && !defined  &{$package . "::" . $_}} keys %{$parent . "::"};
    for (@methods) {
        *{$package . "::" . $_} = \&{$parent . "::" . $_};
    }
    my ($key, $params) = &{$parent . "::__fields__"}; ## А это почему работает???!!
    $attr{$key} = $params;
    # print Dumper(\%{$parent . "::" . "attr"});
}

sub __fields__ {
    return %attr;
}

sub new {
    my ($self, %params) = @_;

    my @required = grep {$attr{$_}{required}} keys %attr;
    for (@required) {
        die "$_ is required at $self\n" if (!$params{$_} && !$attr{$_}{lazy}); ## как быть с required в родителе?
    }

    {
        no strict qw/refs/;
        for my $key (keys %params){
            my $name = $self . '::' . $key;
            *$name = sub {
                my ($self, $val) = @_;
                die "attr $key is bare\n" if ($attr{$key}{is} eq "bare"); ## Warn вместо die?
                die "attr $key is immutable\n" if (defined $val && $attr{$key}{is} ne "rw");
                $self->{$key} = $val if (defined $val);
                return $self->{$key}; ## Почему это работает?
            }
        }
    }

    # print Dumper(\%params);
    # print Dumper(\%attr);


    return bless \%params, $self;
    
}

1;