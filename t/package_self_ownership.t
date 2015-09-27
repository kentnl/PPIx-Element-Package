use strict;
use warnings;

use Test::More;

use PPI::Util qw( _Document );
use lib 't/lib';
use PkgCheck;

for my $corpus (qw( dual_scope.pm single_labelled_scope.pm single_package.pm )) {
  subtest $corpus => sub {
    my $document = _Document( 't/corpus/' . $corpus );

    for my $package ( @{ $document->find('PPI::Statement::Package') || [] } ) {
      package_is $package, $package->namespace, $package->namespace . ' is owned by itself';
      subtest "$corpus:" . $package->namespace . '->children' => sub {
        package_is $_, $package->namespace, $package->namespace . ' owns its children' for $package->children;
      };
    }
  };
}
done_testing;
