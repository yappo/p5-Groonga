use inc::Module::Install;
name 'Groonga';
all_from 'lib/Groonga.pm';
readme_from 'lib/Groonga.pm';
readme_markdown_from 'lib/Groonga.pm';
githubmeta;

# requires '';

use_ppport;
use_xshelper;
cc_warnings;
cc_src_paths qw(xs);

$ENV{INCLUDES} = '/usr/local/groonga/include/groonga';
if ($ENV{INCLUDES}) {
    cc_include_paths split/\s+/, $ENV{INCLUDES};
}
$ENV{LIBS} = '-L/usr/local/groonga/lib';
if ($ENV{LIBS}) {
    cc_libs $ENV{LIBS};
}

cc_libs 'groonga';

tests 't/*.t';
author_tests 'xt';

build_requires 'Test::More';
auto_set_repository;
auto_include;
WriteAll;
