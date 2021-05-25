package notes;
use Dancer2;
use Dancer2::Plugin::Database;
use strict;
use warnings;
use feature 'say';
use Model;
use Template;

set 'session' => 'Simple';
# set 'template' => 'template_toolkit';

our $VERSION = '0.1';
my $model = Model->new();

any ['get', 'post'] => '/new_note' => sub {
    if ( not session('logged_in') ) {
        redirect '/login';
    } elsif (request->method() eq "POST") {
        my $username = session('user');
        my $text = body_parameters->get('note_text');
        my $title = body_parameters->get('note_title');
        my @users = split ",", body_parameters->get('note_share');
        my $inserted_id = $model->new_note($title, $text, $username);
        for (@users) {
            $model->add_share($inserted_id, $_);
        }
    }
    template 'index';
};

get '/secret' => sub { return "Top Secret" };

any ['get', 'post'] => '/login' => sub {
    if ( request->method() eq "POST" ) {
        my $username = body_parameters->get('username');   
        my $password = body_parameters->get('password');
        if ($model->login_user($username, $password)) {
            session 'logged_in' => true;
            session 'user' => $username;
            return redirect '/new_note';
        }
    }
    template 'login';
};

any ['get', 'post'] => '/register' => sub {
    if ( request->method() eq "POST" ) {
        my $username = body_parameters->get('username');   
        my $password = body_parameters->get('password');
        if ($model->register_user($username, $password)) {
            session 'logged_in' => true;
            session 'user' => $username;
            return redirect '/new_note';
        }
    }
    template 'register';
};

1;
