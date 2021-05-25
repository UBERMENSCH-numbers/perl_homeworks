package Model;

use DBI;
use strict;
use warnings;
use feature 'say';
 
my $dbh = DBI->connect("dbi:SQLite:dbname=lib/notes.db","",""); 

sub register_user {
    shift;
    my ($login, $password) = @_;
    if ($dbh->selectrow_array("SELECT count(*) FROM users WHERE login = '$login'")) {
        return 0;
    } else {
        $dbh->do("INSERT INTO users VALUES ('$login', '$password')");
        return 1;
    }
}

sub login_user {
    shift;
    my ($login, $password) = @_;
    if ($dbh->selectrow_array("SELECT count(*) FROM users WHERE login = '$login' AND password = '$password'")) {
        return 1;
    }
    return 0;
}

sub new_note {
    shift;
    my ($title, $text, $user) = @_;
    $dbh->do("INSERT INTO notes(title, text, user) values('$title', '$text', '$user')");
    return $dbh->selectrow_array("SELECT last_insert_rowid() FROM notes");

}

sub add_share {
    shift;
    my ($id, $user) = @_;
    $dbh->do("INSERT INTO share VALUES('$id','$user')");
}

sub edit_note {
    shift;
    my ($id, $title, $text, $user) = @_;
    $dbh->do(
        "UPDATE notes
        set title = '$title',
            text = '$text'
        WHERE id = $id");
}

sub edit_share {
    shift;
    my ($id, $user) = @_;
    $dbh->do("UPDATE share set VALUES('$id','$user')");
}

sub new {
    my $self = shift;
    my %params = @_;
    return bless \%params, $self;
}
