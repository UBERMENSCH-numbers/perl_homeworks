use Test::More;
use Test::Exception;
use lib "/home/user/v.kotelnik/meowse/lib";
use Class;

subtest new => sub {
    lives_ok { Class->new(rw_req => "test", ro_req => "test", bare_req => "test") } "expected to live hash";
    dies_ok { Class->new(rw_req => "test", ro_req => "test", bare_req => "test", something => "test") } "expected to die unexpected";
    my $hashref = { rw_req => "test", ro_req => "test", bare_req => "test", something => "test" };
    dies_ok { Class->new($hashref) } "expected to die unexpected hasref";
    $hashref = { rw_req => "test", ro_req => "test", bare_req => "test"};
    lives_ok { Class->new($hashref) } "expected to live hashref";
    dies_ok { Class->new([1,2,3,4]) } "dies on arrayref";
    dies_ok { Class->new( sub { return "HELLP"} ) } "dies on sub";
    dies_ok { Class->new( 1 ) } "dies on scalar";
};

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
    my $hash = {rw_req => "test", ro_req => "test", bare_req => "test"};
    my $obj = Class->new($hash);
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

subtest lazy_build => sub {
    my $obj = Class->new(rw_req => "test", ro_req => "test", bare_req => "test");
    is($obj->has_lazy_not_req, 0, "has_attr works1");
    is($obj->lazy_not_req, $obj->_build_lazy_not_req, "lazy_not_req calc1");
    is($obj->has_lazy_not_req, 1, "has_attr works2");
    $obj->clear_lazy_not_req;
    is($obj->has_lazy_not_req, 0, "has_attr works3");
    is($obj->lazy_not_req, $obj->_build_lazy_not_req, "lazy_not_req calc2");
    $obj->lazy_not_req("test");
    is($obj->lazy_not_req, "test", "set of lazy attr");
    is($obj->has_lazy_req, 0, "has_attr works4");
    is($obj->lazy_req, $obj->_build_lazy_req, "lazy_req calc1");
    $obj->clear_lazy_req;
    is($obj->has_lazy_req, 0, "has_attr works5");
    $obj->lazy_req(10);
    $obj->lazy_req(undef);
    is($obj->has_lazy_req, 1, "has_attr on undef1");
    $obj->clear_lazy_req;
    is($obj->has_lazy_req, 0, "has_attr on undef2");
};

subtest before_after_around => sub {
    my $obj = Class->new(rw_req => "test", ro_req => "test", bare_req => "test");
    $obj->before_rw_req;
    is($obj->rw_req, 10, "after after_modified");
    is($obj->parent_sub_override, "parent_sub_override_in_childs", "check correct method called1");
    is($obj->before_rw_req, "after_parent_sub_override", "check field modified1");
    is($obj->parent_sub, "parent_sub", "check correct method called2");
    is($obj->before_rw_req, "after_parent_sub", "check field modified2");
    is($obj->multiply_2(2), 4, "check around1");
    is($obj->multiply_2([1,2,3,4]), "arg must be scalar", "check around2");

};

done_testing();

