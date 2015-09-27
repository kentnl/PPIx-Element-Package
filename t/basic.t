use strict;
use warnings;

use Test::More;

use PPI::Util qw( _Document );
use PPI;
use PPIx::Element::Package qw( identify_package_namespace );

my $document = _Document('lib/PPIx/Element/Package.pm');

subtest "Subs are in expected packages" => sub {
  my (@subs) = @{ $document->find('PPI::Statement::Sub') };

  my $expected = {
    'identify_package'           => 'PPIx::Element::Package',
    'identify_package_namespace' => 'PPIx::Element::Package',
  };

  for my $sub (@subs) {
    is(
      identify_package_namespace($sub),
      $expected->{ $sub->name },
      "Namespace for sub " . $sub->name . " is the expected value"
    );
  }
};

subtest "Packages are self-contained" => sub {
  my (@packages) = @{ $document->find('PPI::Statement::Package') };

  my $expected = {
    'PPI::Element'           => 'PPI::Element',
    'PPIx::Element::Package' => 'PPIx::Element::Package',
  };

  for my $package (@packages) {
    my $expected = $expected->{ $package->namespace };

    is( identify_package_namespace($package),
      $expected, "Namespace for package " . $package->namespace . " is the expected value" );
    for my $child ( $package->children ) {
      is( identify_package_namespace($child),
        $expected, "Namespace for package child " . $child->class . " is the expected value" );
    }
  }
};

done_testing;
