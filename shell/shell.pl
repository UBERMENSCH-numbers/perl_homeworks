use strict;
use warnings;
use Cwd qw(cwd);

my @commands = split "|", @ARGV;
my @results;

for my $i (0..@commands) {
    my @items = split " ", $commands[$i];
    my $prev = "";
    if ($items[0] eq "cd") {
        next;
    } elsif ($items[0] eq "pwd") {
        $results[$i] = pwd();
        next;
    } elsif ($items[0] eq "echo") {
        $results[$i] = echo(@items);
        next;
    } elsif ($items[0] eq "kill") {
        $results[$i] = kill_(@items);
        next
    } else {
        $prev = $results[$i - 1] if ($i > 0);
        $results[$i] = `$prev | $commands[$i]`;
    }
    
}

sub cd {
    if (-d $_[1]) {
        die "dir $_[1] already exists";
    } else {
        mkdir $_[1];
    }
}

sub pwd {
    return cwd;
}

sub echo {
    shift;
    return join " ", @_;
}

sub kill_{
    kill shift, @_;
}