package again;
use strict;
use warnings;
use 5.006;
use Carp;

our $VERSION = '0.06';

my %mtimes;

sub require_again {
    @_ == 0 and croak 'Not enough arguments for require_again';
    @_ >  1 and croak 'Too many arguments for require_again';
    my $module = shift;
    (my $file = "$module.pm") =~ s[::][/]g;
    if (not exists $INC{$file} or -M $INC{$file} < $mtimes{$INC{$file}}) {
        delete $INC{$file};
        require $file;
        $mtimes{$INC{$file}} = -M $INC{$file};
    }
}

sub use_again {
    croak '"use_again" should be "use again"';
}

sub use {
    my $method = shift;
    $_[0] or croak 'Not enough arguments for use again';
    require_again($_[0]);
    if (@_ == 2 and ref $_[1] eq 'ARRAY') {
        return if @{ $_[1] } == 0;
        splice @_, 1, 1, @{ $_[1] };
    }
    goto $_[0]->can($method) || return;
}

sub import {
    if (@_ > 1) {
        splice @_, 0, 1, 'import';
        goto &use;
    }
    no strict 'refs';
    *{caller() . "::use_again"} = \&use_again;
    *{caller() . "::require_again"} = \&require_again;
}

sub unimport {
    splice @_, 0, 1, 'unimport';
    goto &use;
}

1;

=head1 NAME

again - Reload modules when they change

=head1 SYNOPSIS

 use again 'LWP::Simple';             # default import
 use again 'LWP::Simple', [];         # no import
 use again 'LWP::Simple', [qw(get)];  # import only get
    
 use again 'LWP::Simple', ();         # default import (!!)
 use again 'LWP::Simple', qw(get);    # import only get
    
 use again;
 require_again 'Foo::Bar';

=head1 DESCRIPTION

When the perl interpreter lives for a long time, modules are likely to change
during its lifetime. Especially for mod_perl applications, this module comes in
handy.

=head2 Usage

=over

=item C<use again;>

A bare C<use again;> (that is: no import list) will export C<require_again>
(and C<use_again>, which always croaks saying you should use C<use again>
instead) into your namespace. There is no convenient way to import 
C<require_again> without importing C<use_again> too.

=item C<use again MODULE, [ IMPORTS ];>

If you do pass arguments, the first is used with C<require_again>, and all
remaining arguments are used to import symbols into your namespace.

When given arguments, C<use again> does not export its own functions.

A single array reference is flattened. If that arrayref contains no elements,
the import does not take place.

In mod_perl scripts, this of course only happens when your script is C<eval>ed.
This happens when your Apache::Registry or Apache::PerlRun script changes, or
when your PLP script is requested.

=item C<require_again MODULE;>

This is the driving force behind C<again.pm>. It C<require>s your module if it
has not been loaded with C<require_again> before or it has changed since the
last time C<require_again> loaded it.

If you're imported a function from the module,
then you'll need to re-import it after calling C<require_again>:

 use again 'Module::Path', qw(module_path);

 ... do some stuff ...

 require_again('Module::Path');
 Module::Path->import('module_path');

If you don't do this then you'll end up running the version of the
function that you first loaded.

=back

=head1 SEE ALSO

L<Module::Reload> provides a class method which checks all
loaded modules to see if the file on disk has changed since the module
was loaded. It was last updated in 1998, and I haven't tested it.

L<Class::Unload> unloads a class, by clearing out its symbol table
and removing it from C<%INC>.

L<Padre::Unload> is part of the L<Padre> IDE. It's similar to Class::Unload,
but says it has "a few more tricks up its sleeve". It's not documented though,
so just intended for internal use in Padre.

=head1 REPOSITORY

L<https://github.com/neilbowers/again>

=head1 LICENSE

There is no license. This software was released into the public domain.
Do with it what you want, but on your own risk. The author disclaims any
responsibility.

If you want to (re)distribute this module and need a license,
you can redistribute it and/or modify it under the same terms as Perl itself.

=head1 AUTHOR

Juerd Waalboer E<lt>juerd@cpan.orgE<gt> E<lt>http://juerd.nl/E<gt>

Documentation updates from Neil Bowers.

=cut
