use strict;
use warnings;
use IO::Socket;
use feature 'say';

my @message = <STDIN>;
my $host = shift @ARGV;
my $port = shift @ARGV;

my $socket = IO::Socket::INET->new(
    PeerAddr => $host,
    PeerPort => $port,
    Proto => "tcp",
    Type => SOCK_STREAM
) or die "Can't connect to $host $/";

print {$socket} join "", @message;

while (<$socket>) {
    print $_;
} 
