#!/usr/bin/perl -w

# perl modif_group.pl $limit

use Net::LDAP::LDIF;

require "file.pm";

my $limit 		= 	$ARGV[0];
my $fullpath 	= 	"result/".$limit;

my $cor_file	=	$fullpath."_cor.txt";
my $re_group 	= 	file::open_file($fullpath."_group.ldif","r");
my $clean_group = 	file::open_file($fullpath."_group_clean.ldif","w");
my $group_member= 	$fullpath."_group_member.ldif";

sub count_member{
	my $entry = $_[0];
	my @array=0;
	push @array, $entry->get_value('member'); 
	return @array;
}

sub read_n_count{
	my $r_group= $_[0];
	while (not $r_group->eof() ){
		my $entry = $r_group->read_entry();
		if($entry->get_value('member',asref => 1)&& $entry){
		my $members = count_member($entry);
		open(COR_FILE, ">>".$group_member)or die('Could not open unwant File ');
		
			print COR_FILE $entry->get_value('cn')." ".$members."\n";
	
	close(COR_FILE);
		}	
	}
}

sub clean_member{
	my $entry = $_[0];
	my $uid = $_[1];
	my $nuid = $_[2];

	my @array=0;
	while($entry->exists('member')){
	if($entry->get_value('member') ~~ $uid){
		my $old_member_entry = $entry->get_value('member');
		my $new_member_entry = $old_member_entry =~ s/uid=(.*),/uid=$nuid,/r;
		$entry->replace('member'=>$new_member_entry);
			
	}else{
		$entry->delete('member'=>$entry->get_value('member'));
	}
	}
	$clean_group->write_entry($entry);
}

sub read_cor{
	
open (COR, $cor_file) or die ("Could not open file.");

while(<COR>){
	chomp;
	#print "$_\n"; # toute la ligne
	my @line=split(/:/,$_);
	my $old_uid =  $line[0];
	my $new_uid = $line[1];
	read_n_clean($old_uid,$new_uid);
	}
}

sub read_n_clean{
		my $uid= $_[0];
		my $nuid= $_[1];
		
	while (not $re_group->eof() ){
		my $entry = $re_group->read_entry();
		if($entry->get_value('member',asref => 1)&& $entry){
		clean_member($entry,$uid,$nuid);
		
		}
	}
$re_group->done();
$clean_group->done();	
}

print "start\n";
&read_cor;
print "end\n";

