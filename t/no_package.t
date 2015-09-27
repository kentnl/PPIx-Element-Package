use strict;
use warnings;

use Test::More;

use PPI::Util qw( _Document );
use lib 't/lib';
use PkgCheck;

my $document = _Document('t/corpus/no_package.pm');

package_is $_, 'main', "all tokens in packageless doc are in namespace main" for $document->tokens;

package_is $_, 'main', "all nodes in packageless doc are in namespace main" for @{ $document->find('PPI::Node') };

done_testing;
