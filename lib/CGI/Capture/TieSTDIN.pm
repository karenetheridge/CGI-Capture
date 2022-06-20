package CGI::Capture::TieSTDIN;

# Small class for replacing STDIN with a provided string

use 5.006;
use strict;
use warnings;

our $VERSION = '1.16';

sub TIEHANDLE {
	my $class  = shift;
	my $string_ref = shift;
	return bless {
		string_ref => $string_ref,
	};
}

sub READ {
	my $self   = shift;
	if ( !defined($self->{string_ref}) || ${$self->{string_ref}} eq '' ) {
		$_[0] = undef;
		return 0;
	}
	my ($string, $length, $offset) = @_;
	$offset = 0		if (!defined($offset));
	my $buffer = substr(${$self->{string_ref}}, $offset, $length, '');
	my $rv     = length $buffer;
	$_[0]      = $buffer;
	return $rv;
}

sub READLINE {
	my $self   = shift;
	my $string_ref = $self->{string_ref};
	if ( !defined($string_ref) || $$string_ref eq '' ) {
		return undef;
	}
	if ( wantarray ) {
		my @lines = split /(?<=\n)/, $$string_ref;
		$$string_ref = '';
		return @lines;
	} else {
		if ( $$string_ref =~ s/^(.+?\n)//s ) {
			return $1;
		} else {
			my $rv = $$string_ref;
			$$string_ref = '';
			return $rv;
		}
	}
}

sub CLOSE {
	my $self = shift;
	return close $self;
}

1;
