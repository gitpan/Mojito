use strictures 1;
package Mojito::Collection::CRUD;
{
  $Mojito::Collection::CRUD::VERSION = '0.13';
}
use MongoDB::OID;
use 5.010;
use Moo;
use Data::Dumper::Concise;

with('Mojito::Role::DB');

has base_url => ( is => 'rw', );

=head1 Methods

=head2 create

Create a list of document ids in the collection named 'collection'.
The funny name is due to the fact we're storing document ids from
the notes collection in individual documents of the collection collection.
i.e. we are creating (ordered) sets of documents identified with
a document name.

The motivation for collections of docs collection is so that we can group 
documents together form display purposes.  Form example, say I'm working 
on a project with multiple documents.  I'd like to be able to "identify/tag" 
them to the project so I can narrow my viewing focus to just those documents.

=cut

sub create {
    my ( $self, $params ) = @_;

    # We don't need to store the form submit value
    delete $params->{collect};
    my $page_ids = $params->{collected_page_ids};
    
    # NOTE: The $page_ids input can come in two different forms: 
    # - String:   "$page_id1,$page_id2,...$page_id_n";
    # - ArrayRef: [$page_id1,$page_id2,..., $page_id_n];
    $params->{collected_page_ids} = [split ',', $page_ids] if (!ref($page_ids));
    
    # add save time as last_modified and created
    $params->{last_modified} = $params->{created} = time();

    my $collection = $self->collection->find_one({ collection_name  => $params->{collection_name} });
    my $oid;
    if ( $oid = $collection->{_id} ) {
        $self->collection->update( { '_id' => $oid }, $params );
    } 
    else {
        $oid = $self->collection->insert($params);
    }
    
    return $oid->value;
}

=head2 read

Read a collection from the database.

=cut

sub read {
    my ( $self, $id ) = @_;
    my $oid = MongoDB::OID->new( value => $id );
    return $self->collection->find_one( { _id => $oid } );
}

=head2 update

Update a collection in the database.

=cut

sub update {
    my ( $self, $params) = @_;

    my $oid = MongoDB::OID->new( value => $params->{id} );
    $params->{last_modified} = time();

    $self->collection->update( { '_id' => $oid }, $params );
}

=head2 delete

Delete a collection from the database.

=cut

sub delete {
    my ( $self, $id ) = @_;

    my $oid = MongoDB::OID->new( value => $id );
    $self->collection->remove( { '_id' => $oid } );
}

=head2 get_all

Get all pages in the notes collection.
Returns a MongoDB cursor one can iterate over.

=cut

sub get_all {
    my $self = shift;
    return $self->collection->find;
}

=head2 BUILD

Set the collection we want to work with.
In this case it's the collection named 'collection'.
It's a bit meta is why the funny naming.

=cut

sub BUILD {
    my $self = shift;
    $self->collection_name('collection');
}

1
