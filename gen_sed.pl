use strict; 
use warnings;

require "traitement.pm";

my $limit = "500";
my %cor =&get_uid_hash($limit);
my @uid =&get_uid_list($limit);

#&gen_script_list(\@uid);
&gen_script_hash(\%cor);

sub gen_script_list{
	my $output = "sorted_sedscript_list.sed";
	my $list = $_[0];	
	my @unsorted_list= @$list;
	my @list = sort @unsorted_list;

	open my $out, ">", $output or die ("Can't open $output\n");
		while ( scalar(@list)>0 ) {
			my $item = pop(@list);
			print $out "/".$item."/d\n";
		}
	close $out
	}

sub gen_script_hash{
        #my $file=$_[0];
        my $hash=$_[0];
        my $output = "sorted_sed_script_hash.sed";
        my %hash= %$hash;
	my @keys= keys(%hash); 

        open my $out , ">", $output or die ("Can't open $output\n");
        while(my ($key,$value)=each(%hash)){
                print $out "s/".$key."/".$value."/g\n";
        }
        close $out;
       
}


# A utiliser après rem.pl
# rm.pl cré 3 fichiers 
# -- *_ldap_base.ldif 		Fichier contenant un echantillon
# -- *_cor_file.txt		Correspondance des uid echantilloné
# -- *_unwant_file.txt		uid non selectionner 

# Objet de ce fichier 
# Récupération d'un tableau associatif des correspondance depuis 
# le fichier *_cor 
sub get_uid_hash{
	#my $file=$_[0];
	my $limit=$_[0];
	my $file= $limit."_cor.txt";
	my %cor= ();
	
	open my $in , "<", $file or die ("Can't open $file\n");
	while(<$in>){
		#extraction de key value
		my ($key,$value) = $_=~ /^(.*):(.*)$/;
		#print $key ."\t".$value. "\n";
		$cor{$key}=$value;
	}
	close $in;
	return %cor;
}

# Récupération d'un liste des uid non désiré depuis 
# le fichier *_unwant_file.txt
sub get_uid_list{
        #my $file=$_[0];
	my $limit =$_[0];
	my $file = $limit."_unwant.txt";
        my @uid= ();

        open my $in , "<", $file or die ("Can't open $file\n");
        while(<$in>){
                # chomp supression du saut de ligne
                chomp($_);
                push(@uid,$_);
        }
        close $in;
        return @uid;
}
  

#print " Recherche et suppression des uid non désirés\n";
#traitement::readthrough($limit,\@uid);
#gen_name::snd($limit,\@uid);
#print " Modification des anciens UID par les nouveaux\n";
#traitement::readnmodify($limit,\%cor);
#gen_name::readnmodify($limit,\%cor);
#print "Fin\n";

# Test
#my @cor= keys(%cor);
#print scalar(@cor);
#print scalar(@uid);
