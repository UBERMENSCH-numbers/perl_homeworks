use strict;
use warnings;
use IO::Socket;
use Getopt::Long;

$| = 1;

my ($tcp, $udp);
GetOptions('tcp' => \$tcp, 'udp' => \$udp);
my $proto = defined $udp ? "udp" : "tcp";

my $port = (grep {/\d{1,6}/} @ARGV)[0];
my $host = (grep {$_ ne $port} @ARGV)[0];

my @input = <STDIN>;

my $socket = IO::Socket::INET->new(
    PeerAddr => $host,
    PeerPort => $port,
    Proto => $proto,
    Type => SOCK_STREAM
) or die "Can't connect to $host $/";

print {$socket} join "", @input;
