use strictures 1;
package Mojito::Model::DB;
BEGIN {
  $Mojito::Model::DB::VERSION = '0.07';
}
use Moo;

with('Mojito::Role::DB');

1