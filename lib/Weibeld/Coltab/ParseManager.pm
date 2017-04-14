package Weibeld::Coltab::ParseManager;

use strict;
use warnings;
use Carp;
use Weibeld::Coltab::HTMLManager qw(add_header start_new_table add_table_row);

# Import 'import' so that a user of this module can call 'import(<subs>)'
use Exporter qw(import);
our @EXPORT_OK = qw(parse_file);

our $VERSION = "0.01";

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
