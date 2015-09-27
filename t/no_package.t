use strict;
use warnings;

use Test::More;

use PPI::Util qw( _Document );
use PPIx::Element::Package qw( identify_package_namespace );

my $document  = _Document('t/corpus/no_package.pm');
my $namespace = 'main';

for my $token ( $document->tokens ) {
  is( identify_package_namespace($token), $namespace, "all tokens in packageless doc are in namespace $namespace" )
    or diag $token->class, ' => ', explain $token->content;
}
for my $element ( @{ $document->find('PPI::Node') } ) {
  is( identify_package_namespace($element), $namespace, "all nodes in packageless doc are in namespace $namespace" )
    or diag $element->class, ' => ', explain $element->content;

}

done_testing;
