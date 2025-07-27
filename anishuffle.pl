#!/usr/bin/env perl

# Gotta fish somewthing with yofukashi

use File::Basename;
use File::Path 'mkpath';
use File::Copy 'move';

my $weeb = {
	# Summer 2025
	'City the Animation'					=> {},
	'Game Center Shoujo to Ibunka Kouryuu'	=> {name=>'Cultural Exchange with a Game Centre Girl',  },
	'Kaoru Hana wa Rin to Saku'				=> {name=>'The Fragrant Flower Blooms with Dignity',    },
	'New Panty and Stocking with Garterbelt'=> {name=>'new PANTY & STOCKING with GARTERBELT',       }, 
	'Yofukashi no Uta Season 2'				=> {name=>'Yofukashi no Uta', year=>'2022', season=>'2'},
	'Turkey!'								=> {name=>'Turkey! Time to Strike',                     },
	'Ruri no Houseki'						=> {name=>'Ruri Rocks'},
	'Silent Witch: Chinmoku no Majo no Kakushigoto' => {name=>'Secrets of the Silent Witch'},
};

my $WATCHED_PATH = '/home/maqo/mercury/media/downloads/ShanaProject/Watched/';
my $DESTINATION_PATH = '/home/maqo/mercury/media/shows/';


my $watched;
opendir($watched, $WATCHED_PATH) || die "Can't open directory [$WATCHED_PATH]!\n";

for my $showPath (readdir($watched)) {
	next if substr($showPath, '0', 1) eq '.';
	my $showName = $showPath;
	print "Fooname is $showName\n";
	# $showName =~ s#.*/(.*)#$1#;
	next unless $showName;

	$weeb->{$showName}->{name} ||= $showName;

	my @times = localtime();
	# print join '.',@times;
	$weeb->{$showName}->{year} ||= 1900 + ($times[5]);
	$weeb->{$showName}->{season} ||= 1;
	my $newSeason = $weeb->{$showName}->{season};

	print "Initial name is [$showName]\n";
	$showName = $weeb->{$showName}->{name} . ' (' . $weeb->{$showName}->{year} . ')';
	print "becomes [$showName]\n";
	my $destShow = "$DESTINATION_PATH/$showName";

	# For each in a list of episode files
	my $epfn;
	my $epfndir = "$WATCHED_PATH/$showPath/";
	print "Opening [$epfndir]\n";
	opendir($epfn, "$epfndir") || die "Can't open directory [$epfndir]!\n";
	my $destPath = "$DESTINATION_PATH/$showName/Season " . $newSeason . "/";
	mkpath $destPath, { mode => 0770 };

	for my $fn (readdir($epfn)) {
		next if substr($fn, '0', 1) eq '.';
		my $destfn = $fn;
		$fn = "$epfndir/$fn";
		$destfn =~ s/(S\d+)/S$newSeason/;
		$destPath .= $destfn;
		print "$fn -> $destPath\n";
		move $fn, "$destPath";
	}
}

#`kodi-send --action="updatelibrary(video)"`

