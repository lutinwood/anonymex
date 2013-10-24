#!/usr/bin/perl -w

#REM -Read Extract and Modify
use Net::LDAP::LDIF;

require "gen_name.pm";
require "traitement.pm";

use strict;
use warnings;

###################	VARIABLES
#
#	perl rem.pl $limit $file_ldif 
#
####	scalaire
# Nombre d'individus à générer 
my $limit= $ARGV[0];

# Tableau associatifs contenants anciens et nouveau uid 
# pour futur modification des champs Memberuid & member: :uid

my %uids = ();
# extract name list
my @final = gen_name::result();
## auastatut non traité
my @exclus = ('jeton','convention','ext-conseils','acces-web','bu');
## Champs mail 
my @mail_field =('mail','auaEmailRenvoi',
                'auaAliasEmail','supannMailPerso','supannAutreMail');

my @objectclass=('auaGroup','sambaSamAccount');

#list des uid a supprimer
my @eggs= ();
my @uidex=();

my $ref_uid = "uid=ShaAbu,ou=people,dc=univ-angers,dc=fr";

#####################			FICHIERS
# Fichier LDIF De référence
my $source ="src/".$ARGV[1]; 
# non modify 
my $non_modif = $limit."_non_modified.ldif";
# selected
my $selected = $limit."selected.ldif";
# group 
my $group = $limit."group.ldif"; 

my $cpt = 0;
my $attr= 'auaStatut';
my $uidToDelete; 

#################""""""		SUBROUTINE
sub open_file{
my $file = $_[0];
my $option =$_[1]; 
my $output;


if($option eq "r"){

	$output = Net::LDAP::LDIF->new( $file, "r", 
                        encode => 'canonical', onerror => 'undef');
}elsif($option eq "w"){

        $output = Net::LDAP::LDIF->new($file, "a", 
                        encode => 'canonical', onerror => 'undef');
        }else{
		print "Option not defined $file \n";
		exit;
	}
	return $output;
	}


###################	OUVERTURE DE FICHIERS
# Ouverture du fichier source 
my $r_source = &open_file($source,"r");

# Ouverture du fichier des entree modifiées	
my $w_non_modif = &open_file($non_modif,"w");

# Ouverture du fichier des selections
my $w_selected = &open_file($selected,"w");

# Ouverture deu fichier des group
my $w_group = &open_file($group,"w");
	 
#########		TRAITEMENT
# Debut de la lecture du fichier source
while (not $r_source->eof() ){
	# Unité d'enregistrement : Instance de 	NET::LDAP::ENTRY
	my $entry = $r_source->read_entry();

	my @object = $entry->get_value('objectClass');
	if($entry->exists($attr) && $entry->get_value($attr) ~~ @exclus){
		# Ecriture des profils non concernés par les modifications
		# Ayant un attribut auastatut
		$w_non_modif->write_entry($entry);
		my $uidex = $entry->get_value('uid');
		push @uidex,$uidex unless $uidex ~~ @uidex;
		}
# si il s'agit d'un ordinateur
	elsif($entry->dn() =~ m/ou\=host/){
		$w_non_modif->write_entry($entry);
	}
	elsif($entry->exists('gecos') ){
		$w_non_modif->write_entry($entry);
		} 
# si il s'agit d'un group 
	elsif("auaGroup" ~~ @object){
		$w_group->write_entry($entry);
                }
	elsif($entry->dn() =~ m/ou\=domains/){
                $w_non_modif->write_entry($entry);
        }
# gestion des group 
	elsif($entry->exists('member')){
		# TODO
		# replace member by it real new members
		# Linked with $entry->exists('memberUid')
		my @new_value = ();
		$entry->replace('member'=> $ref_uid);
		$w_group->write_entry($entry);
		}
	elsif($entry->exists('memberUid')){
	my @new_value = ();
                $entry->replace('memberUid'=> $ref_uid);
                $w_group->write_entry($entry);
	}
# Entree désirées
	elsif($cpt < $limit && $entry->exists('uid')  && $entry->get_value($attr) && "person" ~~ @object ) {
		my $genID = $final[$cpt];
		# Identifiant unique 
		my $uid =$genID->{uid};
   		# Conservation d'une correspondance pour future modification
   		$uids{$entry->get_value('uid')}=$uid;
		# Modification de base (uid,sn,cn)
		traitement::IdModOne($genID,$entry);	
		my $dn 	= $entry->dn() =~ s/uid=(\w*),/uid=$uid,/r;	
 		# Mise à jour du distinguish name       
                $entry->dn($dn);
		# géneration du repertoire personnel
		traitement::SpecMod($genID,$entry,'homeDirectory');
		# Population dotée d'un champs auastatut
		if ($entry->get_value($attr)){	
		   traitement::IdModTwo($genID,$entry);
		   #Modification des attributs facultatifs
		   my @fields = ('mail','auaEmailRenvoi','auaAliasEmail','supannMailPerso',
			'postalAddress','telephoneNumber', 'supannAutreTelephone','sambaSID');
		  	   foreach my $field(@fields){ 
		   		traitement::SpecMod($genID,$entry,$field);
		  	   }
		  	}# attribut auastatut
		   # Incrémantation COmpteur
		   $cpt++;
		   # Ecriture des enregistrements modifiés
		   $w_selected->write_entry($entry);
		   }#end limit
	elsif($cpt == $limit && "person" ~~ @object){
		my $uwant = $entry->get_value('uid');
		push @eggs,$uwant unless $uwant ~~ @eggs;
		 
	}else{	 
		# Fin des profils a ne pas modifier ayant un champs auastatut	
		# Ecriture des enregistrement non modifié
		# Ne contenant aucun uid
		$w_non_modif->write_entry($entry);
		#print " NOT defined\n";

	#	print $entry->dn();	#	print $entry->get_value('dn')."\n";
	
		#exit;#	$r_source->done();
	#	$w_group->done();
	#	$w_non_modif->done();
	#	$w_selected->done();
	#	exit;
		#$out_ldif->write_entry($entry)unless $entry->get_value('uid') ~~ @eggs;
		}#fin else
	    }# fin du while	
#Cloture des fichiers

$r_source->done();
$w_group->done();
$w_non_modif->done();
$w_selected->done();
## Modification des entrées uidi
print scalar(@eggs)."\n";
print " PHASE FINALE 0 \n";
traitement::keep_old_uid($limit,\%uids);
print " PHASE FINALE 1 \n";
traitement::keep_unwanted($limit,\@eggs);
print " FIN REM  \n";
#gen_name::searchndestroy($output,\@eggs);
#traitement::readthrough(\@eggs,$output,$limit."_wuwant.ldif");
#print " PHASE FINALE 3\n"o;
#traitement::readnmodify($limit."_wuwant.ldif",$limit."_clean.ldif",\%uids);
