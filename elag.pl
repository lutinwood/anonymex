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

require "file.pm";

# test nombre de paramètre 
file::test_parameter($ARGV[0],$ARGV[1]);

# variables
my $input_ldif = $ARGV[0];
my $output_ldif = $ARGV[1];
# auastatut a supprimer
my @statut_exclus =('acces-web','bu','bu-sortant','convention',
					'etu-entrant','ext-conseil',
					'perso-nomail','perso-sortant-nomail');

# objectclass a supprimer 
my @object_exclus = ('sambaSamAccount');

my $fullpath = "result/";
############## OUVERTURE DE FICHIER
# SOURCE
	my $read_source = file::open_file($input_ldif,"r");
	my $write_clean = file::open_file($output_ldif,"w");
	my $excluded	= file::open_file($fullpath."excluded.ldif","w");
	my $status_excluded = file::open_file($fullpath."status_excluded.ldif","w");

my $host_deleted	=	0;
my $statut_excluded	= 	0;
my $object_excluded = 	0;
my $total_entries	=	0;

#################""""""		SUBROUTINE
sub test_host{
	my $entry = $_[0];
	if ($entry -> dn() =~ m/ou\=host/){
				$host_deleted++;
				$excluded -> write_entry($entry);
				return 1;}
}
sub test_status{
	my $entry = $_[0];
	if($entry -> get_value('auastatut') ~~ @statut_exclus){
				$statut_excluded++;
				$status_excluded -> write_entry($entry);
				return 1;}
}
sub test_class{
	my $entry = $_[0];
	if($entry -> get_value('objectclass') ~~ @object_exclus){
			$object_excluded++;
			$excluded -> write_entry($entry);
			return 1;}
}
################################ END SUBROUTINE

while (not $read_source->eof()){
		my $entry = $read_source->read_entry();
		
		unless (&test_status($entry) || &test_class($entry) || &test_host($entry)) 
			{
			#ecrire
				$write_clean -> write_entry($entry);
				$total_entries++;
			}
	}

## Fermeture
$read_source->done();
$write_clean->done();
$excluded->done();
$status_excluded->done();


## Messages
print "Fin de nettoyage \n";
print " hotes deleted " . $host_deleted ."\n";
print " status deleted " . $statut_excluded ."\n";
print " object deleted " . $object_excluded ."\n";
print " Total entries " . $total_entries ."\n";