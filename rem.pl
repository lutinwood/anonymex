#!/usr/bin/perl -w
#REM -Read Extract and Modify
use Net::LDAP::LDIF;

require "file.pm";
require "user.pm";
require "group.pm";
require "gen_name.pm";
require "traitement.pm";

use strict;
use warnings;

###################	VARIABLES
#
#	perl rem.pl $file_ldif $limit
#
##############################


sub test_file_ldif{
	my $file = "testg.ldif" ;
	file::open_file($file,"w");
}
#&test_file_ldif;


file::test_parameter($ARGV[0],$ARGV[1]);

# Fichier LDIF De référence
my $source =$ARGV[0];

# Nombre d'individus à générer 
my $limit= $ARGV[1];

## auastatut non traité
my @exclus = ('jeton');
## Champs mail 
my @mail_field =('mail','auaEmailRenvoi',
                'auaAliasEmail','supannMailPerso','supannAutreMail');

#list des uid a supprimer
#UID non retenues
my @eggs= ();

my @uidex=();

my $ref_uid = "uid=ShaAbu,ou=people,dc=univ-angers,dc=fr";

#####################			FICHIERS
 
# non modify 
my $non_modif = $limit."_non_modified.ldif";
# selected
my $selected = $limit."selected.ldif";




my $attr= 'auaStatut';
my $uidToDelete; 
###################	OUVERTURE DE FICHIERS
# Ouverture du fichier source 
	my $r_source = file::open_file($source,"r");
# Ouverture du fichier des entree modifiées	
	my $w_non_modif = file::open_file($non_modif,"w");


my %uids = ();

#TEST
my $nbgroup 	= 	0;
my $member 		= 	0;
my $memberUID 	= 	0;
my $gecos 		= 	0;
my $domain		=	0;
my $domain_group= 	0;
my $entry_waited=	0;
my $notparsed	=	0;
my $other_entries=	0;

#########		TRAITEMENT
# Debut de la lecture du fichier source
sub get_only_group{
	# group 

	while (not $r_source->eof() ){
		
		my $group_file = $limit."_group.ldif";
	my $domain_file = $limit."_domain.ldif";
	my $domain_group_file = $limit."_domain_group.ldif";
	# Ouverture des fichiers 
	my $w_group_file = file::open_file($group_file,"w");
	my $w_domain_file = file::open_file($domain_file,"w");
	my $w_domain_group_file = file::open_file($domain_group_file,"w");
	# Unité d'enregistrement : Instance de 	NET::LDAP::ENTRY
	my $entry = $r_source->read_entry();
if ($entry eq ''){
		print 'no entry' ;
		exit;
}

	if(group::is_domain($entry) || group::is_group($entry))
		{
			if(group::is_domain($entry) && group::is_group($entry)){
				group::get_domain($entry,$w_domain_group_file);
				$domain_group++;
			}elsif(group::is_domain($entry)){
				group::get_domain($entry,$w_domain_file);
				$domain++;
			}elsif(group::is_group($entry)){
				$nbgroup++;
			}
		}
	#Fermeture des fichiers
	$w_group_file->done();
	$w_domain_file->done();
	$w_domain_group_file->done();
	}
	$r_source->done();
}


sub get_only_user{
	my $cpt = 0;
	# Ouverture du fichier des selections
	my $w_selected = file::open_file($selected,"w");
	my $r_source = file::open_file($source,"r");
	while (not $r_source->eof() ){
		my $entry = $r_source->read_entry();
	if(user::is_user($entry)){
		my @final = gen_name::result();
			if($cpt < $limit){
				
				# extract name list
			
				my $genID = $final[$cpt];
				my $uid =$genID->{uid};
				$uids{$entry->get_value('uid')}=$uid;
				user::modif_user($entry,$cpt,$uid,$genID);
				user::get_user($entry,$w_selected);
				# Incrémentation COmpteur
				
				$entry_waited++;
				$cpt++;
				}elsif($cpt >= $limit){
					$notparsed++;	
				}
			}else{
			$other_entries++;
			}
	}
	$w_selected->done();
}

&get_only_group;
&get_only_user;

#Cloture des fichiers
$r_source->done();
$w_non_modif->done();

## Modification des entrées uidi
#print scalar(@eggs)."\n";
print " PHASE FINALE 0 \n";
user::keep_old_uid($limit,\%uids);
print " PHASE FINALE 1 \n";
user::keep_unwanted($limit,\@eggs);
print " FIN REM  \n";

print "limit" .$limit."\n";
print "GRoup " . $nbgroup."\n";
print "Member " . $member."\n";
print "MemberUID" . $memberUID."\n";
print "Group n domain " . $domain_group."\n";
print "Domain " . $domain."\n";
print "Entries " . $entry_waited."\n";
print "Not Parsed " . $notparsed."\n";
print "Other " . $other_entries."\n";
