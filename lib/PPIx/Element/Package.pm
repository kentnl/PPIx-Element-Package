use 5.006;    # our
use strict;
use warnings;

package PPIx::Element::Package;

our $VERSION = '0.001000';

# ABSTRACT: Derive the package an element is defined in

# AUTHORITY

use Scalar::Util qw( refaddr );
use Exporter 5.57 qw( import );
our @EXPORT_OK = qw( identify_package identify_package_namespace );

=func identify_package

Identifies the logical owner C<PPI::Statement::Package> for C<$element>

  my $package = PPIx::Element::Package::identify_package( $element );

=cut

sub identify_package {
  my ($element) = @_;
  return $element if $element->isa('PPI::Statement::Package');
  return unless $element->can('parent') and defined $element->parent;
  my $parent = $element->parent;
  return $parent if $parent->isa('PPI::Statement::Package');
  return identify_package($parent) unless $parent->can('children');
  my (@previous_siblings);
  my $self_addr = refaddr($element);

  for my $sibling ( $parent->children ) {
    last if $self_addr eq refaddr $sibling;
    push @previous_siblings, $sibling;
  }
  for my $previous_sibling ( reverse @previous_siblings ) {
    return $previous_sibling if $previous_sibling->isa('PPI::Statement::Package');
  }
  return identify_package($parent);
}

sub identify_package_namespace {
  my ($element) = @_;
  my $package = identify_package($element);
  return 'main' unless defined $package;
  return 'main' unless defined $package->namespace;
  return $package->namespace;
}

1;

=head1 SYNOPSIS

  use PPI;
  use PPIx::Element::Package qw( identify_package identify_package_namespace );

  # Do your normal PPI stuff here.

  # Get the logical enclosing package or undef if one cannot be discovered
  my $package = identify_package( $element );

  # Get the name of the logical enclosing package, or main if one cannot be discovered
  my $namespace = identify_package_namespace( $element );

=head1 DESCRIPTION

This module aims to determine the scope any L<< C<PPI::Element>|PPI::Element >>
( which includes L<< C<Nodes>|PPI::Node >> and L<< C<Tokens>|PPI::Token >> ) is defined in.

It provides two utility methods as follows:

=over 4

=item C<identify_package> - The Logical L<<
C<PPI::Statement::Package>|PPI::Statement::Package
>> that owns the C<Element>

=item C<identify_package_namespace> - The name-space of the logical C<<
PPI::Statement::Package >> that owns the element.

=back

The latter of these is just a convenience wrapper on top of C<x_package> that
returns C<main> when either the owning C<Statement::Package> cannot be found,
or when the owning C<Statement::Package>'s name-space is somehow undefined.

=head1 LOGIC

Here lies the assumptions that this module uses to find the C<Package>:

=over 4

=item 1. That any node that has children nodes implies a lexical scope.

=item 2. That within a given lexical scope, the first C<Package> sibling prior
to a given Element is the C<Owner> package.

=item 3. In the event a given lexical scope has no C<Package> declarations
between the Element and the first child of that lexical scope, that the
C<Package> can be derived from the position of the scope itself, by re-applying
rules 1 and 2 recursively upwards until the C<Document> is reached.

=item 4. Any nodes that are C<PPI::Statement::Package> are contained I<within>
B<themselves>, that is:

  package Foo; # This Whole line is inside "Foo"
  package Bar; # This Whole line is inside "Bar"

=item 5. And subsequently, any children of a C<PPI::Statement::Package> C<Node>
(which are the tokens themselves that compose the statement) are themselves
within that package. ( This is just a logical extension of #4 ).

=back

The biggest scope I presently have for error in these assumptions is in the
assumptions about Package scope being determinable from the C<PPI> document
hierarchy, which may lead to an over-eager presumption that a lexical scope
exists where one may not exist.

However, under my testing so far this approach has proven more useful and
accurate than manually traversing the tokens and only declaring scopes on
C<Block> boundaries.

=head1 SEE ALSO

=head2 C<PPIx::LineToSub>

I initially tried using L<< C<PPIx::LineToSub>|PPIx::LineToSub >>, however,
in testing it proved far too sloppy for my uses, and having no support for
lexical contexts at all and is entirely oriented on a
"new package overrides previous package" principle.

Its is also limited for my use cases in that it is entirely line oriented,
so cases like this are intractably insolvable:

  package Quux; { package Foo; baz() } bar();

Answering "what package is on this line" is not even a sensible question to
ask there.

It has however a performance advantage due to being a single-pass indexing
sweep with all subsequent checks being a simple array look-up.

