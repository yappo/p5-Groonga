package Groonga::PatriciaTrie;
use strict;
use warnings;

1;
__END__

=head1 NAME

Groonga::PatriciaTrie - Groonga patricia operator

=head1 SYNOPSIS

  use Groonga;
  use Groonga::Constants;
  use Groonga::PatriciaTrie;

  my $path = '/for/bar/baz.db';
  my $pat = Groonga::PatriciaTrie->new;
  if (! $pat->open($path)) {
      $pat->create($path) or die 'Groonga::PatriciaTrie create error';
  }

  $pat->add('yappo', 'hello');
  say $pat->get('yappo'); # hello
  if ($pat->delete('yappo') != GRN_SUCCESS) {
      die 'delete error';
  }

  if ($pat->close != GRN_SUCCESS) {
      die 'close error';
  }
  if ($pat->remove($path) != GRN_SUCCESS) { # delete /for/bar/baz.db
      die 'remove error';
  }

useing scan method

  my $path = '/for/bar/baz.db';
  my $pat = Groonga::PatriciaTrie->new;
  $pat->create($path, $key_size, $value_size, GRN_OBJ_KEY_VAR_SIZE) or die 'Groonga::PatriciaTrie create error';

  $pat->add('yappo', 'hello');
  $pat->add('nekokak', 'good');

  my $text = 'nekokak with yappon';
  $pat->scan($text, sub {
      my($record, $dict_term, $offset, $length) = @_;
  };

=head1 DESCRIPTION

Groonga is 

=head1 METHODS

=over 4

=item my $pat = Groonga::PatriciaTrie->new() : Groonga::PatriciaTrie

Get Groonga::PatriciaTrie instance.

=item $pat->create($path, $key_size=0x1000, $value_size=0x1000, $flags=0) : Bool

Create Groonga patricia file.

=item $pat->create($path) : Bool

Open Groonga patricia file.

=item $pat->close() : grn_rc

Close Groonga patricia handle.

=item $pat->remove($path) : grn_rc

Delete Groonga patricia file.

=item my($record_id, $is_new_record) = $pat->add($key, $value) : Array

Add key/value to Groonga patricia file.

=item my($value, $record_id) = $pat->add($key) : Array

Retrieves a key from the Groonga patricia file.

=item $pat->delete($key) : grn_rc

Delete a key.

=item $pat->scan($text, $callback) : void

Retrieves a $text from the Groonga patricia dict.
moust set flags GRN_OBJ_KEY_VAR_SIZE the create method.

  $pat->create($path, $key_size, $value_size, GRN_OBJ_KEY_VAR_SIZE) or die 'Groonga::PatriciaTrie create error';

  $pat->add('yappo', 'hello');
  $pat->add('nekokak', 'good');

  my $text = 'nekokak with yappon';
  $pat->scan($text, sub {
      my($record, $dict_term, $offset, $length) = @_;
      say "$record, $dict_term, $offset, $length";
      # nekokak, nekokak, 0, 7
      # yappo, yappo, 13, 5
  };

=back

=head1 AUTHOR

Kazuhiro Osawa E<lt>yappo {at} shibuya {dot} plE<gt>

=head1 SEE ALSO

L<Groonga>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
