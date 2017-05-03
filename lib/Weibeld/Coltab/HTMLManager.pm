package Weibeld::Coltab::HTMLManager;

use strict;
use warnings;
use Carp;
use HTML::TagTree;
use File::Map qw(map_file);
use feature qw(switch);
no warnings 'experimental::smartmatch';

# Import 'import' so that users of our module can import our subs
use Exporter qw(import);
our @EXPORT_OK = qw(init_html set_css add_header
                    start_new_table add_table_row get_html);

our $VERSION = "0.01";

my $html;
my $head;
my $body;
my $table;

# Initialise a new HTML tree. Call before all other functions of this module.
sub init_html {
    my $title = shift;
    $html= HTML::TagTree->new('html');
    $head = $html->head();
    $head->title($title) if ($title);
    $body = $html->body();
}

# Add CSS information to HTML tree.
# Arguments:
#   $css:     a valid filename
#   $is_link: bool: true => add link to CSS file; false => include CSS content
sub set_css {
    my($css, $is_link) = @_;
    if ($is_link) {
        $head->link('', "rel=\"stylesheet\" href=\"$css\"");
    } else {
        map_file(my $css_content, $css);
        $head->style($css_content);
    }
}

# Add a header (<h1> to <h6>) to the HTML tree
sub add_header{
    my ($level, $text) = @_;
    given ($level) {
        when (1) { $body->h1($text); }
        when (2) { $body->h2($text); }
        when (3) { $body->h3($text); }
        when (4) { $body->h4($text); }
        when (5) { $body->h5($text); }
        when (6) { $body->h6($text); }
        default { croak "Invalid HTML header level"; }
    }
}

# Add a new table to the HTML tree
sub start_new_table {
    $table = $body->table();
}

# Add a new row to the most recently added table of the HTML tree
sub add_table_row {
    my $color_code = shift;
    my $tr = $table->tr();
    $tr->td('', "class=\"color\" style=\"background-color:$color_code\"");
    $tr->td($color_code, 'class="code"');
}

# Return the generated HTML as a string
sub get_html{
    return $html->get_html_text(-1, 0);
}

1;

__END__

=head1 NAME

Weibeld::Coltab::HTMLManager - create a colour table HTML file

=head1 SYNOPSIS

    use Weibeld::Coltab::HTMLManager qw(init_html set_css start_new_table
                                        add_table_row add_header get_html);

    init_html();
    set_css("syles.css");
    add_header(1, "My Favourite Colours");
    start_new_table();
    add_table_row("#2020AE");
    print get_html();

=head1 DESCRIPTION

The Weibeld::Coltab::HTMLManager module allows to create an HTML file with headers and colour tables. The headers can be anything from C<< <h1> >> to C<< <h6> >>. The colour tables are HTML tables with two columns, of which the first-column cells have their background colour set to a specific colour (e.g. C<#2020AE>), and the second-column cells display the corresponding colour code (i.e. C<#2020AE>).

A title and a CSS file can be set for the HTML file being created, and the final HTML text can be obtained as a string.

=head1 FUNCTIONS

=over 4

=item init_html

The C<init_html> function initialises the HTML tree.

Note that it is mandatory to call this function before calling any other function in this module.

=item set_css

The C<set_css> function can be used to include or link a CSS file to the HTML file.

Takes two arguments. The first argument must be the name of a CSS file. The second argument, which is optional, defines whether the CSS file is included in full-text in the HTML header (if the argument evaluates to I<true>), or only linked to (if the argument is missing or evaluates to I<false>).

In the latter case (if the CSS file is linked to), the first argument may be a URL.

=item add_header

The C<add_header> function adds a new header (C<< <h1> >>, C<< <h2> >>, etc.) to the HTML tree.

The function takes two arguments. The first argument must be a number between 1 and 6 denoting the desired header level. The second argument is the text of the header.

=item start_new_table

The C<start_new_table> function should be called whenever a new table should be added to the HTML file. This new table will be the one to which subsequent calls to C<L</"add_table_row">> add their table rows.

=item add_table_row

The C<add_table_row> function adds a new row to the current colour table of the output. This table row has two columns, the first one is empty but has its background colour set to the supplied colour, and the second column holds the colour code of the supplied colour.

This function takes a single argument, which is the hexadecimal RGB colour code of the desired colour for this table row.

Valid colour code formats are (note that the prefixed C<#> is optional):

=over 4

=item *

C<[#]RRGGBB>

=item *

C<[#]RGB>

=back

The created C<< <td> >> tags for the two columns of the table are assigned the following CSS classes:

Note that it is necessary to call L</"start_new_table"> at least once before calling this function.

=item get_html

The C<get_html> function  returns the generated HTML as a string.

=back

=head1 AUTHOR

Daniel Weibel <L<info@weibeld.net|mailto:info@weibeld.net>>

=head1 SEE ALSO

Weibeld::Coltab::ParseManager

=head1 LICENSE

Copyright 2017 Daniel Weibel

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
