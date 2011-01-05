#!/usr/bin/env perl
# copied from http://search.cpan.org/src/DMAKI/ZeroMQ-0.02_05/tools/genfiles.pl
use strict;
use File::Spec;

write_constants_file( File::Spec->catfile('xs', 'const-xs.inc') );

sub write_constants_file {
    my $file = shift;

    my $header = $ENV{GROONGA_H} || do {
        my $cflags = `pkg-config --cflags groonga`;
        $cflags =~ s/\-I//;
        $cflags =~ s/\s//g;
        "$cflags/groonga.h";
    };

    open( my $in, '<', $header ) or
        die "Could not open file $header for reading: $!";

    open( my $out, '>', $file ) or
        die "Could not open file $file for writing: $!";
    print $out
        "# Do NOT edit this file! This file was automatically generated\n",
        "# by Makefile.PL on @{[scalar localtime]}. If you want to\n",
        "# regenerate it, remove this file and re-run Makefile.PL\n",
        "\n",
        "IV\n",
        "_constant()\n",
        "    ALIAS:\n",
    ;

    my %cache = map { $_ => 1 } qw(
        GRN_API
        GRN_INT64_SET GRN_INT64_VALUE GRN_QUERY_ADJ_POS2 GRN_INT64_VALUE_AT
        GRN_INT64_PUT GRN_VALUE_FIX_SIZE_INIT GRN_QUERY_ADJ_POS1 GRN_INT64_SET_AT
        GRN_TIME_SET GRN_TIME_VALUE GRN_TIME_VALUE_AT GRN_TIME_PUT
        GRN_RECORD_INIT GRN_TIME_SET_AT
    );
    while (my $ln = <$in>) {
        if ($ln =~ /\s(GRN_[A-Z0-9_]+)\s/) {
            next if $cache{$1}++;
            print $out "        $1 = $1\n";
        }
    }
    close $in;
    print $out        "    CODE:\n",
        "        RETVAL = ix;\n",
        "    OUTPUT:\n",
        "        RETVAL\n"
    ;
    close $out;
}
