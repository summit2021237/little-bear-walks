#!/usr/bin/perl
use strict;
use warnings;
use feature qw(switch);

open(my $in,  "<",  "./output/solution.txt")  or die "Can't open solution.txt: $!";
open(my $out, ">",  "./output/assignments.csv") or die "Can't open assignments.txt: $!";

# Find start of assignments
while (<$in>) { # assigns each line to $_
	$_ = trim_whitespace($_);
	if (/^Assignments.*$/) {
		<$in>;
		last;
	}
}

# Add assigned walks to list
my @assigned_walks;
while (<$in>) {
	$_ = trim_whitespace($_);
	if (!/^\(.*/) {
		last;
	}

	my @columns = split /:/;
	my $is_assigned = $columns[2];
	$is_assigned = trim_whitespace($is_assigned);
	if ($is_assigned eq "1.0") {
		my @walk_info = split /,/, $columns[0];
		@walk_info = map {extract_single_quote_val($_)} @walk_info;
		push @assigned_walks, [$walk_info[0], $walk_info[1], $walk_info[2]];
	}
}

# Add assignments to hashes
my %date_set;
my %morning_walks;
my %midday_walks;
my %afternoon_walks;
foreach my $assigned_walk (@assigned_walks) {
	$date_set{$assigned_walk->[1]} = 1;
	if ($assigned_walk->[0] eq "Morning") {
		$morning_walks{$assigned_walk->[1]} = $assigned_walk->[2];
	} elsif ($assigned_walk->[0] eq "Midday") {
		$midday_walks{$assigned_walk->[1]} = $assigned_walk->[2];
	} elsif ("Afternoon") {
		$afternoon_walks{$assigned_walk->[1]} = $assigned_walk->[2];
	}
}

# Write to assignments file
foreach my $date (sort (keys %date_set)) {
	print $out "$date";
	write_person(\%morning_walks, $date);
	write_person(\%midday_walks, $date);
	write_person(\%afternoon_walks, $date);
	print $out "\n";
}

close $in or die "$in: $!";
close $out or die "$out: $!";

sub trim_whitespace {
	my $val = $_[0];
	$val =~ s/^\s+|\s+$//g;
	return $val;
}

sub extract_single_quote_val {
	my $val = $_[0];
	$val =~ s/^[^']*\'|\'[^']*$//g;
	return $val;
}

sub write_person {
	my %walks_for_time = %{$_[0]};
	if (exists $walks_for_time{$_[1]}) {
		print $out ",$walks_for_time{$_[1]}";
	} else {
		print $out ",N/A";
	}
}
