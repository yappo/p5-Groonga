use strict;
use warnings;
use Test::More;
use File::Temp qw( tempdir );
use File::Spec ();
use Groonga;

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

ok($pat->create($tmp_name), 'create');
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

ok($pat->close, 'close');
ok(!$pat->create($tmp_name), 'not create');
ok($pat->open($tmp_name), 'open');

ok($pat->close, 'close');

ok($pat->remove($tmp_name), 'remove');
ok(!-f $tmp_name, 'removed tmp file');


done_testing;
