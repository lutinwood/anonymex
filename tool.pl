#!/usr/bin/perl -w

use strict;
use warnings;

##################"	Subroutine
sub get_file_size{
	
my $logfile="tool.log";
my $filename = "500_ldap_base.ldif";

open my $log, ">", $logfile or die "Trouble with $logfile";
	print $log system("ls","-ltr",$filename);
close ($log);
	}

sub show_log_file{
	my $logfile="tool.log";
	system("cat", $logfile);
	}

sub array_of_file{
	opendir(DOSSIER,".");
	my @new = ();
	my @entrees =readdir(DOSSIER);
	closedir(DOSSIER);
	foreach my $entrees (@entrees){
		if ($entrees =~m/x.*/){
		push(@new,$entrees);
		}
		}
	my @sorted_new = sort @new;
	return @sorted_new;
	}

sub process{
my @files = &array_of_file;
print "Begining processing ..";
while (scalar(@files)>0){
my $item = pop(@files);
print $item;
	system("sed","-f",$item,"-i","500_ldap_base.ldif");
	system("cp","500_ldap_base.ldif","500_ldap_base.ldif_".$item);
	&get_file_size();
	print scalar(@files);
	}
print "END";
}

#################	CALLS

&process();
#&get_file_size();
#print scalar(&array_of_file);
#&show_log_file();
