#!/usr/bin/perl -w

# elag.pl suppruime les entrées non désirées
# Elagage à faire avant traitement :
#  objectClass: sambaDomain
#   auaStatut: bu
#   ou=hosts

# Champs à supprimer dans ou=people :
#    samba* 
###################	USE
#
#	perl elag.pl $input_ldif $output_ldif
# 
######################################
use Net::LDAP::LDIF;

use strict;
use warnings;
#################""""""		SUBROUTINE
## Accès fichier
sub open_file{
	my $file 	=	$_[0];
	my $option 	=	$_[1]; 
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
################################ END SUBROUTINE

# test nombre de paramètre 
if($ARGV[0] eq ''){
		die "Le fichier source est manquant ! \n";
		
	}else{
		if($ARGV[1] eq ''){
				die "le fichier destination est manquant !\n";
		}
}

my $input_ldif = $ARGV[0];
my $output_ldif = $ARGV[1];
# auastatus a supprimer
my @status_exclus =('bu','bu-sortant','ext-conseil','nomail');

# objectclass a supprimer 
my @object_exclus = ('sambaSamAccount');


############## OUVERTURE DE FICHIER
# SOURCE
	my $read_source = &open_file($input_ldif,"r");
	my $write_clean = &open_file($output_ldif,"w");

## Lecture Source
while (not my $read_source->eof()){
		my $entry = $read_source->read_entry();
		# n'est pas un hôte
		if (not $entry -> dn() =~ m/ou\=host/
			||
		# n'a pas de status d'exclusion
			not $entry -> get_value('auastatus')~~ @status_exclus
			|| 
		# n'a pas de classe d'exclusion
			not $entry -> get_value('objectclass') ~~ @object_exclus)
			{
			#ecrire
				$write_clean -> write_entry($entry);
			}
	}
$read_source->done();
$write_clean->done();
print "Fin de nettoyage \n"
