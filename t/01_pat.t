use strict;
use warnings;
use Test::More;
use File::Temp qw( tempdir );
use File::Spec ();
use Groonga;
use Groonga::Constants;
use Groonga::PatriciaTrie;

my $dir      = tempdir( CLEANUP => 1 );
my $tmp_name = File::Spec->catfile($dir, 'test.db');

my $pat = Groonga::PatriciaTrie->new;
isa_ok($pat, 'Groonga::PatriciaTrie');

do {
    local $@;
    eval {
        $pat->close;
    };
    like $@, qr/^Cannot close context/;
};

ok(!$pat->open($tmp_name), 'empty file open');
ok(!-f $tmp_name, 'not create tmp file');

ok($pat->create($tmp_name, 1024, 1024, GRN_OBJ_KEY_VAR_SIZE), 'create'); # GRN_OBJ_KEY_VAR_SIZE is for scan test
ok(-f $tmp_name, 'created tmp file');

do {
    local $@;
    eval {
        $pat->create($tmp_name);
    };
    like $@, qr/^Cannot create context. please close this context./;

    local $@;
    eval {
        $pat->open($tmp_name);
    };
    like $@, qr/^Cannot create context. please close this context./;
};

is($pat->close, GRN_SUCCESS, 'close');
ok(!$pat->create($tmp_name), 'not create');
ok($pat->open($tmp_name), 'open');

my($id, $added) = $pat->add('yappo', 'hello');
is($id, 1);
is($added, 1);
($id, $added) = $pat->add('yappo', 'bye');
is($id, 1);
is($added, 0);
($id, $added) = $pat->add('nekokak', 'san');
is($id, 2);
is($added, 1);

my $value;
($value, $id) = $pat->get('yappo');
is($id, 1);
is($value, 'bye');
($value, $id) = $pat->get('nekokak');
is($id, 2);
is($value, 'san');

$pat->add('neko', 'kak');

my $text = 'nekokak with yappon';
my @results = (
    ['nekokak', 'nekokak',  0, 7, 2],
    ['yappo',     'yappo', 13, 5, 1],
);
my $i = 0;
$pat->scan($text, sub {
    is($_[0], $results[$i]->[0], 'record');
    is($_[1], $results[$i]->[1], 'term');
    is($_[2], $results[$i]->[2], 'offset');
    is($_[3], $results[$i]->[3], 'length');
    is($_[4], $results[$i]->[4], 'record_id');
    $i++;
});

is($pat->delete('yappo'), GRN_SUCCESS, 'delete yappo');
is($pat->delete('yappo'), GRN_INVALID_ARGUMENT, 'not delete yappo');
($id, $added) = $pat->add('yappo', 'k');
is($id, 4);
is($added, 1);
($value, $id) = $pat->get('yappo');
is($id, 4);
is($value, 'k');

is($pat->close, GRN_SUCCESS, 'close');

is($pat->remove($tmp_name), GRN_SUCCESS, 'remove');
ok(!-f $tmp_name, 'removed tmp file');


done_testing;
