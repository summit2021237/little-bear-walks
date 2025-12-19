#!/usr/bin/perl
use strict;
use warnings;

open(my $in,  "<",  "./output/solution.txt")  or die "Can't open solution.txt: $!";
open(my $out, ">",  "./output/assignments.txt") or die "Can't open assignments.txt: $!";

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
		push @assigned_walks, @walk_info;
		print $out "$walk_info[0], $walk_info[1], $walk_info[2]\n";
	}
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
