use strict;
use warnings;

package PkgCheck;

use Test::Builder;
use Exporter 5.57 qw( import );
use PPIx::Element::Package (qw( identify_package_namespace ) );

our @EXPORT = qw( package_is );

sub package_is($$$) {
  my ( $element, $package, $reason ) = @_;
  my $builder = Test::Builder->new();
  $builder->is_eq( identify_package_namespace( $element ), $package, $reason ) or do {
    $builder->diag( "class: " . $element->class );
    $builder->diag( "content: " . $element->content );
  };
}


