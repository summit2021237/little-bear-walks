#!/usr/bin/perl
use strict;
use warnings;

open(my $in,  "<",  "./output/solution.txt")  or die "Can't open solution.txt: $!";
open(my $out, ">",  "./output/assignments.csv") or die "Can't open assignments.txt: $!";

my %date_set;
my %morning_walks;
my %midday_walks;
my %afternoon_walks;
find_start_of_assignments();
add_assignments_to_hashes(add_assigned_walks());
write_to_csv();

close $in or die "$in: $!";
close $out or die "$out: $!";

sub find_start_of_assignments {
	while (<$in>) {
		$_ = trim_whitespace($_);
		if (/^Assignments.*$/) {
			<$in>;
			last;
		}
	}
}

sub add_assigned_walks {
	my @assigned_walks;
	while (<$in>) {
		$_ = trim_whitespace($_);
		last if (!/^\(.*/);

		my @columns = split /:/;
		next if (!is_assigned($columns[2]));

		push @assigned_walks, parse_walk_info($columns[0]);
	}
	return \@assigned_walks;
}

sub is_assigned {
		my $is_assigned = trim_whitespace($_[0]);
		return $is_assigned eq "1.0";
}

sub parse_walk_info {
	my @walk_info = map {extract_single_quote_val($_)} (split /,/, $_[0]);
	return \@walk_info;
}

sub extract_single_quote_val {
	my $val = $_[0];
	$val =~ s/^[^']*\'|\'[^']*$//g;
	return $val;
}

sub trim_whitespace {
	my $val = $_[0];
	$val =~ s/^\s+|\s+$//g;
	return $val;
}

sub add_assignments_to_hashes {
	foreach my $assigned_walk (@{$_[0]}) {
		my ($time, $date, $person) = @{$assigned_walk};
		$date_set{$date} = 1;
		if ($time eq "Morning") {
			$morning_walks{$date} = $person;
		} elsif ($time eq "Midday") {
			$midday_walks{$date} = $person;
		} elsif ($time eq "Afternoon") {
			$afternoon_walks{$date} = $person;
		}
	}
}

sub write_to_csv {
	foreach my $date (sort (keys %date_set)) {
		print $out "$date";
		write_person(\%morning_walks, $date);
		write_person(\%midday_walks, $date);
		write_person(\%afternoon_walks, $date);
		print $out "\n";
	}
}

sub write_person {
	my %walks_for_time = %{$_[0]};
	if (exists $walks_for_time{$_[1]}) {
		print $out ",$walks_for_time{$_[1]}";
	} else {
		print $out ",N/A";
	}
}
