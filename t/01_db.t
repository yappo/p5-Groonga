use strict;
use warnings;
use Test::More;
use File::Temp;
use Groonga;

my $db = Groonga::DB->new();
isa_ok $db, 'Groonga::DB';
ok($db->create(undef));

subtest 'create and open' => sub {
    my $db1 = Groonga::DB->new();
    my $path = tmpnam();
    ok($db1->create($path));
    ok(-f $path);

    my $db2 = Groonga::DB->new();
    ok($db2->open($path));
};

done_testing;

