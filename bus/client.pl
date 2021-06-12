use strict;
use warnings;

use AnyEvent;
use AnyEvent::Socket;
use AnyEvent::Handle;

my $address = '127.0.0.1';
my $port = 8898;
my $hdl;

my $cv = AnyEvent->condvar();

my $cb_say = sub {
	print "Server say: $_[1]";
	$cv->send();
};

my $say_name = sub {
    print(@_);
    print 1;
	# $hdl->push_write("MSG\n");
	# $hdl->push_read(regex => qr/:/, $cb_say);
};

tcp_connect $address, $port, sub {
	my ($fh) = @_;
	$hdl = AnyEvent::Handle->new(fh => $fh);
	$hdl->push_read(regex => qr/:/, $say_name);
};

$cv->recv();
