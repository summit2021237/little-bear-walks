#!/usr/bin/perl
use strict;
use warnings;

open(my $in,  "<",  "./output/solution.txt")  or die "Can't open solution.txt: $!";
open(my $out, ">",  "./output/assignments.txt") or die "Can't open assignments.txt: $!";

# Find start of assignments
while (<$in>) { # assigns each line to $_
	$_ =~ s/^\s+|\s+$//g; # remove leading and trailing whitespace from line
	if (/^Assignments.*$/) {
		<$in>;
		last;
	}
}

# Print assignments
while (<$in>) {
	$_ =~ s/^\s+|\s+$//g;
	if (!/^\(.*/) {
		last;
	}
	print $out "$_\n";
}

close $in or die "$in: $!";
close $out or die "$out: $!";
