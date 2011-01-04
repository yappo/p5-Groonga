use strict;
use Test::More tests => 1;

BEGIN { use_ok 'Groonga' }
diag Groonga->get_package() .  " : " . Groonga->get_version();

