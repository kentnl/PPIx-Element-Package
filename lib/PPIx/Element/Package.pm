use 5.006;    # our
use strict;
use warnings;

package PPIx::Element::Package;

our $VERSION = '0.001000'; # TRIAL

# ABSTRACT: Derive the package an element is defined in

our $AUTHORITY = 'cpan:KENTNL'; # AUTHORITY

use Scalar::Util qw( refaddr );

our @EXPORT_OK = qw( find_package );









sub find_package {
  my ($token) = @_;
  if ( $token->isa('PPI::Statement::Package') ) {
    return $token;
  }
  return unless $token->can('parent') and defined $token->parent;
  my $parent = $token->parent;
  if ( $parent->isa('PPI::Statement::Package') ) {
    return $parent;
  }
  return find_package($parent) unless $parent->can('children');
  my (@all_siblings) = $parent->children();
  my (@previous_siblings);
  my $self_addr = refaddr($token);
  for my $sibling (@all_siblings) {
    last if $self_addr eq refaddr $sibling;
    push @previous_siblings, $sibling;
  }
  for my $previous_sibling ( reverse @previous_siblings ) {
    return $previous_sibling if $previous_sibling->isa('PPI::Statement::Package');
  }
  return find_package($parent);
}

{
  use PPI::Element;
  package    # Hide From PAUSE
    PPI::Element;











  sub x_package {
    my ($self) = @_;
    return PPIx::Element::Package::find_package($self);
  }











  sub x_package_namespace {
    my ($self) = @_;
    my $package = $self->x_package;
    return 'main' unless defined $package;
    return 'main' unless defined $package->namespace;
    return $package->namespace;
  }
}

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

PPIx::Element::Package - Derive the package an element is defined in

=head1 VERSION

version 0.001000

=head1 SYNOPSIS

  use PPI;
  use PPIx::Element::Package;

  # Do your normal PPI stuff here.

  # Get the logical enclosing package or undef if one cannot be discovered
  my $package = $element->x_package;

  # Get the name of the logical enclosing package, or main if one cannot be discovered
  my $namespace = $element->x_package_namespace;

=head1 DESCRIPTION

This module aims to determine the scope any L<< C<PPI::Element>|PPI::Element >>
( which includes L<< C<Nodes>|PPI::Node >> and L<< C<Tokens>|PPI::Token >> ) is defined in.

It adds two utility methods on the C<PPI::Element> class as follows:

=over 4

=item C<x_package> - The Logical L<<
C<PPI::Statement::Package>|PPI::Statement::Package
>> that owns the C<Element>

=item C<x_package_namespace> - The name-space of the logical C<<
PPI::Statement::Package >> that owns the element.

=back

The latter of these is just a convenience wrapper on top of C<x_package> that
returns C<main> when either the owning C<Statement::Package> cannot be found,
or when the owning C<Statement::Package>'s name-space is somehow undefined.

=head1 Extension Methods

=head2 x_package

Find the logical "owner" package of an C<Element>

  my $package = $element->x_package;

Returns C<undef> if one cannot be found.

=head2 x_package_namespace

Find the name-space of the logical owner package.

  my $package = $element->x_package_namespace;

Returns C<main> if one cannot be found, or one can be found and its C<namespace> value is not defined.

=head1 FUNCTIONS

=head2 find_package

Call this function if you want to avoid using the C<x_> functions on the elements themselves.

  my $package = PPIx::Element::Package::find_package( $element );

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

=head1 AUTHOR

Kent Fredric <kentnl@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2015 by Kent Fredric <kentfredric@gmail.com>.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
