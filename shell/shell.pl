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
    print color('bold green') . "[▲ " . color('bold white') . cwd() . color('bold green'). "]\$ ". color('reset');
    my $input = <STDIN>;
    chomp $input;
    next unless (defined $input && $input ne "");
    process($input);
}


sub process {
    my @commands = split /(?<!["'\\])[|](?!["'])/, $_[0];
    my ($child_in, $child_in_w);
    pipe($child_in, $child_in_w);
    my ($child_out, $child_out_w);
    pipe($child_out, $child_out_w);

    my @pids;

    for my $i (0..$#commands) {
        $child_in = 0 if ($i == 0);
        $child_out_w = 0 if ($i == $#commands);

        if ($UTILS{(split / /, $commands[$i])[0] }) {
            $UTILS{(split / /, $commands[$i])[0] }($commands[$i], $child_in, $child_out_w);
        } else {
            push @pids, fork_exec($commands[$i], $child_in, $child_out_w);
        }

        $child_in = $child_out;
        undef $child_out;
        undef $child_out_w;
        pipe ($child_out, $child_out_w);
    }
    waitpid $_, 0 for (@pids);

    close $child_in_w;
}

sub fork_exec {
    my ($cmd, $child_in, $child_out_w) = @_;
    my $pid = fork();
    if ($pid){
        return $pid;
    } else {
        open(STDOUT, ">&", $child_out_w) if ($child_out_w);
        open(STDIN, '<&', $child_in) if ($child_in);
        exec($cmd) || die "exec failed";
    }
}

sub cd {
    my $dir = (split / /, shift)[1];
    unless (-d $dir) {
        warn "dir $dir not exists\n";
    } else {
        chdir("$dir");
    }
}

sub pwd {
    my $child_out_w = $_[2];
    if ($child_out_w) {
        print {$child_out_w} cwd();
    } else {
        print cwd() . "\n";
    }
}

sub echo {
    my @echo = (split / /, $_[0]);
    shift @echo;
    my $child_out_w = $_[2];
    if ($child_out_w) {
        print {$child_out_w} join " ", @echo;
    } else {
        print join(" ", @echo) , "\n";
    }
}

sub kill_{
    my @params = split /[- ]/, $_[0];
    warn "process not found\n" unless (kill $params[-2], $params[-1]);
}
