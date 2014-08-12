package Process::Async::Manager;

use strict;
use warnings;

use parent qw(IO::Async::Notifier);

=head1 NAME

Process::Async::Manager - handle async background process

=head1 SYNOPSIS

 my $pm = Process::Async::Manager->new;
 my $child = $pm->spawn(
  worker_class => 'Some::Worker::Class',
 );
 $child->stdio->write('start');

=head1 DESCRIPTION

=head1 METHODS

=cut

=head2 configure

Applies our configuration. Currently accepts:

=over 4

=item * worker_class - the name of the subclass used for instantiating a worker

=item * child_class - (optional) child subclass name, uses 'Process::Async::Child'
by default

=back

=cut

sub configure {
	my ($self, %args) = @_;
	$self->{worker_class} = delete $args{worker_class} if exists $args{worker_class};
	$self->{child_class} = delete $args{child_class} if exists $args{child_class};
	$self->SUPER::configure(%args);
}

=head2 spawn

Spawn a child. Returns a L<Process::Async::Child> instance.

=cut

sub spawn {
	my ($self) = @_;

	# Use the same loop subclass in the child process as we're using
	my $loop_class = ref($self->loop);
	my $worker_class = $self->worker_class;
	my $child_class = $self->child_class || 'Process::Async::Child';

	my $child = $child_class->new;

	# Provide the code and a basic STDIO handler
	$child->configure(
		stdio => {
			via => 'pipe_rdwr',
			on_read => $child->curry::weak::on_read,
		},
		code => sub {
			# (from here, we're in the fork)
			my $loop = $loop_class->new;
			$loop->add(
				my $worker = $worker_class->new
			);
			$worker->run($loop);
		}
	);
	$self->add_child($child);
}

1;

__END__

=head1 AUTHOR

Tom Molesworth <cpan@perlsite.co.uk>

=head1 LICENSE

Copyright Tom Molesworth 2014. Licensed under the same terms as Perl itself.

