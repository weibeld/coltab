package Weibeld::Coltab::ParseManager;

use strict;
use warnings;
use Carp;
use Exporter qw(import);
use Weibeld::Coltab::HTMLManager qw(add_header start_new_table add_table_row);

our(@EXPORT_OK, $VERSION);

$VERSION = "0.01";
@EXPORT_OK = qw(parse_file);

# /^[*+-]\s+`?\#?([a-f0-9]{3}|[a-f0-9]{6})`?\s*$/i

my $is_open_list;
my $callbacks;

sub parse_file {
    my $file = shift;
    $callbacks = shift;
    $is_open_list = 0;

    # Loop through all the lines of the file
    open(my $f, '<', $file) or croak "Can't open file $file for reading: $!";
    while (<$f>) {
        # Test if line is a list item
        if (my $item = _parse_list_item($_)) {
            $callbacks->{on_list_item_found}->($item);
            $is_open_list = 1 if ($is_open_list == 0);
            next;
        # If line is not a list item, test if an ongoing list is interrupted
        } else {
            _interrupt_list();
        }
        # Test if line is a header
        if (my $h = _parse_header($_)) {
            $callbacks->{on_header_found}->($h->{content}, $h->{level});
            next;
        }
    }

    # Test if EOF is ending an ongoing list
    _interrupt_list();
}

sub _interrupt_list {
    if ($is_open_list) {
        $callbacks->{on_list_interrupted}->();
        $is_open_list = 0;
    }
}

sub _parse_list_item {
    my $line = shift;
    return $1 if ($line =~ /^[*+-]\s+(.*)$/);
}

sub _parse_header {
    my $line = shift;
    for my $i (1 .. 6) {
        my $pat = "^" . "#"x$i . "\\s+(.*)\$";
        if ($line =~ /$pat/) {
            my %hash = (level => $i, content => $1);
            return \%hash;
        }
    }
}

1;

__END__

=head1 NAME

Weibeld::Coltab::ParseManager - parse the input Markdown file of the B<coltab> application

=head1 SYNOPSIS

    use Weibeld::Coltab::ParseManager qw(parse_file);

    parse_file("filename");

=head1 DESCRIPTION

This module parses the Markdown input file of the B<coltab> application for headers and bullet-point list items and instructs the Weibeld::Coltab::HTMLManager module to add a corresponding element to the output HTML file.

In particular, for each header encountered in the input file, the module instructs Weibeld::Coltab::HTMLManager to add a corresponding HTML header to the HTML tree, and for each encountered list item, the module instructs Weibeld::Coltab::HTMLManager to add a table row to the HTML tree.

=head1 FUNCTIONS

=over 4

=item parse_file

Parses the input file as described in L</DESCRIPTION>.

The C<parse_file> function takes a single argument, which must be a relative or absolute filename of a Markdown file.

The function returns an undefined value in any case.

=back

=head1 AUTHOR

Daniel Weibel <L<info@weibeld.net|mailto:info@weibeld.net>>

=head1 SEE ALSO

Weibeld::Coltab::HTMLManager

=head1 LICENSE

Copyright 2017 Daniel Weibel

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
