use Test::More;
use Test::Exception;
use lib "/home/user/v.kotelnik/meowse/lib";
use Class;

subtest required_attr => sub {
    lives_ok { Class->new(rw_req => "test", ro_req => "test", bare_req => "test") } "expected to live1";
    lives_ok { Class->new(rw_req => "test", ro_req => "test", bare_req => "test", rw_not_req => "test", ro_not_req => "test", bare_not_req => "test") } "expected to live2";
    dies_ok { Class->new(rw_req => "test", ro_req => "test") } "expected to die1";
    dies_ok { Class->new() } "expected to die2";
    dies_ok { Class->new(rw_req => "test", ro_req => "test", rw_not_req => "test", ro_not_req => "test") } "expected to die3";
};

subtest is_attr => sub {
    lives_ok { Class->new(rw_req => "test", ro_req => "test", bare_req => "test")->rw_req } "get rw attr";
    lives_ok { Class->new(rw_req => "test", ro_req => "test", bare_req => "test")->ro_req } "get ro attr";
    dies_ok { Class->new(rw_req => "test", ro_req => "test", bare_req => "test")->bare_req } "get bare attr";
    lives_ok { Class->new(rw_req => "test", ro_req => "test", bare_req => "test")->rw_req("test") } "set rw attr";
    dies_ok { Class->new(rw_req => "test", ro_req => "test", bare_req => "test")->ro_req("test") } "set ro attr";
    dies_ok { Class->new(rw_req => "test", ro_req => "test", bare_req => "test")->bare_req("test") } "set bare attr";
};

subtest get_set_attr => sub {
    my $obj = Class->new(rw_req => "test", ro_req => "test", bare_req => "test");
    is($obj->rw_req, "test", "simple get1");
    is($obj->ro_req, "test", "simple get2");
    $obj->rw_req("test1");
    is($obj->rw_req, "test1", "simple set1");
    dies_ok{ $obj->something } "dies for unexpected attr1";
    dies_ok{ $obj->something(10) } "dies for unexpected attr2";
};

subtest extends_subs_attr => sub {
    my $obj = Class->new(rw_req => "test", ro_req => "test", bare_req => "test");
    lives_ok{ $obj->parent_sub } "subroutine from parent exists";
    is($obj->parent_sub, Parent::parent_sub(), "subroutine from parent correct");
    lives_ok{ $obj->parent_sub_override } "overriden subroutine exists";
    is($obj->parent_sub_override, Class::parent_sub_override, "overriden subroutine correct");
    $obj = Class->new(rw_req => "test", ro_req => "test", bare_req => "test", parent_attr => "parent_attr");
    is($obj->parent_attr, "parent_attr", "field from parent correct");
    $obj->parent_attr("parent_attr1");
    is($obj->parent_attr, "parent_attr1", "modified field from parent correct");
};




# my $obj = Class->new(first_name => "test");
# is($obj->first_name, "test", 'first name get is ok');
# $obj->first_name("test1");
# is($obj->first_name, "test1", 'first name set is ok');

# dies_ok { Class->new(last_name => "test") } "required attr die";


