package Weibeld::Coltab::ParseManager;

use strict;
use warnings;
use Carp;
use Exporter qw(import);

our $VERSION = "0.01";
our @EXPORT_OK = qw(parse_file);

# Reference to hash with references to functions
my $callbacks;
# True if there's an ongoing list in the input file, and false otherwise
my $is_open_list;

# Primary function of this module. Read input file line by line and call
# provided callbacks. The first argument is the input file, the second argument
# is a reference to a hash containing function refs under the following keys:
#   - on_header_found
#   - on_list_item_found
#   - on_list_interrupted
sub parse_file {
    my $file = shift;
    $callbacks = shift;
    $is_open_list = 0;

    # Loop through all the lines of the input file
    open(my $f, '<', $file) or croak "Can't open file $file for reading: $!";
    while (<$f>) {
        # Test if line is a list item
        if (my $item = _parse_list_item($_)) {
            $callbacks->{on_list_item_found}->($item);
            $is_open_list = 1 if (not $is_open_list);
            next;
        # If line is not a list item, test if a list has been interrupted
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

# Test if the passed string is a Markdown list item, if so, return the item text
sub _parse_list_item {
    my $line = shift;
    return $1 if ($line =~ /^[*+-]\s+(.*)$/);
}


# Test if the passed string is a Markdown header (level 1 to 6), if so, return
# a reference to a hash with the keys "content" and "level".
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

# If there's a running list, signalize its interruption by through the callback
sub _interrupt_list {
    if ($is_open_list) {
        $callbacks->{on_list_interrupted}->();
        $is_open_list = 0;
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
