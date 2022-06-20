package CGI::Capture::TieSTDIN;

# Small class for replacing STDIN with a provided string

use 5.006;
use strict;
use warnings;

our $VERSION = '1.16';

sub TIEHANDLE {
	my $class  = shift;
	my $string = shift;
	return bless {
		string => $string,
	};
}

sub READ {
	my $self   = shift;
	my $string = $self->{string};
	if ( !defined($string) || $$string eq '' ) {
		$_[0] = undef;
		return 0;
	}
	my (undef, $length, $offset) = @_;
	$offset = 0		if (!defined($offset));
	my $buffer = substr( $$string, $offset, $length, '' );
	my $rv     = length $buffer;
	$_[0]      = $buffer;
	return $rv;
}

sub READLINE {
	my $self   = shift;
	my $string = $self->{string};
	if ( !defined($string) || $$string eq '' ) {
		return undef;
	}
	if ( wantarray ) {
		my @lines = split /(?<=\n)/, $$string;
		$$string = '';
		return @lines;
	} else {
		if ( $$string =~ s/^(.+?\n)//s ) {
			return "$1";
		} else {
			my $rv = $$string;
			$$string = '';
			return $rv;
		}
	}
}

sub CLOSE {
	my $self = shift;
	return close $self;
}

1;
