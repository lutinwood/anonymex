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
# Fichier LDIF De référence
my $file = "src/".$ARGV[1];
my $output = $limit."_ldap_base.ldif";
my $cpt = 0;
my $attr= 'auaStatut';
my $uidToDelete; 

# Tableau associatifs contenants anciens et nouveau uid 
# pour futur modification des champs Memberuid & member: :uid
my %uids = ();
# extract name list
my @final = gen_name::result();
## auastatut non traité
my @exclus = ('jeton','convention','ext-conseils','acces-web');
## Champs mail 
my @mail_field =('mail','auaEmailRenvoi',
		'auaAliasEmail','supannMailPerso','supannAutreMail');

my @objectclass=('auaGroup','sambaSamAccount');

#list des uid a supprimer
my @eggs= ();
my @uidex=();

###################	OUVERTURE DE FICHIERS
# Ouverture du fichier source 
my $ldif = Net::LDAP::LDIF->new( $file, "r", 
			encode => 'canonical', onerror => 'undef');
#Si il n'existe pas déjà le créer
unless(-e $output){
	my $out_ldif = Net::LDAP::LDIF->new($output, "a", 
			encode => 'canonical', onerror => 'undef');
	}
	# sijon le mettre à jour
	my $out_ldif = Net::LDAP::LDIF->new($output, "w", 
			encode => 'canonical', onerror => 'undef');
#Concerne tout mes attributs ayant un attribut uid

	# if($entry->exists('sambaSID')){
		 
#########		TRAITEMENT
# Debut de la lecture du fichier source
while (not $ldif->eof() ){
	# Unité d'enregistrement : Instance de 	NET::LDAP::ENTRY
	my $entry = $ldif->read_entry();

	if($entry->exists($attr) && $entry->get_value($attr) ~~ @exclus){
		# Ecriture des profils non concernés par les modifications
		# Ayant un attribut auastatut
		$out_ldif->write_entry($entry);
		my $uidex = $entry->get_value('uid');
		push @uidex,$uidex unless $uidex ~~ @uidex;
		}
	elsif($cpt < $limit && $entry->exists('uid') ) {
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
		   $out_ldif->write_entry($entry);
		   }#end limit
	elsif($cpt == $limit && $entry->exists('uid') && $entry->get_value('objectclass') !~ @objectclass ){
		my $uwant = $entry->get_value('uid');
		if($entry->get_value('auastatut') ~~ @exclus){
		print "error";
		}else{
		push @eggs,$uwant unless $uwant ~~ @eggs or $uwant ~~ @uidex or 
		$entry->get_value('objectClass')eq "organizationalUnit";
		} 
	}else{	 
		# Fin des profils a ne pas modifier ayant un champs auastatut	
		# Ecriture des enregistrement non modifié
		# Ne contenant aucun uid
		
		$out_ldif->write_entry($entry)unless $entry->get_value('uid') ~~ @eggs;
		}#fin else
	    }# fin du while	
#Cloture des fichiers
$out_ldif->done();
$ldif->done();
## Modification des entrées uidi
print scalar(@eggs)."\n";
print " PHASE FINALE 0 \n";
traitement::keep_old_uid($limit,\%uids);
print " PHASE FINALE 1 \n";
traitement::keep_unwanted($limit,\@eggs);
print " FIN REM  \n";
#gen_name::searchndestroy($output,\@eggs);
#traitement::readthrough(\@eggs,$output,$limit."_wuwant.ldif");
#print " PHASE FINALE 3\n";
#traitement::readnmodify($limit."_wuwant.ldif",$limit."_clean.ldif",\%uids);
