#!/usr/bin/perl

unless($ARGV[0]) {
	die "please designate filename";
}

$indentLevel = 0;
$cdata = 0;

open FILE, "<", $ARGV[0];
open FMTED, ">", "fmted_" . $ARGV[0];

while(<FILE>) {
	chomp;
	s/>/>\n/g;
	s/([^>])</\1\n</g;

	foreach $line (split "\n", $_) {
		if($line =~ m/^\s*$/) {
			next;
		}
		$cdata = 1 if(!$cdata && $line =~ m/^<!\[CDATA/);
		if ($line =~ m/^<\// && !$cdata) {
			$indentLevel--;
		}

		for (1 .. $indentLevel) {
			 print FMTED "  ";
		}
		print FMTED $line, "\n";

		if($line =~ m/^<\w.*[^\/]>/ && !$cdata) {
			$indentLevel++;
		}

		$cdata = 0 if($cdata && $line =~ m/\]\]>$/);
	}

}

close FILE;
close FMTED;
