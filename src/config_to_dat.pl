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

close $dat_file or die "$dat_file $!";

sub write_sets {
	write_times();
}

sub write_times{
	write_to_dat("set Times :=");
	foreach my $time (@{$config->get_times()}) {
		write_to_dat(" $time");
	}
	write_to_dat(";\n");
}

sub write_to_dat {
	print {$dat_file} $_[0];
}
