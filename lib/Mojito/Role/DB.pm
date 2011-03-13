use strictures 1;
package Mojito::Role::DB;
BEGIN {
  $Mojito::Role::DB::VERSION = '0.08';
}
use Moo::Role;
use MongoDB;

# Create a database and get a handle on a users collection.
has 'conn' => (
    is => 'ro',
    lazy => 1,
    builder => '_build_conn',
);
has 'db_name' => (
    is => 'rw',
    lazy => 1,
    default => sub { 'mojito' },
);
has 'db' => (
    is => 'ro',
    lazy => 1,
    builder => '_build_db',
);
has 'collection' => (
    is => 'ro',
    lazy => 1,
    builder => '_build_collection',
);
has 'collection_name' => (
    is => 'rw',
    lazy => 1,
    default => sub { 'notes' },
);

sub _build_conn {
    MongoDB::Connection->new;
}

sub _build_db  {
    my $self = shift;
    my $db_name = $self->db_name;
    $self->conn->${db_name};
}
sub _build_collection  {
    my $self = shift;
    my $collection_name = $self->collection_name;
    $self->db->${collection_name};
}
1;