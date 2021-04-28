use strict;
use warnings;
use Cwd qw(cwd);
use Data::Dumper;
use feature 'say';

my @commands = split '\|',  $ARGV[0];
my @results;

my $prev;
for my $i (0..$#commands) {
    my @items = split " ", $commands[$i];
    print Dumper(\@items);
    if ($items[$i] eq "cd") {
        cd(@items);
        next;
    } elsif ($items[$i] eq "pwd") {
        $results[$i] = pwd();
        next;
    } elsif ($items[$i] eq "echo") {
        $results[$i] = echo(@items);
        next;
    } elsif ($items[$i] eq "kill") {
        kill_(@items);
        next
    } else {
        if (defined $prev) {
            $results[$i] = `$prev | $commands[$i]`;
        } else {
            $results[$i] = `$commands[$i]`;
        }
    }
    $prev = $results[$i];
}

print Dumper(\@results);


sub cd {
    unless (-d $_[1]) {
        die "dir $_[1] not exists";
    } else {
        chdir("$_[1]") ;
    }
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
    kill $sig, shift;
}

my $child_pid;
if (!defined($child_pid = fork())) {
  die "cannot fork: $!";

} elsif ($child_pid) {
    say "---parent---";
} else {
    say "---child---";
}