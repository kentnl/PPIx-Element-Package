use strict;
use warnings;

use Test::More;

use PPI::Util qw( _Document );
use PPI;
use PPIx::Element::Package qw( identify_package_namespace );

my $document = _Document('lib/PPIx/Element/Package.pm');

my (@subs) = @{ $document->find('PPI::Statement::Sub') };

for my $sub (@subs) {
  is( identify_package_namespace($sub), 'PPIx::Element::Package', "Namespace for sub " . $sub->name . " is the expected value", );
}

done_testing;
