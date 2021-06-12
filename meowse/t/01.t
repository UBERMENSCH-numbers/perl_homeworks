
use Test::More;

use Class;

my $test_first_name = "test123";
my $obj = Class->new(first_name => $test_first_name);
is($obj->first_name, $test_first_name, 'firat name is ok');
