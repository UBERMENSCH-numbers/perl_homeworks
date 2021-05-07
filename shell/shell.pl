use strict;
use warnings;
use Cwd qw(cwd);
use feature 'say';
use Term::ANSIColor 'color';

$|=1;
my %UTILS;

%UTILS = (
    "cd" => \&cd,
    "pwd" => \&pwd,
    "echo" => \&echo,
    "kill" => \&kill_,
);

while (1) {
    print color('bold green') . "[▲ " . color('bold white') . pwd() . color('bold green'). "]\$ ". color('reset');
    my $input = <STDIN>;
    chomp $input;

    next unless (defined $input && $input ne "");

    my $output = process($input);
    if (defined $output) {
        chomp $output;
        say $output;
    }
}


sub process {
    my @commands = split /\Q|\E/, $_[0];
    my ($output, $input) = (1, 1);

    for my $i (0..$#commands) {
        my @items = split " ", $commands[$i];
        if (defined $UTILS{$items[0]}) {
            if ($i < $#commands) {
                $input = $UTILS{$items[0]}(@items);
            } else {
                return $UTILS{$items[0]}(@items);
            }
        } else {
            if ($i == 0 && $#commands != 0) {
                $input = fork_exec($commands[$i], undef, $output);
            } elsif ($i != 0 && $i == $#commands) {
                return fork_exec($commands[$i], $input, undef);
            } elsif ($i != 0 && $i != $#commands) {
                $input = fork_exec($commands[$i], $input, $output);
            } else {
                return fork_exec($commands[$i], undef, undef);
            }
        }  
    }      
}

sub fork_exec {
    my ($command, $input, $output) = @_;
    my $pid;
    if (defined $output) {
        die "could not fork\n" unless defined($pid = open(CHILD, "-|"));
    } else {
        die "could not fork\n" unless defined($pid = fork());
    }

    if ($pid) {
        waitpid $pid, 0;
        if (defined $output) {
            my @out = <CHILD>;
            close(CHILD);
            return join "", @out
        }
        return undef;
    } elsif ($pid == 0) {
        exec("echo '$input' | $command") if (defined $input);
        exec($command);
    }
}

sub cd {
    unless (-d $_[1]) {
        warn "dir $_[1] not exists\n";
    } else {
        chdir("$_[1]") ;
    }
    return undef;
}

sub pwd {
    return cwd();
}

sub echo {
    shift;
    return join " ", @_;
}

sub kill_{
    shift;
    my $sig = shift =~ tr/-//;
    warn "process not found\n" unless (kill $sig, shift);
    return undef;
}
