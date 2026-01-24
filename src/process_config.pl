#1/usr/bin/perl
use strict;
use warnings;
use Data::Dumper;
use JSON;

open(my $config_file, "<", "../config.json") or die "Can't open config.json $!";
open(my $dat_file, ">", "modeling_problem.dat") or die "Can't open modeling_problem_test.dat $!";

my $config_content = do {local $/; <$config_file>};

my $config = decode_json($config_content); 

write_times();

sub write_times {
	my @times = ();
	foreach my $walk (@{$config->{walk_info}->{walks}}) {
		push(@times, $walk->{time});
	}

	write_to_dat("set Times :=");
	foreach my $time (@times) {
		write_to_dat(" $time");
	}
	write_to_dat(";\n");
}

sub write_to_dat {
	print {$dat_file} $_[0];
}
