use strict;
use warnings;
use Test::More;
use Groonga;

my $db = Groonga::DB->new();
isa_ok $db, 'Groonga::DB';
     $db->create(undef) or die "cannot create db";

done_testing;

