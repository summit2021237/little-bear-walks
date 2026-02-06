#1/usr/bin/perl
use strict;
use warnings;
use DateTime;
use JSON;
use POSIX;

open(my $config_file, "<", "../config.json") or die "Can't open config.json $!";
open(my $dat_file, ">", "modeling_problem_test1.dat") or die "Can't open modeling_problem_test.dat $!";

my $config_content = do {local $/; <$config_file>};

my $config = decode_json($config_content); 

my @people = @{$config->{people}};

write_sets();

write_walk_needed();
write_lengths();
write_max_walk_portion();
write_all_walk_multiplier();

sub write_sets {
	write_times();
	write_dates();
	write_people();
}

sub write_times {
	write_to_dat("set Times :=");
	foreach my $walk (@{$config->{walk_info}->{walks}}) {
		write_to_dat(" $walk->{time}");
	}
	write_to_dat(";\n");
}

sub write_dates {
	my $start_date = string_to_date($config->{walk_info}->{start_date});
	my $end_date = string_to_date($config->{walk_info}->{end_date});
	if (DateTime->compare($start_date, $end_date) == 1) {
		die "Start date is after end date";
	}

	write_to_dat("set Dates :=");
	my $next_date = $start_date;
	while (DateTime->compare($next_date, $end_date) != 1) {
		write_to_dat(" " . date_to_string($next_date));
		$next_date = $next_date->add(days => 1);
	}
	write_to_dat(";\n");
}

sub string_to_date {
	my @date_components = split "/", $_[0];
	return DateTime->new(
		year => $date_components[2],
		month => $date_components[0],
		day => $date_components[1],
	);
}

sub date_to_string {
	my $date = $_[0]->{local_c};
	return sprintf("%02d/%02d/%04d", $date->{month}, $date->{day}, $date->{year});
}

sub write_people {
	write_to_dat("set People :=");
	foreach my $person (@people) {
		write_to_dat(" $person->{name}");
	}
	write_to_dat(";\n");
}

sub write_walk_needed {
	write_to_dat("\n");
	write_to_dat("param WalkNeeded :=");
	my @walks_not_needed_for_dates = @{$config->{walk_info}->{walks_not_needed}};
	foreach my $walks_not_needed_for_date (@walks_not_needed_for_dates) {
		my $date = $walks_not_needed_for_date->{date};
		foreach my $time (@{$walks_not_needed_for_date->{times}}) {
			write_to_dat(sprintf("\n%s %s 0", $time, $date));
		}
	}
	write_to_dat(";\n");
}

sub write_max_walk_portion {
	write_to_dat("\nparam MaxWalkPortion := ");
	if ($config->{other_model_values}->{evenly_distribute}) {
		write_to_dat(calc_max_walk_portion());
	} else {
		write_to_dat($config->{other_model_values}->{max_walk_portion});
	}
	write_to_dat(";\n");
}

sub calc_max_walk_portion {
	return 1/scalar(@people)+.01; # allow for a small difference between the total amount of time for each person
}

sub write_all_walk_multiplier {
	write_to_dat("\nparam AllWalkMultiplier := $config->{other_model_values}->{all_walk_multiplier};\n");
}

sub write_lengths {
	write_to_dat("\n");
	write_to_dat("param Lengths :=");
	foreach my $walk (@{$config->{walk_info}->{walks}}) {
		write_to_dat("\n$walk->{time} $walk->{duration}");
	}
	write_to_dat(";\n");
}

sub write_to_dat {
	print {$dat_file} $_[0];
}
