#!/usr/bin/perl -w

use strict;
use warnings;

my $file="10_cor.txt";
open (COR, $file) or die ("Could not open file.");

while(<COR>){
	chomp;
	#print "$_\n"; # toute la ligne
	my @line=split(/:/,$_);
	print $line[0]."===".$line[1]."\n";
	
	
}
	
