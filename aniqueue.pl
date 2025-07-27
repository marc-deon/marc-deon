#!/usr/bin/env perl
use v5.36;
use IO::Socket::INET;

my $PORT = 2081;
my $ADDR = '192.168.1.2';
my $buff = "";
my $dir;
my @filenames;

my $DOWNLOADS = "/home/maqo/mercury/media/downloads/ShanaProject/Unwatched/";
my $SHOWS = "/home/maqo/mercury/media/shows/";

sub trim {
    $_[0] =~ s/^\s+|\s+$//g;
 }

my $sock = IO::Socket::INET->new(
	LocalAddr => $ADDR,
    LocalPort => $PORT,
    Proto     => 'tcp',
	Listen	  => 4,
) or die("$!\n");
die("No socket!\n") unless $sock;
#print "Socket good!\n";

MAIN: while (1) {
	#say "Waiting...";
	my $peer = $sock->accept();
	my $ph = $peer->peerhost();
	my $pp = $peer->peerport();

	#say "Connection from $ph:$pp";

	$$peer->recv($buff, 1024);

	my ($cmd, $show, $episode) = split (/,/, $buff, 3);
	trim $cmd; trim $show; trim $episode;
	$show = lc $show;
	say "[$cmd][$show][$episode]";

	if ($cmd =~ 'list') {
		unless (opendir($dir, $DOWNLOADS)) {
			peer->send("Could not open downloads directory");
			$peer->shutdown(SHUT_WR);
			die;
		}
		my @files = readdir($dir);
		#@files = sort @files;

		my $s = "";
		for (@files) {
			next if substr($_, '0', 1) eq '.';
			$_ =~ /\[.*\] (.*?) - (\d{1,3}).*/i;
			$s .= "$1, E$2\n";
		}
	
		say "Sending $s";
		$peer->send($s);
		$peer->shutdown(SHUT_WR);
	}

	elsif ($cmd =~ 'file') {
		unless ($show && $episode) {
			$peer->send("ERR: Need show and episode: [$show] [$episode]");
			$peer->shutdown(SHUT_WR);
			next;
		}
		#say "Searching for [$show] [$episode]";

		unless (opendir($dir, $DOWNLOADS)) {
			peer->send("Could not open downloads directory");
			$peer->shutdown(SHUT_WR);
			die;
		}

		for (readdir($dir)) {
			next if substr($_, '0', 1) eq '.';
			#say "Checking $_";
			$_ =~ /\[.*\] (.*?) - (\d{1,3}).*/i;
			my $s = lc $1;
			my $e = lc $2;
			#say "[$s] [$e]";
			next unless $s && $e;

			next unless $s =~ $show;
			next unless $e =~ $episode;
			$peer->send($DOWNLOADS . $_);
			say "Sending" . $DOWNLOADS . $_;
			$peer->shutdown(SHUT_WR);
			closedir($dir);
			next MAIN;
		}

		#say "Couldn't find";
		$peer->send("ERR: Couldn't find");
	}
}

#say "End";

