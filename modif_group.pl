#!/usr/bin/perl -w

use Net::LDAP::LDIF;

require "file.pm";

sub count_member{
	my $entry = $_[0];
	my @array=0;
	push @array, $entry->get_value('member'); 
	return @array;
}

sub clean_member{
	my $entry = $_[0];
	my $uid = $_[1];
	my $nuid = $_[2];
	my $file = $_[3];
	my @array=0;
	while($entry->exist('member')){
	if($entry->get_value('member') ~~ $uid){
		my $old_member_entry = get_value('member');
		my $new_member_entry = $old_member_entry =~ s/uid=(\w*),/uid=$nuid,/r;
		$entry->replace('member'=>$new_member_entry);
			
	}else{
		$entry->delete('member'=>get_value('member'));
	}
	}
	$file->write_entry($entry);
}

sub read_cor{
	my $file="10_cor.txt";
open (COR, $file) or die ("Could not open file.");

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
		my $re_group = file::open_file("result/10_group.ldif","r");
		my $clean_group = file::open_file("result/10_group_clean.ldif","w");
		
	while (not $re_group->eof() ){
		my $entry = $re_group->read_entry();
		if($entry->get_value('member',asref => 1)&& $entry){
		clean_member($entry,$uid,$nuid,$clean_group);
		
		}
	}
$re_group->done();
$clean_group->done();	
}

sub read_n_count{
	my $r_group= $_[0];
	while (not $r_group->eof() ){
		my $entry = $r_group->read_entry();
		if($entry->get_value('member',asref => 1)&& $entry){
		my $members = count_member($entry);
		open(COR_FILE, ">>result/10_group_member.ldif")or die('Could not open unwant File ');
		
			print COR_FILE $entry->get_value('cn')." ".$members."\n";
	
	close(COR_FILE);
		}	
	}
}



print "end\n";

