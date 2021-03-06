use 5.006;    # our
use strict;
use warnings;

package PPIx::Element::Package;

our $VERSION = '0.001001';

# ABSTRACT: Derive the package an element is defined in

# AUTHORITY

use Scalar::Util qw( refaddr );
use Exporter 5.57 qw( import );
our @EXPORT_OK = qw( identify_package identify_package_namespace identify_package_in_previous_siblings );

=func identify_package

Upwards-Recursively identifies the logical owner C<PPI::Statement::Package> for
C<$element>.

  my $package = PPIx::Element::Package::identify_package( $element );

=cut

sub identify_package {
  my ($element) = @_;

  # Packages are their own owners
  return $element if $element->isa('PPI::Statement::Package');

  # Elements without parents have no Package
  return unless $element->can('parent') and my $parent = $element->parent;

  # Any element which is directly a child of a Package is also the Package
  # ( These are the package tokens themselves )
  return $parent if $parent->isa('PPI::Statement::Package');

  # Check any sibling nodes previous to the current one
  # and return the nearest Package, if present.
  my $package = identify_package_in_previous_siblings($element);
  return $package if defined $package;

  # Otherwise, recursively assume the Package of whatever your
  # parent is.
  return identify_package($parent);
}

=func identify_package_namespace

Recursively find the C<Package> as per C<identify_package> and return the
imagined name-space associated.

  my $name = identify_package_namespace( $element );

This is mostly a convenience wrapper that returns C<main> safely when no
package can be otherwise determined.

=cut

sub identify_package_namespace {
  my ($element) = @_;
  my $package = identify_package($element);

  return ( defined $package and defined $package->namespace ) ? $package->namespace : 'main';
}

=func identify_package_in_previous_siblings

Non-Recursively find a C<Package> statement that is the nearest preceding sibling
of C<$element>.

  my $package = identify_package_in_previous_siblings( $element );

Returns the nearest C<PPI::Statement::Package>, or C<undef> if none can be
found in the siblings.

=cut

sub identify_package_in_previous_siblings {
  my ($element) = @_;

  # elements without parents or children can't hold siblings
  return unless $element->can('parent') and my $parent = $element->parent;
  return unless $parent->can('children');

  my $self_addr = refaddr($element);
  my $last_package;

  for my $sibling ( $parent->children ) {

    # Record most recently found Package
    $last_package = $sibling if $sibling->isa('PPI::Statement::Package');

    # Return whatever package was found as soon as we find ourselves
    # ( Because we don't care about Packages after ourselves.
    return $last_package if $self_addr eq refaddr($sibling);
  }
  return;
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

=head1 THANKS

To L<< C<MITHALDU>|https://metacpan.org/author/MITHALDU >> for feedback
and code review on the initial design. All lurking bugs still present I can
take full credit for.
