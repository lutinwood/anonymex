#!/usr/bin/perl -w
#REM -Read Extract and Modify
use Net::LDAP::LDIF;
use integer;

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
#		$source		->	Fichier ldif 
#		$limit		->	Nombre d'individus
#		@exclus		-> auaStatut non traité
#		@mail_field -> Champs mail possibles
#		@eggs		-> uid non retenue
#		@uidex		-> correspondance old new uid 
#		
#		
#			TEST
my $nbgroup 		= 	0;
my $member 			= 	0;
my $memberUID 		= 	0;
my $gecos 			= 	0;
my $domain			=	0;
my $domain_group	= 	0;
my $entry_waited	=	0;
my $notparsed		=	0;
my $other_entries	=	0;
my $samba			=	0;
my $orga			=	0;

file::test_parameter($ARGV[0],$ARGV[1]);

###		VAR

my $source 	=	$ARGV[0];
my $limit	= 	$ARGV[1];

my $path 	= "result/";
my $fullpath 	= 	$path.$limit;

my @exclus 	= 	('jeton'); 
my @mail_field 	=	('mail','auaEmailRenvoi',
                	'auaAliasEmail','supannMailPerso','supannAutreMail');
my @eggs	= 	();
my @uidex	=	();
my %uids = ();

###		FICHIERS
 
my $non_modif 	= 	$fullpath."_non_modified.ldif";
my $selection 	=	$fullpath."_selection.ldif";
my $selected 	= 	$fullpath."selected.ldif";

my $samba_file 			=	$fullpath."_samba.ldif";
my $orga_file			=	$fullpath."_orga.ldif";
my $group_file 			=	$fullpath."_group.ldif";
my $domain_file 		=	$fullpath."_domain.ldif";
my $domain_group_file 	= 	$fullpath."_domain_group.ldif";

#########		SUBROUTINES

sub test_entry{
	my $entry  	= 	$_[0];
	if ($entry eq ''){
				print 'no entry' ;
				exit;
			}
}

sub get_only_group{
	# Handler
	my $w_samba_file =	file::open_file($samba_file,"w");
	my $w_orga_file =	file::open_file($orga_file,"w");
	my $w_group_file = file::open_file($group_file,"w");
	my $w_domain_file = file::open_file($domain_file,"w");
	my $w_selected = file::open_file($selected,"w");
	my $r_source 	= file::open_file($source,"r");
	
	while (not $r_source->eof() ){
		my $entry = $r_source->read_entry();
		&test_entry($entry);
		
			if(group::is_orga($entry)){
				group::get_group($entry,$w_orga_file);
				$orga++;
				
			}elsif(group::is_samba_group($entry)){
				group::get_group($entry,$w_samba_file);
				$samba++;
				
			}elsif(group::is_domain($entry)){
				group::get_group($entry,$w_domain_file);
				$domain++;
				
			}elsif(group::is_group($entry)){
				group::get_group($entry,$w_group_file);
				$nbgroup++;
				}
			elsif(user::is_user($entry) && $entry->get_value('uid')){
			user::get_user($entry,$w_selected);
			}
}
	# Fermeture
	$w_samba_file->done();
	$w_orga_file->done();
	$w_group_file->done();
	$w_domain_file->done();
	$w_selected->done();
	$r_source->done();
}

sub generate_id{
	
}

sub get_selected_user{
	my $cpt_etud = 0;
	my $cpt_perso = 0;
	my $cpt = 0;
	my @final = gen_name::result();
	
	my $r_selected = file::open_file($selected,"r");
	my $w_selection = file::open_file($selection,"w");

	while (not $r_selected->eof() ){
		my $entry = $r_selected->read_entry();
		&test_entry($entry);
		# Etudiant
		if ($entry->get_value('auaStatut') eq 'etu' && $cpt_etud < $limit){
				# extract name list
				my $genID = $final[$cpt];
				my $uid =$genID->{uid};
				if($entry->get_value('uid') eq ''){ 
					print "no uid";
					$entry->dump();
					print "\n";
				}
				
				$uids{$entry->get_value('uid')}=$uid;
				
				user::modif_user($entry,$cpt,$uid,$genID);
				user::get_user($entry,$w_selection);
				
				$entry_waited++;
				$cpt_etud++;
				$cpt++;
			}
			elsif($entry->get_value('auaStatut') eq 'perso' && $cpt_perso < $limit){
							# extract name list
				my $genID = $final[$cpt];
				my $uid =$genID->{uid};
				if($entry->get_value('uid') eq ''){ 
					print "no uid";
					$entry->dump();
					print "\n";
				}
				
				$uids{$entry->get_value('uid')}=$uid;
				
				user::modif_user($entry,$cpt,$uid,$genID);
				user::get_user($entry,$w_selection);
				
				$entry_waited++;
				$cpt_perso++;
				$cpt++;
			}
				elsif($cpt_etud >= $limit || $cpt_perso >= $limit){
					my $uwant = $entry->get_value('uid');
					push @eggs,$uwant unless $uwant ~~ @eggs;
					$notparsed++;	
				}
		
	}
	$w_selection->done();
	$r_selected->done();	
	}

###		MAIN
print "group\n";
&get_only_group;
print "user\n";
&get_selected_user;
print " keep old\n";
user::keep_old_uid($limit,\%uids);
print " keep unwanted 1 \n";
user::keep_unwanted($limit,\@eggs);
print " FIN REM  \n";

### 	MESSAGE
print "limit" .$limit."\n";
print "GRoup " . $nbgroup."\n";
print "Member " . $member."\n";
print "MemberUID" . $memberUID."\n";
print "Group n domain " . $domain_group."\n";
print "Domain " . $domain."\n";
print "Entries " . $entry_waited."\n";
print "Not Parsed " . $notparsed."\n";
print "Other " . $other_entries."\n";
