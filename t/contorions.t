use strict;
use warnings;

use Test::More;

use PPI::Util qw( _Document );
use PPI;
use PPIx::Element::Package;

my $document = _Document('t/corpus/LineSub_A.pm');

subtest "Subs are in expected packages" => sub {
  my (@subs) = @{ $document->find('PPI::Statement::Sub') };

  my $expected = {
    'un_packaged' => 'main',
    'sub_a'       => 'Example',
    'sub_b'       => 'OtherExample',
    'forward'     => 'OtherExample',
    'chaos'       => 'Chaos',
    'not_chaos'   => 'OtherExample',
  };

  for my $sub (@subs) {
    is( $sub->x_package_namespace, $expected->{ $sub->name }, "Namespace for sub " . $sub->name . " is the expected value" );
    if ( not $sub->forward ) {
      is(
        $sub->block->finish->x_package_namespace,
        $expected->{ $sub->name },
        "Namespace for sub " . $sub->name . "'s finishing token is the expected value"
      );
    }
  }
};

subtest "Packages are self-contained" => sub {
  my (@packages) = @{ $document->find('PPI::Statement::Package') };

  my $expected = {
    'Example'      => 'Example',
    'OtherExample' => 'OtherExample',
    'Chaos'        => 'Chaos',
  };

  for my $package (@packages) {
    my $expected = $expected->{ $package->namespace };

    is( $package->x_package_namespace, $expected, "Namespace for package " . $package->namespace . " is the expected value" );
    for my $child ( $package->children ) {
      is( $child->x_package_namespace, $expected, "Namespace for package child " . $child->class . " is the expected value" );
    }
  }
};



done_testing;
