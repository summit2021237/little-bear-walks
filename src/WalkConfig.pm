package WalkConfig;

use strict;
use warnings;

use JSON;

sub new {
	my ($class_name, $json) = @_;
	return bless decode_json($json), $class_name;
}

sub get_times {
	my @times = ();
	foreach my $walk (@{$_[0]->{walk_info}->{walks}}) {
		push(@times, $walk->{time});
	}
	return \@times;
}

1;
