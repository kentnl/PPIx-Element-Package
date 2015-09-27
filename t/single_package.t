use strict;
use warnings;

use Test::More;
use PPI::Util qw( _Document );
use lib 't/lib';
use PkgCheck;

my $document = _Document('t/corpus/single_package.pm');

package_is $_, 'Example', 'all tokens in single-package doc are in namespace Example' for $document->tokens;

package_is $_, 'Example', 'all nodes in single-package doc are in namespace Example' for @{ $document->find('PPI::Node') };

done_testing;
