use strict;
use warnings;
use Test::More;
use Groonga;
use Groonga::Constants;

is(GRN_SUCCESS, 0);
is(GRN_END_OF_DATA, 1);
is(GRN_UNKNOWN_ERROR, -1);
is(GRN_TRUE, 1);
is(GRN_FALSE, 0);

done_testing;
