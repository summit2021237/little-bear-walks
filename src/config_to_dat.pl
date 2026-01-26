#1/usr/bin/perl
use strict;
use warnings;

use lib "/usr/local/app/src";

use Data::Dumper;
use Text::CSV;
use WalkConfig;

open(my $config_file, "<", "./config.json") or die "Can't open config.json $!";
my $config_content = do {local $/; <$config_file>};
close $config_file or die "$config_file: $!";

open(my $dat_file, ">", "./data/modeling_problem.dat") or die "Can't open modeling_problem.dat $!";

my $config = WalkConfig->new($config_content);

write_sets();
write_params();

close $dat_file or die "$dat_file $!";

sub write_sets {
	write_set("Times", @{$config->get_times()});
	write_set("Dates", @{$config->get_dates()});
	write_set("People", @{$config->get_person_names()});
}

sub write_set {
	my ($name, @items) = @_;
	write_to_dat("set $name :=");
	foreach my $item (@items) {
		write_to_dat(" $item");
	}
	write_to_dat(";\n");
}

sub write_params {
	write_walk_needed();
	write_ratings();
	write_lengths();
	write_max_walk_frac();
	write_all_walk_factor();
}

sub write_walk_needed {
	my @val_refs = ();
	foreach my $walks_not_needed_for_date (@{$config->get_walks_not_needed()}) {
		add_walks_not_needed_for_date(\@val_refs, $walks_not_needed_for_date);
	}
	write_multi_dim_param("WalkNeeded", @val_refs);
}

sub add_walks_not_needed_for_date {
	my ($val_refs_ref, $walks_not_needed_for_date) = @_;
	my $date = $walks_not_needed_for_date->{date};
	foreach my $time (@{$walks_not_needed_for_date->{times}}) {
		push(@{$val_refs_ref}, [$time, $date, 0]);
	}
}

sub write_ratings {
	my @val_refs = ();
	foreach my $person_name (@{$config->get_person_names()}) {
		add_ratings_for_person(\@val_refs, $person_name);
	}
	write_multi_dim_param("Ratings", @val_refs);
}

sub add_ratings_for_person {
	my ($val_refs_ref, $person_name) = @_;

	my $csv = Text::CSV->new({
			binary => 1,
			auto_diag => 1
		});

	my $file_name = $config->get_ratings_file_name($person_name);
	open(my $ratings_file, "<", sprintf("./data/%s", $file_name)) or die "Can't open $file_name $!";

	$csv->getline($ratings_file); # skip header

	while (my $data = $csv->getline($ratings_file)) {
		add_ratings_for_person_for_date($val_refs_ref, $person_name, $data);
	}

	close $ratings_file or die "$ratings_file $!";
}

sub add_ratings_for_person_for_date {
	my ($val_refs_ref, $person_name, $data) = @_;

	my $date = "";
	if ($data->[0] =~ /([0-9]{2}\/[0-9]{2}\/[0-9]{4})/) {
		$date = $1;
	}

	my @times = @{$config->get_times()};
	for (my $i = 0; $i < scalar(@times); $i++) {
		if (is_valid_rating($data->[$i + 1])) {
			push(@{$val_refs_ref}, [$times[$i], $date, $person_name, $data->[$i + 1]]);
		}
	}
}

sub is_valid_rating {
	return $_[0] >= 0 && $_[0] <= 9;
}

sub write_lengths {
	my @val_refs = ();
	foreach my $time (@{$config->get_times()}) {
		push(@val_refs, [$time, $config->get_length($time)]);
	}
	write_multi_dim_param("Lengths", @val_refs);
}

sub write_multi_dim_param {
	my ($name, @val_refs) = @_;

	if (scalar(@val_refs) == 0) {
		return;
	}

	write_to_dat("\nparam $name :=");
	foreach my $val_ref (@val_refs) {
		write_to_dat(sprintf("\n%s", join(" ", @{$val_ref})));
	}
	write_to_dat(";\n");
}

sub write_max_walk_frac {
	my $val = 1;
	if ($config->is_evenly_distributed()) {
		$val = calc_max_walk_frac();
	} else {
		# TODO: add support for different percentages for each person
	}
	write_one_dim_param("MaxWalkFrac", $val);
}

sub calc_max_walk_frac {
	return 1/scalar(@{$config->get_person_names()})+.01; # allow for a small difference between the total amount of time for each person
}

sub write_all_walk_factor {
	write_one_dim_param("AllWalkFactor", $config->get_all_walk_factor());
}

sub write_one_dim_param {
	my ($name, $val) = @_;
	write_to_dat("\nparam $name := $val;\n");
}

sub write_to_dat {
	print {$dat_file} $_[0];
}
