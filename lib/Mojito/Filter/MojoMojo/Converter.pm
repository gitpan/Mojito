use strictures 1;
package Mojito::Filter::MojoMojo::Converter;
{
  $Mojito::Filter::MojoMojo::Converter::VERSION = '0.20';
}
use Moo;
use HTML::Toc;
use HTML::TocInsertor;
use 5.010;

has content => (
    is       => 'rw',
    required => 1,
);
has original_content => ( is => 'rw', );
has html_toc => (
    is => 'ro',
    lazy => 1,
    builder => '_build_html_toc',
);
sub _build_html_toc {
    HTML::Toc->new();    
}

=head1 Methods

=head2 convert_content

Run through the list of MojoMojo converters.
Currently it's just the <pre lang="$lang"> to <pre class="prettyprint">

=cut

sub convert_content {
    my ($self) = (shift);

    return if !$self->content;
    $self->$_ for qw/ pre_lang toc /;
    return $self->content;
}

=head2 pre_lang

Turn MojoMojo <pre lang="$foo">bar</pre> into:
    <pre class="prettyprint">bar</pre>

=cut

sub pre_lang {
    my ($self) = @_;

    my $content = $self->content;
    $content =~
      s/<pre\s+lang=[^>]*>(.*?)<\/pre>/<pre class="prettyprint">$1<\/pre>/sig;
    $self->content($content);
}

=head2 toc

Graciously pilfered from dandv's hard work on MojoMojo.

Calls the formatter. Takes a ref to the content as well as the context object.
The syntax for the TOC plugin invocation is:

  {{toc M- }}     # start from Header level M
  {{toc -N }}     # stop at Header level N
  {{toc M-N }}    # process only header levels M..N

where M is the minimum heading level to include in the TOC, and N is the
maximum level (depth). For example, suppose you only have one H1 on the page
so it doesn't make sense to add it to the TOC; also, assume you and don't want
to include any headers smaller than H3. The {{toc}} markup to achieve that would be:

  {{toc 2-3}}

Defaults to 1-6.

=cut

sub toc {
    my ($self) = @_;

    my $content = $self->content;
    my $toc_params_RE = qr/\s+ (\d+)? \s* - \s* (\d+)?/x;
    while (
        # replace the {{toc ..}} markup tag and parse potential parameters
        $content =~ s[
            {{ toc (?:$toc_params_RE)? \s* \/? }}
        ][<div class="toc">\n<!--mojomojoTOCwillgohere-->\n</div>]ix) {
        my ($toc_h_min, $toc_h_max);
        $toc_h_min = $1 || 1;
        $toc_h_max = $2 || 9;  # in practice, there are no more than 6 heading levels
        $toc_h_min = 9 if $toc_h_min > 9;  # prevent TocGenerator error for headings >= 10
        $toc_h_max = 9 if $toc_h_max > 9 or $toc_h_max < $toc_h_min;  # {{toc 3-1}} is wrong; make it {{toc 3-9}} instead

        my $toc = $self->html_toc;
        my $tocInsertor = HTML::TocInsertor->new();

        $toc->setOptions({
            header => '',  # by default, \n<!-- Table of Contents generated by Perl - HTML::Toc -->\n
            footer => '',
            insertionPoint => 'replace <!--mojomojoTOCwillgohere-->',
            doLinkToId => 0,
            levelToToc => "[$toc_h_min-$toc_h_max]",
#            templateAnchorName => \&assembleAnchorName,
        });

        # http://search.cpan.org/dist/HTML-Toc/Toc.pod#HTML::TocInsertor::insert()
        $tocInsertor->insert($toc, $content, {output => \$content});
        $self->content($content);
    }
}

=head2 BUILD

Store original content

=cut

sub BUILD {
    my ($self) = (shift);
    $self->original_content( $self->content );
}

1
