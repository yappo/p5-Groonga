use inc::Module::Install;
name 'Groonga';
all_from 'lib/Groonga.pm';
readme_from 'lib/Groonga.pm';
readme_markdown_from 'lib/Groonga.pm';
githubmeta;

# requires '';

tests 't/*.t';
author_tests 'xt';

build_requires 'Test::More';
auto_set_repository;
auto_include;
WriteAll;
