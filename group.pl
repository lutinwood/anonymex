#!/usr/bin.perl -w 

use Net::LDAP::LDIF;
use Scalar::Util::Reftype;

use strict; 
use warnings;


my $limit= $ARGV[0];
my $file = $limit."_ldap_base.ldif";
my $output = $limit."_clean_group.ldif";
my @exclus = ('jeton','convention','ext-conseils','acces-web');


 my $ldif_dn = Net::LDAP::LDIF->new( $file, "r", encode => 'none', onerror => 'undef');
 my @newmemberlist = ();


while (not $ldif_dn->eof() ){
my $entry_dn = $ldif_dn->read_entry();
my $dn = $entry_dn->dn();
 
#my $ou = $dn->{'ou'};
              if ($dn =~ m/people/){
		my $status = $entry_dn->get_value('auaStatut');
			if ($status ~~ @exclus){
#			print $entry_dn->dn();
		}else{
			if ($entry_dn->exists('uid')){
                push(@newmemberlist,$entry_dn->dn());
						}
                                                }
	}

                }
$ldif_dn->done();
print scalar(@newmemberlist);

 
#=begin GHOSTCODE
my $ldif = Net::LDAP::LDIF->new( $file, "r",
                        encode => 'canonical', onerror => 'undef');

unless(-e $output){
        my $out_ldif = Net::LDAP::LDIF->new($output, "a",
                        encode => 'canonical', onerror => 'undef');
        }
        # sijon le mettre à jour
        my $out_ldif = Net::LDAP::LDIF->new($output, "w",
                        encode => 'canonical', onerror => 'undef');

my $cpt = 0 ;

while (not $ldif->eof()){
my $entry = $ldif->read_entry();
	if ($entry->exists('member')){
		#do Get the number of member
			my $refmember= $entry->get_value('member',asref=>1);
		my @member  = @$refmember;
		my $nbrmember= scalar @member;
		print "\n".$nbrmember."\n";
		$cpt++;
		my @new_value = ();# 
		my @empty = ();
		$entry->replace('member'=>pop(@newmemberlist));
		for( my $cpt= 0; $cpt < $nbrmember; $cpt++){
			#	print pop(@newmemberlist);
				#push(@new_value,pop(@newmemberlist));		
				$entry->add('member'=> pop(@newmemberlist));
				}
				#print @new_value;
				#$entry->replace('member'=> @new_value);
				$entry->update($out_ldif);
				}
		
		if ($cpt >2){
		exit;
	}
	}
$ldif->done();
#=end GHOSTCODE
