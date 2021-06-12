my $ascii = '
        /\    ___---
 ------/  \---
 -----/    \---------
-----/      \---___
    /        \     ---
   /__________\
   You reached dark side
';

use strict;
use warnings;
use AnyEvent;
use AnyEvent::Socket;
use AnyEvent::Handle;
use Data::Dumper;
use feature 'say';
use utf8;

my $address = '100.100.147.21';
my $listen_port = 8888;
my $N_MSGS_POOL_SIZE = 50;

my $cb_connect;
my $cb_feeder_msg;

my $cv = AnyEvent->condvar;

my $clients = {};
my $readers = {};
my $feeders = {};
my @msgs = ();

sub send_new {
    my $msg = shift;
    for (keys %$readers) {
        if ($msg->{type} eq $readers->{$_}->{type}) {
            $readers->{$_}->{client}->push_write("New messsage:\n");
            $readers->{$_}->{client}->push_write(json => $msg);
        }
    }
};

sub on_error {
    my ($client, $fatal, $msg) = @_;
    my $client_str = "$client";
    my $key = "$client->{fh}";
    warn "error from socket $client : $msg";
    unless ($fatal) { 
        $clients->{$key}->push_write($msg);
    }
    close($client->{fh});
    $clients->{$key}->destroy;
    warn "destroyed $client";
    delete $clients->{$client_str};
    delete $feeders->{$client_str};
    delete $readers->{$client_str};
    print(Dumper($readers), Dumper($feeders));
}

$cb_feeder_msg = sub {
    my ($client, $buf) = @_;
    if (!$buf->{type} || !$buf->{msg}) {
        on_error($client, 1, "Invalid JSON?");
        return;
    }
    $buf->{feeder} = $feeders->{$client}{name};
    shift @msgs if ($#msgs >= $N_MSGS_POOL_SIZE - 1);
    push @msgs, $buf;
    $client->push_write("Your message:\n");
    $client->push_write(json => $buf);
    send_new($buf);
    $client->push_read(json => $cb_feeder_msg);
    # print Dumper(\@msgs);
};

my $HASH_REF_STR = ref {};

$cb_connect = sub {
	my ($client, $buf) = @_;
	warn "Read from client\n". Dumper($buf);
    unless (ref $buf eq $HASH_REF_STR && $buf->{stream} && ($buf->{name} || $buf->{type})) {
        $client->push_write("Missed 'name' or 'type'/'name' \n You leaved the Dark Side\n");
        $client->push_shutdown();
        return;
    }
    if ($buf->{stream} eq "in") {
        say "new feeder". Dumper("$client->{fh}");
        $feeders->{$client} = {client => $client, name => $buf->{name}};
        $feeders->{$client}{client}->push_read(json => $cb_feeder_msg);
    } elsif($buf->{stream} eq "out") {
        say "new reader". Dumper("$client->{fh}");
        $readers->{$client} = {client => $client, type => $buf->{type}};
        my @filtered = grep {$_->{type} eq $buf->{type}} @msgs;
        $readers->{$client}{client}->push_write("Your Type Messages:\n");
        $readers->{$client}{client}->push_write(json => $_) for @filtered;
        my $new_line_cnt = 1;
        my $reader_wd; $reader_wd = sub { 
            $readers->{$client}{client}->push_read(chunk => 1, sub {
                my ($fh, $data) = @_; 
                say "`" . $data . "`\n";
                if (!$data || !$new_line_cnt) {
                    on_error(@_);
                } else {
                    $reader_wd->();
                }
                $new_line_cnt-- if $data eq "\n";
            });
        };
        $reader_wd->();
        
    }
};

my $cb_new_connection = sub {
	my ($fh, $host, $port) = @_;
	$clients->{$fh} = AnyEvent::Handle->new(
		fh => $fh,
		on_error => \&on_error,
        on_eof => \&on_error,
	);
	warn "New connection in $host:$port from client $fh";
    $clients->{$fh}->push_write($ascii);
	$clients->{$fh}->push_read(json => $cb_connect);
    return;
};

tcp_server $address, $listen_port, $cb_new_connection;

$cv->recv;

