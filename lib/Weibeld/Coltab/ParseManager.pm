package Weibeld::Coltab::ParseManager;

use strict;
use warnings;
use Carp;
use Exporter qw(import);
use Weibeld::Coltab::HTMLManager qw(add_header start_new_table add_table_row);

our(@EXPORT_OK, $VERSION);

$VERSION = "0.01";
@EXPORT_OK = qw(parse_file);

my $is_table_started;

sub parse_file {
    my $fname = shift;
    open(my $f, '<', $fname) or croak "Can't open file $fname for reading: $!";
    # Loop through all the lines of the input file
    while (<$f>) {
        next if _parse_list_item($_);
        # If it's not a list item and there's an open table, close the table
        if ($is_table_started) { $is_table_started = 0; }
        next if _parse_header($_);
    }
}

sub _parse_list_item {
    my $line = shift;
    # Test if the line is a list item
    if ($line =~ /^[*+-]\s+`?\#?([a-f0-9]{3}|[a-f0-9]{6})`?\s*$/i) {
        if (not $is_table_started) {
            start_new_table();
            $is_table_started = 1;
        }
        add_table_row("#$1");
        return 1;
    }
}

sub _parse_header {
    my $line = shift;
    if (_is_header($line)) {
        my %header = _get_header($line);
        add_header($header{level}, $header{text});
        return 1;
    }
}

sub _get_header {
    my $line = shift;
    for my $i (1 .. 6) {
        my $pattern = "^" . "#"x$i . "\\s+(.*)\$";
        if ($line =~ /$pattern/) {
            return (level => $i, text => $1);
        }
    }
}

sub _is_header {
    my $line = shift;
    return ($line =~ /^#{1,6}\s/);
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
