#!/usr/bin/perl -w

package user;

sub is_user{
	my $entry  	= 	$_[0];
	if($entry->dn() =~ m/ou\=people/){
		return 1;
	} 
		
}

sub get_user{
	my $entry  	= 	$_[0];
	my $file	=	$_[1];
	$file->write_entry($entry);	
}

sub modif_user{
	my $entry  	= 	$_[0];
	my $cpt  	= 	$_[1];
	my $uid  	= 	$_[2];
	my $genID  	= 	$_[3];
	
	traitement::IdModOne($genID,$entry);
	my $dn 	= $entry->dn() =~ s/uid=(\w*),/uid=$uid,/r;
	$entry->dn($dn);
	traitement::SpecMod($genID,$entry,'homeDirectory');
	if ($entry->get_value( 'auaStatut')){
		traitement::IdModTwo($genID,$entry);
		my @fields = ('mail','auaEmailRenvoi','auaAliasEmail','supannMailPerso',
			'postalAddress','telephoneNumber', 'supannAutreTelephone','sambaSID');
		  	   foreach my $field(@fields){ 
		   		traitement::SpecMod($genID,$entry,$field);
		  	   }
		}
	}

sub keep_old_uid{
	my $limit  	= 	$_[0];
	my $string 	= 	$_[1];
	my %ptr 	= %$string; 
	
	my $fullpath = "result/".$limit; 
	open(COR_FILE, ">".$fullpath."_cor.txt")or die('Could not open COR File ');
	while ((my $c,my $v) = each(%ptr)) {
 		print COR_FILE "$c:$v\n";
	}
	close(COR_FILE);
}

sub keep_unwanted{
	my $limit=$_[0];
	my $string = $_[1];
	my @ptr = @$string; 
	my $fullpath = "result/".$limit;
	
	open(COR_FILE, ">".$fullpath."_unwant.txt")or die('Could not open unwant File ');
		foreach my $uid (@ptr){
			print COR_FILE "$uid\n";
			}
	close(COR_FILE);
}

#END {}
1;