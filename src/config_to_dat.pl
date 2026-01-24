#1/usr/bin/perl
use strict;
use warnings;

use lib "/usr/local/app/src";

use Data::Dumper;
use WalkConfig;

open(my $config_file, "<", "./config.json") or die "Can't open config.json $!";
my $config_content = do {local $/; <$config_file>};
close $config_file or die "$config_file: $!";

open(my $dat_file, ">", "./output/modeling_problem_test1.dat") or die "Can't open modeling_problem.dat $!";

my $config = WalkConfig->new($config_content);

write_sets();

write_walk_needed();

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

sub write_walk_needed {
	my @val_refs = ();
	foreach my $walks_not_needed_for_date (@{$config->get_walks_not_needed()}) {
		add_walks_not_needed_for_date(\@val_refs, $walks_not_needed_for_date);
	}
	write_multi_dim_param("WalkNeeded", @val_refs);
}

sub add_walks_not_needed_for_date {
	my $val_refs_ref = $_[0];
	my $walks_not_needed_for_date = $_[1];

	my $date = $walks_not_needed_for_date->{date};
	foreach my $time (@{$walks_not_needed_for_date->{times}}) {
		my @val = ($time, $date, 0);
		push(@$val_refs_ref, \@val);
	}
}

sub write_multi_dim_param {
	my ($name, @val_refs) = @_;
	write_to_dat("\nparam $name :=");
	foreach my $val_ref (@val_refs) {
		write_to_dat(sprintf("\n%s", join(" ", @{$val_ref})));
	}
	write_to_dat(";\n");
}

sub write_to_dat {
	print {$dat_file} $_[0];
}
