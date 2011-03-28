package Groonga;
use strict;
use warnings;
our $VERSION = '0.01';

use XS::Object::Magic; 
use XSLoader;
XSLoader::load(__PACKAGE__);

1;
__END__

=head1 NAME

Groonga -

=head1 SYNOPSIS

  use Groonga;

=head1 DESCRIPTION

Groonga is

=head1 METHODS

=over 4

=item my $version = Groonga->get_version() : Str

Get the version number of groonga library.

=item my $package = Groonga->get_package() : Str

Get the package name of groonga library.

=back

=head1 AUTHOR

Kazuhiro Osawa E<lt>yappo {at} shibuya {dot} plE<gt>

=head1 SEE ALSO

L<http://groonga.org/>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
