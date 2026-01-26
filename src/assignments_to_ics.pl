#1/usr/bin/perl
use strict;
use warnings;

use lib "/usr/local/app/src";
# use open qw(:std :encoding(UTF-8));
# use utf8;

use DateTime;
use WalkConfig;

my $app_name = "little-bear-walks";
my $config = create_config();

open(my $in, "<", "./output/assignments.csv") or die "Can't open assignments.csv: $!";

my @names = @{$config->get_person_names()};
my @times = @{$config->get_times()};

my %outs = %{create_output_files()};

while (<$in>) {
	add_events_for_day();
}

close_files();

sub create_config {
	open(my $config_file, "<", "./config.json") or die "Can't open config.json $!";
	my $config_content = do {local $/; <$config_file>};
	close $config_file or die "$config_file: $!";
	return $config = WalkConfig->new($config_content);
}

sub create_output_files {
	my %outs = ();
	foreach my $name (@names) {
		 open(my $out, ">:utf8", "./output/$name.ics") or die "Can't open $name.ics: $!";
		 $outs{$name} = \$out;
		 start_file(\$out);
	}
	return \%outs;
}

sub start_file {
	my $out = $_[0];
	my $current_time = time();
	print {${$out}} "BEGIN:VCALENDAR\nVERSION:2.0\nPRODID:$app_name-$current_time}\n";
}

sub add_events_for_day {
	my @columns = split /,/;
	my $date = string_to_date($columns[0]);
	for (my $i = 0; $i < scalar(@times); $i++) {
		my $name = trim_whitespace($columns[$i + 1]);
		add_event_for_time($date, $times[$i], $name);
	}
}

sub string_to_date {
	my @date_components = split "/", $_[0];
	return DateTime->new(
		year => $date_components[2],
		month => $date_components[0],
		day => $date_components[1],
	);
}

sub trim_whitespace {
	my $val = $_[0];
	$val =~ s/^\s+|\s+$//g;
	return $val;
}

sub add_event_for_time {
	my ($datetime, $time, $name) = @_;
	my $date = $datetime->{local_c};
	my $dtstart = create_dtstart($date, $time, $name);
	my $duration = sprintf("PT%dM", $config->get_duration($time));
	add_event({
			name => $name,
			dtstart => $dtstart,
			duration => $duration,
			summary => $config->get_event_name($name, $time),
		}
	);
}

sub create_dtstart {
	my ($date, $time, $name) = @_;
	my ($hour, $minute) = split(":", $config->get_event_time($name, $time));
	return create_datetime_string({
			year => $date->{year},
			month => $date->{month},
			day => $date->{day},
			hour => $hour,
			minute => $minute,
			second => 0,
		});
}

sub add_event {
	last if $_[0]->{name} eq "N/A";
	my $current_time = DateTime->now();
	my $dtstamp = create_datetime_string($current_time->{local_c});
	my $uid = $app_name . "-" . $_[0]->{dtstart} . "-" . $dtstamp;
	print {${$outs{$_[0]->{name}}}} "BEGIN:VEVENT\nUID:$uid\nDTSTAMP:$dtstamp\nDTSTART:$_[0]->{dtstart}\nDURATION:$_[0]->{duration}\nSUMMARY:$_[0]->{summary}\nEND:VEVENT\n";
}

sub create_datetime_string {
	my $date = $_[0];
	return sprintf("%04d%02d%02dT%02d%02d%02d", $date->{year}, $date->{month}, $date->{day}, $date->{hour}, $date->{minute}, $date->{second});
}

sub end_file {
	my $name = $_[0];
	print {${$outs{$name}}} "END:VCALENDAR\n";
}

sub close_files {
	foreach my $name (@names) {
		 end_file($name);
		 close_output($name);
	}
	close $in or die "$in: $!";
}

sub close_output {
	close ${$outs{$_[0]}} or die "$outs{$_[0]}: $!";
}
