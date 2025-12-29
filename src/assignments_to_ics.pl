#1/usr/bin/perl
use strict;
use warnings;
use DateTime;
use Data::Dumper;

open(my $in, "<", "./output/assignments.csv") or die "Can't open assignments.csv: $!";

my @names = ();
my %outs = ();
foreach my $name (@names) {
	 open(my $out, ">", "./output/$name.ics") or die "Can't open $name.ics: $!";
	 $outs{$name} = \$out;
	 start_file($name);
}

foreach my $name (@names) {
	 end_file($name);
}

while (<#in>) {
	my @columns = split /,/;
	my $date = $columns[0];
}

sub start_file {
	my $name = $_[0];
	my %current_time = %{DateTime->now()->{local_c}};
	print {${$outs{$name}}} "BEGIN:VCALENDAR\nVERSION:2.0\nPRODID:little-bear-walks-$current_time{year}$current_time{month}$current_time{day}$current_time{hour}$current_time{minute}$current_time{second}\n";
}

sub end_file {
	my $name = $_[0];
	print {${$outs{$name}}} "END:VCALENDAR\n";
}
