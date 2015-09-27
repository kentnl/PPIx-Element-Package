use strict;
use warnings;

use Test::More;

use PPI::Util qw( _Document );
use PPIx::Element::Package qw( identify_package_namespace );

for my $corpus (qw( dual_scope.pm single_labelled_scope.pm single_package.pm )) {
  subtest $corpus => sub {
    my $document = _Document( 't/corpus/' . $corpus );

    for my $package ( @{ $document->find('PPI::Statement::Package') || [] } ) {
      is( identify_package_namespace($package), $package->namespace, $package->namespace . ' is owned by itself' );
      subtest "$corpus:" . $package->namespace . '->children' => sub {
        for my $child ( $package->children ) {
          is( identify_package_namespace($child), $package->namespace, $package->namespace . ' owns its children' );
        }
      };
    }
  };
}
done_testing;
