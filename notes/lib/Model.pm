package Model;

use DBI;
use strict;
use warnings;
use Digest::MD5 'md5_hex';
 
my $dbh = DBI->connect("dbi:SQLite:dbname=../notes/notes.db","","",{ sqlite_unicode => 1 });

sub register_user {
    shift;
    my ($login, $password) = @_;
    if ($dbh->selectrow_array("SELECT count(*) FROM users WHERE login = ?", undef, $login)) {
        return 0;
    } else {
        $dbh->do("INSERT INTO users VALUES (?, ?)", undef, $login, $password);
        return 1;
    }
}

sub login_user {
    shift;
    my ($login, $password) = @_;
    if ($dbh->selectrow_array("SELECT count(*) FROM users WHERE login = ? AND password = ?", undef, $login, $password)) {
        return 1;
    }
    return 0;
}

sub new_note {
    shift;
    my ($title, $text, $user) = @_;
    my $id = md5_hex(rand());
    $dbh->do("INSERT INTO notes(id, title, text, user) values(?, ?, ?, ?)", undef, $id, $title, $text, $user);
    return $id;

}

sub add_share {
    shift;
    my ($id, $user) = @_;
    $dbh->do("INSERT INTO share VALUES(?, ?)", undef, $id, $user);
}

sub edit_note {
    shift;
    my ($id, $title, $text) = @_;
    use Data::Dumper;
    $dbh->do("
        UPDATE notes
        set title = ?,
            text = ?
        WHERE id = ?",
    undef, $title, $text, $id);
}

sub edit_share {
    shift;
    my $id = shift;
    my @users = @{+shift};
    
    $dbh->do("DELETE FROM share WHERE id = ?", undef, $id);
    $dbh->do("INSERT INTO share VALUES(?, ?)", undef, $id, $_) for @users;
}

sub get_user_notes {
    shift;
    my $user = shift;
    return $dbh->selectall_arrayref("SELECT id, title FROM notes WHERE user = ?", undef, $user);
}

sub get_note {
    shift;
    my $id = shift;
    return $dbh->selectrow_hashref("SELECT id, title, text, user FROM notes WHERE id = ?", undef, $id);
}

sub get_share {
    shift;
    my $id = shift;
    return $dbh->selectcol_arrayref("SELECT user FROM share WHERE id = ?", undef, $id);
}

sub get_shared_by_user {
    shift;
    my $user = shift;
    return $dbh->selectall_arrayref("
        SELECT title, id, user
        FROM notes
        WHERE id in (SELECT id from share WHERE user = ?)",
    undef, $user);
}

sub delete_note {
    shift;
    my $id = shift;
    $dbh->do("DELETE FROM notes WHERE id = ?", undef, $id);
}

sub new {
    my $self = shift;
    my %params = @_;
    return bless \%params, $self;
}