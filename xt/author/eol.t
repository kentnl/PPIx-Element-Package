use strict;
use warnings;

# this test was generated with Dist::Zilla::Plugin::Test::EOL 0.18

use Test::More 0.88;
use Test::EOL;

my @files = (
    'lib/PPIx/Element/Package.pm',
    't/00-compile/lib_PPIx_Element_Package_pm.t',
    't/00-report-prereqs.dd',
    't/00-report-prereqs.t',
    't/corpus/dual_scope.pm',
    't/corpus/no_package.pm',
    't/corpus/single_labelled_scope.pm',
    't/corpus/single_package.pm',
    't/dual_scope.t',
    't/lib/PkgCheck.pm',
    't/no_package.t',
    't/package_self_ownership.t',
    't/self-parse.t',
    't/single_labelled_scope.t',
    't/single_package.t'
);

eol_unix_ok($_, { trailing_whitespace => 1 }) foreach @files;
done_testing;