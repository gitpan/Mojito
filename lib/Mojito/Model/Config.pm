use strictures 1;
package Mojito::Model::Config;
BEGIN {
  $Mojito::Model::Config::VERSION = '0.09';
}
use Moo;

with('Mojito::Role::Config');

1