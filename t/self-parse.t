use strict;
use warnings;

use Test::More;
use PPI::Util qw( _Document );
use lib 't/lib';
use PkgCheck;

my $document = _Document('lib/PPIx/Element/Package.pm');

package_is $_, 'PPIx::Element::Package', "Namespace for sub " . $_->name . " is the expected value"
  for @{ $document->find('PPI::Statement::Sub') };

done_testing;
