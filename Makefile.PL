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

system("pkg-config --exists groonga")==0
	or do {
		print STDERR "missing groonga library\n";
		exit;
	};

tests 't/*.t';
author_tests 'xt';

build_requires 'Test::More';
auto_set_repository;
makemaker_args(
    CCFLAGS => `pkg-config --cflags groonga`,
    LIBS    => `pkg-config --libs groonga`,
);
WriteAll();
