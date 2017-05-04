package Weibeld::Coltab::HTMLManager;

use strict;
use warnings;
use Carp;
use HTML::TagTree;
use File::Map qw(map_file);
use feature qw(switch);
no warnings 'experimental::smartmatch';
use Exporter qw(import);

our $VERSION = "0.01";
our @EXPORT_OK = qw(html_init html_set_css html_add_header html_add_row
                    html_end_table html_get);

my $html;
my $head;
my $body;
my $table;

# Initialise new HTML tree. Must be called before all other functions. A title
# for the HTML may be optionally passed.
sub html_init {
    my $title = shift;
    $html= HTML::TagTree->new('html');
    $head = $html->head();
    $head->title($title) if ($title);
    $body = $html->body();
}

# Add CSS to HTML (optional). The first arg is a CSS file, the second arg is
# a boolean specifying whether to include the CSS as a link (true), or as full
# text (false). If true, the first arg may be a URL.
sub html_set_css {
    my($css, $is_link) = @_;
    if ($is_link) {
        $head->link('', "rel=\"stylesheet\" href=\"$css\"");
    } else {
        map_file(my $css_content, $css);
        $head->style($css_content);
    }
}

# Add a header (<h1> to <h6>) to the HTML. The first arg is the header content,
# the second arg is the level of the header (1 to 6).
sub html_add_header{
    my ($content, $level) = @_;
    given ($level) {
        when (1) { $body->h1($content); }
        when (2) { $body->h2($content); }
        when (3) { $body->h3($content); }
        when (4) { $body->h4($content); }
        when (5) { $body->h5($content); }
        when (6) { $body->h6($content); }
        default { croak "Invalid HTML header level"; }
    }
}


# Add a colour row to the HTML. If there is currently no open table, a new table
# is created. The argument must be an RGB colour of the form #RRGGBB or #RGB.
sub html_add_row {
    my $color = shift;
    $table = $body->table() if (not $table);
    my $tr = $table->tr();
    $tr->td('', "class=\"color\" style=\"background-color:$color\"");
    $tr->td($color, 'class="code"');
}

# End the currently open table (if any), so that subsequent calls to
# html_add_row start a new table rather than appending to the existing one.
sub html_end_table {
    $table = 0;
}

# Return the generated HTML as a string
sub html_get{
    return $html->get_html_text(-1, 0);
}

1;

__END__

=head1 NAME

Weibeld::Coltab::HTMLManager - create a colour table HTML file

=head1 SYNOPSIS

    use Weibeld::Coltab::HTMLManager qw(html_init html_set_css start_new_table
                                        html_add_row html_add_header html_get);

    html_init();
    html_set_css("syles.css");
    html_add_header(1, "My Favourite Colours");
    start_new_table();
    html_add_row("#2020AE");
    print html_get();

=head1 DESCRIPTION

The Weibeld::Coltab::HTMLManager module allows to create an HTML file with headers and colour tables. The headers can be anything from C<< <h1> >> to C<< <h6> >>. The colour tables are HTML tables with two columns, of which the first-column cells have their background colour set to a specific colour (e.g. C<#2020AE>), and the second-column cells display the corresponding colour code (i.e. C<#2020AE>).

A title and a CSS file can be set for the HTML file being created, and the final HTML text can be obtained as a string.

=head1 FUNCTIONS

=over 4

=item html_init

The C<html_init> function initialises the HTML tree.

Note that it is mandatory to call this function before calling any other function in this module.

=item html_set_css

The C<html_set_css> function can be used to include or link a CSS file to the HTML file.

Takes two arguments. The first argument must be the name of a CSS file. The second argument, which is optional, defines whether the CSS file is included in full-text in the HTML header (if the argument evaluates to I<true>), or only linked to (if the argument is missing or evaluates to I<false>).

In the latter case (if the CSS file is linked to), the first argument may be a URL.

=item html_add_header

The C<html_add_header> function adds a new header (C<< <h1> >>, C<< <h2> >>, etc.) to the HTML tree.

The function takes two arguments. The first argument must be a number between 1 and 6 denoting the desired header level. The second argument is the text of the header.

=item start_new_table

The C<start_new_table> function should be called whenever a new table should be added to the HTML file. This new table will be the one to which subsequent calls to C<L</"html_add_row">> add their table rows.

=item html_add_row

The C<html_add_row> function adds a new row to the current colour table of the output. This table row has two columns, the first one is empty but has its background colour set to the supplied colour, and the second column holds the colour code of the supplied colour.

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

=item html_get

The C<html_get> function  returns the generated HTML as a string.

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
