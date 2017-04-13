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

# Initialise a new HTML tree. Must be called before all other subroutines.
sub init_html {
    $html= HTML::TagTree->new('html');
    $head = $html->head();
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

# Return the generated HTMl as a string
sub get_html{
    return $html->get_html_text(-1, 0);
}

1;
