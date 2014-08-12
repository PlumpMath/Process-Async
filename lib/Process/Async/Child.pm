package Process::Async::Child;

use strict;
use warnings;

use parent qw(IO::Async::Process);

=head1 NAME

Process::Async::Child -

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 METHODS

=cut

sub on_read {
	my ($self, $stream, $buffref, $eof) = @_;
	while($$buffref =~ s/^(.*)\n//) {
		my ($k, $data) = split ' ', $1, 2;
		if(my $method = $self->can('cmd_' . $k)) {
			$method->($self, $data);
		} else {
			$self->on_command(
				$k => $data
			);
		}
	}
	warn "Closed input" if $eof;
	return 0
}

sub on_finish {
	warn "finished?";
}

1;

__END__

=head1 SEE ALSO

=head1 AUTHOR

Tom Molesworth <cpan@perlsite.co.uk>

=head1 LICENSE

Copyright Tom Molesworth 2014. Licensed under the same terms as Perl itself.

