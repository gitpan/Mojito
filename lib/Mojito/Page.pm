use strictures 1;
package Mojito::Page;
BEGIN {
  $Mojito::Page::VERSION = '0.09';
}
use Moo;
use Sub::Quote qw(quote_sub);

=head1 Description

An object to delegate to the Page family of objects.

=cut

=head1 Synopsis

    use Mojito::Page;
    my $page_source = $params->{content};
    my $pager = Mojito::Page->new( page_source => $page_source);
    my $web_page = $pager->render_page;

=cut

# delegates
use Mojito::Page::Parse;
use Mojito::Page::Render;
use Mojito::Page::CRUD;
use Mojito::Page::Git;
use Mojito::Template;
use Mojito::Model::Link;

# roles

has parser => (
    is      => 'ro',
    isa     => sub { die "Need a PageParse object.  Have ref($_[0]) instead." unless $_[0]->isa('Mojito::Page::Parse') },
    lazy    => 1,
    handles => [
        qw(
          page_structure
          )
    ],
    writer => '_build_parse',
);

has render => (
    is      => 'ro',
    isa     => sub { die "Need a PageRender object" unless $_[0]->isa('Mojito::Page::Render') },
    handles => [
        qw(
          render_page
          render_body
          intro_text
          )
    ],
    writer => '_build_render',
);

has editer => (
    is      => 'ro',
    isa     => sub { die "Need a PageEdit object" unless $_[0]->isa('Mojito::Page::CRUD') },
    handles => [
        qw(
            create
            read
            update
            delete
          )
    ],
    writer => '_build_edit',
);

has tmpl => (
    is      => 'ro',
    isa     => sub { die "Need a Template object" unless $_[0]->isa('Mojito::Template') },
    handles => [
        qw(
          template
          home_page
          fillin_create_page
          fillin_edit_page
          )
    ],
    writer => '_build_template',
);

has linker => (
    is      => 'ro',
    isa     => sub { die "Need a Link Model object" unless $_[0]->isa('Mojito::Model::Link') },
    handles => [
        qw(
            get_most_recent_links
            get_feed_links
          )
    ],
    writer => '_build_link',
);

has gitter => (
    is      => 'ro',
    isa     => sub { die "Need a PageGit object" unless $_[0]->isa('Mojito::Page::Git') },
    handles => [
        qw(
            commit_page
            rm_page
            diff_page
            search_word
          )
    ],
    writer => '_build_gitter',
);
=head1 Methods

=head2 BUILD

Create the handler objects

=cut

sub BUILD {
    my $self                  = shift;
    my $constructor_args_href = shift;

    # pass the options into the subclasses
    $self->_build_parse(Mojito::Page::Parse->new($constructor_args_href));
    $self->_build_render(Mojito::Page::Render->new($constructor_args_href));
    $self->_build_edit(Mojito::Page::CRUD->new( $constructor_args_href));
    $self->_build_gitter(Mojito::Page::Git->new( $constructor_args_href));
    $self->_build_template(Mojito::Template->new( $constructor_args_href));
    $self->_build_link(Mojito::Model::Link->new( $constructor_args_href));

}

1