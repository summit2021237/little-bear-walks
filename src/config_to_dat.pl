#1/usr/bin/perl
use strict;
use warnings;

use lib "/usr/local/app/src";

use Data::Dumper;
use WalkConfig;

open(my $config_file, "<", "./config.json") or die "Can't open config.json $!";
my $config_content = do {local $/; <$config_file>};
close $config_file or die "$config_file: $!";

my $config = WalkConfig->new($config_content);
print Dumper($config);
