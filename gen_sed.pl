use strict; 
use warnings;

require "traitement.pm";

#ex:  gen_sed.pl 5 
#my limit = ARGV[0];
my $limit = $ARGV[0];

my $ldif_file		= $limit."_ldap_base.ldif";
my $list_output 	= $limit."_list.sed";
my $hash_output 	= $limit."_hash.sed";
my $correspondance 	= $limit."_cor.txt";
my $unwanted 		= $limit."_unwant.txt";

my $split_dir		=	"split_dir";
 
# recupération des inforamtion depuis les fichier 
my %cor =&get_uid_hash();
my @uid =&get_uid_list();

&clean_source();
# Génération des fichier destiné a sed
&gen_script_list(\@uid);
&gen_script_hash(\%cor);

#&clean_output();

#&sed_mod();

#&detailed_deletion();

print "END\n";

sub sed_mod{
	print "Modification des correspondances\n";
	system("sed","-f",$hash_output,"-i",$ldif_file);
	system("cp",$ldif_file,$ldif_file.".bakmod");
	}

sub detailed_deletion{
        # creation du repertoire
        &split_dir();
        &process();
        }

sub split_dir{
 print "Création d'un repertoire split\n";
        system("mkdir", $split_dir);
        system("cp", $list_output, $split_dir."/".$list_output);
        system("cd",$split_dir);
        system("split",$list_output);
	system("cp", "../".$ldif_file,".");
}

sub process{
my @files = &array_of_file;
print "Begining processing ..";
while (scalar(@files)>0){
my $item = pop(@files);
print $item."\n";
        system("sed","-f",$item,"-i",$ldif_file);
        system("cp",$ldif_file,$ldif_file."_".$item);
#        &get_file_size();
        print scalar(@files);
        }
print "END";
}


sub array_of_file{
        opendir(DOSSIER,".");
        my @new = ();
        my @entrees =readdir(DOSSIER);
        closedir(DOSSIER);
        foreach my $entrees (@entrees){
                if ($entrees =~m/x.*/){
                push(@new,$entrees);
                }
                }
        my @sorted_new = sort @new;
        return @sorted_new;
        }

sub clean_output{
#	system("sed","-i", '/\/\$\//d',$list_output);
  my  $tmpsupfile = "tmp-" . $unwanted;
     open(SUP, "$list_output") or die "$!";
     open(TMP, "> $tmpsupfile") or die "$!";

     my $line;
     while (defined($line = <SUP>)) {
         chomp $line;
         if( $line =~ m/\/\$\//){
		 $line =~ m/\/\$\//;
		}
         print TMP "$line\n";
        }
     
     close(TMP) or die "$!";
     close(SUP) or die "$!";
     rename("$tmpsupfile", "$list_output") or die "$!";
    return 1;
}

sub clean_source{

  my  $tmpsupfile = "tmp-" . $unwanted;
     open(SUP, "$unwanted") or die "$!";
     open(TMP, "> $tmpsupfile") or die "$!";

     my $line;
     while (defined($line = <SUP>)) {
         chomp $line;
         if($line !~ m/\//){
         print TMP "$line\n";
	}
     }
     close(TMP) or die "$!";
     close(SUP) or die "$!";
     rename("$tmpsupfile", "$unwanted") or die "$!";
    return 1;


#	system("sed","/\//d","-i",$unwanted);
	#system("sed","/bu[0-9]/d","-i",$unwanted);
	}

sub gen_script_list{
	my $output = $list_output;
	my $list = $_[0];	
	my @unsorted_list= @$list;
	my @list = sort @unsorted_list;

	open my $out, ">", $output or die ("Can't open $output\n");
		while ( scalar(@list)>0 ) {
			my $item = pop(@list);
			if($item =~ /\./){
			$item =~ s/\./\\\./g;}
			elsif($item =~ /\-/){
			$item =~ s/\-/\\\-/g;}
			elsif($item =~ /\$/){
			$item =~ s/\$/\\\$/g;}	
			print $out "/[= ]".$item."/d\n";
		}
	close $out
	}

sub gen_script_hash{
        #my $file=$_[0];
        my $hash=$_[0];
        my $output = $hash_output;
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
	#my $limit=$_[0];
	my $file= $correspondance;
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
	#my $limit =$_[0];
	my $file = $unwanted;
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
