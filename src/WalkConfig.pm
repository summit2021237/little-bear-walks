package WalkConfig;

use strict;
use warnings;

use DateTime;
use JSON;

sub new {
	my ($class_name, $json) = @_;
	my %walk_config = ();

	my $decoded_json = decode_json($json);
	$walk_config{decoded_json} = $decoded_json;

	$walk_config{start_date} = string_to_date($decoded_json->{walk_info}->{start_date});
	$walk_config{end_date} = string_to_date($decoded_json->{walk_info}->{end_date});
	validate_dates(\%walk_config);

	$walk_config{people_to_info} = get_people_to_info($decoded_json);

	return bless \%walk_config, $class_name;
}

sub string_to_date {
	my @date_components = split "/", $_[0];
	return DateTime->new(
		year => $date_components[2],
		month => $date_components[0],
		day => $date_components[1],
	);
}

sub validate_dates {
	if (DateTime->compare($_[0]->{start_date}, $_[0]->{end_date}) == 1) {
		die "Start date is after end date";
	}
}

sub get_people_to_info {
	my %people_to_info = ();
	foreach my $person (@{$_[0]->{people}}) {
		$people_to_info{$person->{name}} = $person;
	}
	return \%people_to_info;
}

sub get_times {
	my @times = ();
	foreach my $walk (@{$_[0]->{decoded_json}->{walk_info}->{walks}}) {
		push(@times, $walk->{time});
	}
	return \@times;
}

sub get_dates {
	my @dates = ();
	my $next_date = $_[0]->{start_date};
	while (DateTime->compare($next_date, $_[0]->{end_date}) != 1) {
		push(@dates, date_to_string($next_date));
		$next_date = $next_date->add(days => 1);
	}
	return \@dates;
}

sub date_to_string {
	my $date = $_[0]->{local_c};
	return sprintf("%02d/%02d/%04d", $date->{month}, $date->{day}, $date->{year});
}

sub get_person_names {
	my @person_names = keys(%{$_[0]->{people_to_info}});
	return \@person_names;
}

sub get_walks_not_needed {
	return $_[0]->{decoded_json}->{walk_info}->{walks_not_needed};
}

sub get_ratings_file_name {
	my $person_name = $_[1];
	return $_[0]->{people_to_info}->{$person_name}->{ratings_file};
}

1;
