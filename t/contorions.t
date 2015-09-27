use strict;
use warnings;

use Test::More;

use PPI::Util qw( _Document );
use PPI;
use PPIx::Element::Package qw( identify_package_namespace );

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
    is( identify_package_namespace( $sub), $expected->{ $sub->name }, "Namespace for sub " . $sub->name . " is the expected value" );
    if ( not $sub->forward ) {
      is(
        identify_package_namespace( $sub->block->finish ),
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

    is( identify_package_namespace(  $package ), $expected, "Namespace for package " . $package->namespace . " is the expected value" );
    for my $child ( $package->children ) {
      is( identify_package_namespace( $child ), $expected, "Namespace for package child " . $child->class . " is the expected value" );
    }
  }
};



done_testing;
