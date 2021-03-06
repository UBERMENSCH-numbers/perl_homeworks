package notes;
use Dancer2;
use strict;
use warnings;
use utf8;
use Model;
use Template;

our $VERSION = '0.1';
my $model = Model->new();

any ['get', 'post'] => '/login' => sub {
    if (request->method() eq "POST") {
        my $username = body_parameters->get('username');
        my $password = body_parameters->get('password');
        if ($model->login_user($username, $password)) {
            session 'logged_in' => true;
            session 'user' => $username;
            redirect param('path') || '/';
        }
    }
    template 'login';
};

any ['get', 'post'] => '/register' => sub {
    if (request->method() eq "POST") {
        my $username = body_parameters->get('username');
        my $password = body_parameters->get('password');
        if ($model->register_user($username, $password)) {
            session 'logged_in' => true;
            session 'user' => $username;
            redirect param('path') || '/';
        }
    }
    template 'register';
};

get '/logout' => sub {
    app->destroy_session;
    redirect '/login';
};

hook before => sub {
    if (!session('user') && request->path_info !~ m{^/login} && request->path_info !~ m{^/register}) {
        redirect '/login?path='.request->path_info;
    }
};

post '/delete_note' => sub {
    $model->delete_note(query_parameters->get('id'));
    redirect '/';
};

get '/' => sub {
    my $username = session('user');
    my $notes = $model->get_user_notes($username);
    my $share = $model->get_shared_by_user($username);
    my %notes;
    for (@{$notes}) {
        my ($id, $title) = @{$_};
        $notes{$id} = $title;
    }
    my %shared;
    for (@{$share}) {
        my ($title, $id, $user) = @{$_};
        $shared{$id} = [$title, $user];
    }
    template 'main', {
        notes => \%notes,
        notes_shared => \%shared,
        username => $username
    };
};

any ['get', 'post'] => '/note' => sub {
    my $id = query_parameters->get('id');
    my $username = session('user');

    if (request->method() eq "POST") {
        my $text = body_parameters->get('note_text');
        my $title = body_parameters->get('note_title');
        my @users = split ",", body_parameters->get('note_share');
        $model->edit_note($id, $title, $text);
        $_ =~ s/\s+//g for (@users);
        $model->edit_share($id, \@users);
        redirect '/';
    }

    my $note = $model->get_note($id);
    redirect '/' unless $note;
    my $readonly = $username ne $note->{user};
    my $share = join ",", @{$model->get_share($id)};

    template 'note', {
        note_title => $note->{title},
        note_text => $note->{text},
        note_share => $share,
        readonly => $readonly,
    };
};

any ['get', 'post'] => '/new_note' => sub {
    if (request->method() eq "POST") {
        my $username = session('user');
        my $text = body_parameters->get('note_text');
        my $title = body_parameters->get('note_title');
        my @users = split ",", body_parameters->get('note_share');
        my $inserted_id = $model->new_note($title, $text, $username);
        for (@users) {
            $_ =~ s/\s+//g;
            $model->add_share($inserted_id, $_);
        }
        redirect '/';
    }
    template 'note', { 
        placeholder => 1,
    };
};

1;