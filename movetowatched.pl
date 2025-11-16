#!/usr/bin/env perl

use File::Basename;
use File::Path 'mkpath';
use File::Copy 'move';

my $dryRun = 0;
print "DRY RUN\n" if $dryRun;

my $rootPath = '/home/maqo/mercury/media/downloads/ShanaProject/';
my $WATCHED = $rootPath . 'Watched/';
my $UNWATCHED = $rootPath . 'Unwatched/';

# Takes Show, episode, (optionally season number) as ARGV
my $show = shift @ARGV;
my $episode = shift @ARGV;
my $season = shift @ARGV;
my $season ||= 1;

print "Target is $show $episode\n";

# Find matching filenames
my @filenames;
my $dir;
opendir($dir, $UNWATCHED) || die "Can't open directory [$UNWATCHED]!\n";

if ($episode eq 'next') {
	my @numbers;

	# Get list of episode numbers for title
	for (readdir($dir)) {
		$_ =~ /(\[.*\] )?(.*?) - (\d{1,3}).*/i;
		my $title = $2;
		my $ep = $3;

		next unless $title   =~ /$show/i;
		unshift @numbers, $ep;
	}

	# Sort and pick first
	@numbers = sort @numbers;
	$ep = shift @numbers;
	exit unless ($ep);
}


for (readdir($dir)) {
	$_ =~ /(\[.*\] )?(.*?) - (\d{1,3}).*/i;
	my $title = $2;
	my $ep = $3;

	next unless $title   =~ /$show/i;
	if ($episode !~ '-1') {
		next unless $ep =~ /$episode/;
	}
	unshift @filenames, $_;
}

# Do move
for (@filenames) {
	$_ =~ /\[.*\] (.*?) - (\d{1,3}).*/i;
	my $title = $1;
	my $episode = $2;

	my $new = $WATCHED
		. "$title"
		. '/'
		. "S$season"
		. "E$episode"
		. '.mkv';


	if ($dryRun) {
		print "(dry) Moving $_ to $new\n";
	} else {
		mkpath dirname($new), {mode => 0740 };
		print "Created path [" . dirname($new) . "]\n";
		$_ = $UNWATCHED . $_;
		my $foo = move "$_", "$new";
		print "Error: [$!]" unless $foo;
		print "($foo) Moved from [$_] to [$new]\n";
	}
}
