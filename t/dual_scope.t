use strict;
use warnings;

use Test::More;

use PPI::Util qw( _Document );
use lib 't/lib';
use PkgCheck;

my $document = _Document('t/corpus/dual_scope.pm');

my @subs = @{ $document->find('PPI::Statement::Sub') };
my ($inner) = grep { $_->name eq 'in_scope' } @subs;
my ($outer) = grep { $_->name eq 'out_of_scope' } @subs;

package_is( $inner, 'Example', 'sub inside the scope after the package is owned by the package' );
package_is( $outer, 'Outer',   'sub outside the scope after the package is owned by Outer' );

subtest 'in_scope children' => sub {
  package_is $_, 'Example', 'Children of inner sub are owned by the package' for $inner->children;
};
subtest 'out_of_scope children' => sub {
  package_is $_, 'Outer', 'Children of outer sub are owned by Outer' for $outer->children;
};
done_testing;
