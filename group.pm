#!/usr/bin/perl -w

package group;

sub is_group{
	my $entry  	= 	$_[0];
	if($entry->dn() =~ m/ou\=groups/){
		return 1;
	} 
		
}

sub is_domain{
	my $entry  	= 	$_[0];
	if($entry->dn() =~ m/ou\=domain/){
		return 1;
	} 
		
}

sub is_orga{
		my $entry  	= 	$_[0];
		if($entry->get_value('objectClass') 
		=~ 'organizationalUnit' && $entry->get_value('objectClass') =~ 'top'){
			return 1;
		}
}

sub is_samba_group{
		my $entry  	= 	$_[0];
		if($entry->get_value('memberUid')){
			return 1;
		}
		
}

sub get_group{
	my $entry  	= 	$_[0];
	my $file 	=	$_[1];
		$file->write_entry($entry);	
}
 	  

#END {}
1;
