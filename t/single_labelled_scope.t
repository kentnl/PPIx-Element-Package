use strict;
use warnings;

use Test::More;

use PPI::Util qw( _Document );
use PPIx::Element::Package qw( identify_package_namespace );

my $document  = _Document('t/corpus/single_labelled_scope.pm');
my $namespace = 'Example';

my @subs = @{ $document->find('PPI::Statement::Sub') };
my ($inner) = grep { $_->name eq 'in_scope' } @subs;
my ($outer) = grep { $_->name eq 'out_of_scope' } @subs;

is( identify_package_namespace($inner), 'Example', 'sub inside the scope after the package is owned by the package' );
is( identify_package_namespace($outer), 'main',    'sub outside the scope after the package is owned by main' );

subtest 'in_scope children' => sub {
  for my $child ( $inner->children ) {
    is( identify_package_namespace($child), 'Example', 'Children of inner sub are owned by the package' );
  }
};
subtest 'out_of_scope children' => sub {
  for my $child ( $outer->children ) {
    is( identify_package_namespace($child), 'main', 'Children of outer sub are owned by main' );
  }
};
done_testing;
