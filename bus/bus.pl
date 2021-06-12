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

my $address = '100.100.145.77';
my $listen_port = 8888;

my $cb_connect;
my $cb_feeder_msg;

my $cv = AnyEvent->condvar;

my $clients = {};
my $readers = {};
my $feeders = {};
my @msgs = ();

sub send_new {
    my $msg = shift;
    # print "-----------\n";
    # print Dumper($msg);
    # print Dumper($readers);
    # print Dumper($feeders);
    # print "-----------\n";
    for (keys %$readers) {
        if ($msg->{type} eq $readers->{$_}->{type}) {
            $readers->{$_}->{client}->push_write("New messsage:\n");
            $readers->{$_}->{client}->push_write(json => ($msg));
        }
    }
};

$cb_feeder_msg = sub {
    my ($client, $buf) = @_;
    if (!$buf->{type} || !$buf->{msg}) {
        $client->push_write("invalid format");
        return;
    }
    $buf->{feeder} = $feeders->{$client}{name};
    push @msgs, $buf;
    $client->push_write("Your message:\n");
    $client->push_write(json => ($buf));
    send_new($buf);
    $client->push_read(json => $cb_feeder_msg);
    # print Dumper(\@msgs);
    
};

$cb_connect = sub {
	my ($client, $buf) = @_;
	warn "Read from client\n". Dumper($buf);
    unless (ref $buf eq ref {} && $buf->{stream} && ($buf->{name} || $buf->{type})) {
        $client->push_write("Missed 'stream' or 'type'\n You leaved the Dark Side\n");
        $client->push_shutdown();
        return;
    }
    if ($buf->{stream} eq "in") {
        say "new feeder". Dumper($client) . "\n";
        %{$feeders->{$client}} = (client => $client, name => $buf->{name});
        $feeders->{$client}{client}->push_read(json => $cb_feeder_msg);
    } elsif($buf->{stream} eq "out") {
        say "new reader". Dumper($client) . "\n";
        %{$readers->{$client}} = (client => $client, type => $buf->{type});
        my @filtered = grep {$_->{type} eq $buf->{type}} @msgs;
        $readers->{$client}{client}->push_write("Your Type Messages:\n");
        $readers->{$client}{client}->push_write(json => \@filtered);
    }
};

my $cb_new_connection = sub {
	my ($client, $host, $port) = @_;
	my $hdl; $hdl = AnyEvent::Handle->new(
		fh => $client,
		on_error => sub {
            my (undef, $fatal, $msg) = @_;
            warn "error from socket: $msg";
            unless ($fatal) { 
                $hdl->push_write("Invalid JSON?\nYou leaved the Dark Side\n");
                $hdl->destroy;
            }
            warn $hdl;
            $hdl = undef;
            close($client);
        },
	);
	warn "New connection in $host:$port from client $client";
    $hdl->push_write($ascii);
    $clients->{$client} = $hdl;
	$hdl->push_read(json => $cb_connect);
    return;
};

tcp_server $address, $listen_port, $cb_new_connection;

$cv->recv;

