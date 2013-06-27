#!/usr/bin/perl -w
package gen_name;
# Cette version utilise une:
# liste de tableaux associatifs == array of hash
# Pour stocker les nom et prenoms issue d'un fichier text
# La liste contient:
# les références == pointeurs des tableaux associatifs
# la structure du tableau associatif: 
# {id = nom + prenom , nom = , prenom =,}
# unicité garantie par l'id 

# Utilisation d'un liste composé de  900 noms d'auteur
# extraction et création de notre enregistrement par la 
# fonction (subroutine) 
#	generate_name() 
# Retourne une liste de tableaux associatifs 

# Génération d'autres nom depuis cette liste avec la 
# fonction multi(@) qui accepte une liste en paramètre 
# qui retourne une liste de tableaux associatifs  

#use Exporter;
#@ISA=('Exporter');

#@EXPORT_OK=('result');
#BEGIN{
#our $VERSION = 1.00;
#}
#################################################
#		GMresult			#
################################################


sub result(){
	my @result = generate_name();
	my @temp =  multi(@result);
	my @final = ();
	my %control = ();
	my $cptc=0;
	foreach $temp (@temp){
	#crea tion de luid pour verifier son unicité
	my $val = substr($temp->{prenoms},0,3).
	substr($temp->{noms},0,3);
	if (! exists $control{$val}){
		$control{$val}=$cpt;
		push @final, { 
				uid => $val, 
				noms => $temp->{noms},
				prenoms => $temp->{prenoms}
				};
		$cptc++;
		}#End unless
	}#end foreach
#	print $final[58000]->{noms};	
	return @final;
}
#################################################
#		generate_name()			#
#################################################
# Fonction d'extraction de nom depuis un fichier texte
sub generate_name {
#my $index = "index_auteur.txt";
   # Ouverture du fichier
   open(INDEX_FILE, "src/index_auteur.txt") or 
   die("Could not open INDEX file.");
   # Initialisation de la liste
   my @new_list = ();
	
   # Lecture du fichier
   while(my $name = <INDEX_FILE>){
	# Si la ligne contient qu'un seul caractère 	
	if($name =~ /^([A-Z])$/){
        # Ne rien faire
        }else{
	# Extraire les couple nom prenom en faire une liste
        my @list_name = split('-',$name);
	# Pour chaque élément de la liste 
        foreach my $mod_name (@list_name){
	  # Division de chaque couple de la liste
	  if($mod_name =~ /\s(\w*)\s\((\w*)\)\s/){
	  # Ajout du Couple Noms, Prenom 
	  # Insertion des entrée de la liste par références
	    push @new_list, {
	      # Composition d'un identifiant unique
		#	id	=> $1 . " " . $2,
	      		noms 	=> $1,
	      		prenoms	=> $2,
	     		};       	
                }# End if 
           } # End for each
	} # End else
    } # End while
  # fermeture du fichier 
  close(INDEX_FILE);
return @new_list;
} # End fonction generate_name 

#################################################
#		multi(@)			#
#################################################

# Fonction de génération de nouvelle entrée
sub multi(@){ # @ contrôle que le paramètre soit bien une liste
   #paramètre de la subroutine 
   my (@source) = @_;
   #new hash 	
   my @dest = ();
   # Affichage du contenue du tableau de hash
      foreach my $result (@source){
      # copie de l'anciennne base
      # une simple copie de la liste aurait suffit 
       push @dest, {
       # Accès aux attribut du tableau associatif
	id 	=> $result->{noms}." ".$result->{prenoms},
	noms 	=> $result->{noms},
	prenoms => $result->{prenoms},
		};
	# Géneration des nouvelles entrées
	for(my $i=0;$i<600;$i++){
	  # Utilisation d'un choix aléatoire 
	  my $rand =0;
	  $rand = int(rand(500));	
	  # Extraction d'un enregistrement aléatoire
	  my $temp = $source[$rand];
	    # Ajout de l'entrée aléatoire
	    push @dest, {
		id => $result->{noms} . " " .
				$temp->{prenoms}, 
		noms	=> 	$result->{noms},
		# Issue de l'entrée aléatoirement choisi
		prenoms => 	$temp->{prenoms},
		};
	   } # end for 
	}# end foreach
	return @dest;
}# End multi(@)

#####################################################
#
#		Gen phone number
################################################

sub gen_phone{
my $id  = int(rand(7));

my $phone = "0".$id;

for(my $i = 0 ; $i < 4;$i++){
	my $al = int(rand(99));
	$phone = "$phone"." "."$al";

	}
return $phone;

}

##################################################
#
#		gen Town
###############################
sub get_town{
	open(INDEX_FILE, "src/FRANCE.csv") or 
   die("Could not open INDEX file.");
my @new_list = ();
my @towns =();


while(my $line = <INDEX_FILE>){
	(my $zip, my $town,  my $dep) = 
($line =~/(\d*)\;(\w*)\;(\w*)/);
	
push @towns,{
	zip => $zip,
	town=> $town,
	dep=>$dep};
# random unit base on array size 
}
my $test = int(rand(scalar @towns));
my $entry = $towns[$test];

return $entry;
}

##################################################
#
#		Gen Address
#
################################################## 
sub gen_address{
my $entry = get_town();
my $code = $entry->{zip};
my $ville = $entry->{town};


my $num = int(rand(200));
my @road= ('Rue','Allée','Avenue','Faubourg', 'Boulevard');
my $rrand = int(rand(scalar @road)); 
my $type = $road[$rrand];

my @getstreet = generate_name();
my $rstreet = int(rand(scalar @getstreet));
my $street = $getstreet[$rstreet]->{prenoms}." ".
	$getstreet[$rstreet]->{noms};
 
my $address = "$num, $type $street\$\$$code\$$ville"; 
#8 impasse des terrasses $$72300$sable-sur-sarthe
return $address;
}

########################################################
#
#		Modif host directory (path,user)
#
#######################################################
sub hd{
my $old_path=$_[0];
my $user =$_[1];

#substr EXPR,OFFSET,LENGTH
my $first = substr($user,0,1);
my $second = substr($user,1,1);
my $new_path = $old_path;

# s = replace
# s/string to replace/new string/ g = modify | r = make a copi
$new_path =~ s/\/home\/(\w)\/(\w)\/(\w*)/\/home\/$first\/$second\/$user/g;
return $new_path;
}

########################################################
#
#		Modification des entrée uid old -> new
#
##########################################################
#Passage par référence
# use : readnmodify($file,\%hash);
#sub readnmodify{
#my $input = $_[0];
#my $output =$_[1];
#my $limit = $_[0]; 
#my $string = $_[1];
#my %ptr = %$string;

#open my $in, "<","$limit.snd.ldif" or die("Could not open RNM INPUT file.\n");
#open my $out, ">","$limit.clean_ldap.ldif" or die("Could not open RNM OUTPUT\n");
#while (<$in>){
#	s/$key/$value/g;
#	print $out $_;
#	}
#close $in;
#close $out;

#  while ( my ($key, $value) = each(%ptr) ) {
        #print $file;
#	system("sed","-i","s/".$key."/".$value."/g",$file );
 #   }
#}

sub snd{
my $limit = $_[0];
my $file= $limit."_ldap_base.ldif"; 
my $string = $_[1];
my @ptr = @$string;

  while ( scalar(@ptr)>0 ) {
        #print $file;
	my $item = pop(@ptr);
        system("sed","-i","/".$item."/d",$file );
    }
system("cp",$file,$file.".bak");
}

sub readnmodify{
my $limit = $_[0];
my $file = $limit."_ldap_base.ldif";
my $string = $_[1];
my %ptr = %$string;

  while ( my ($key, $value) = each(%ptr) ) {
        #print $file;
        system("sed","-i","s/".$key."/".$value."/g",$file );
    }
}




sub searchndestroy{
my $input = $_[0];
my $output = $_[1];
my $string = $_[2];
#my $limit = $_[2];
my @ptr = @$string;
#	foreach my $match (@ptr) {
        #print $file;
#	system("perl","-ni","-e","/".$match."/",$file );
 #   }

open my $in, "<",$input or die("Could not get SND INPUT file.\n");
open my $out, ">",$output or die("Could not open SND OUTPUT\n");
foreach my $match(@ptr){

while (<$in>){
	if(/$match/){next;}else{print $out $_;}
	}
}
close $in;
close $out; 
}
#END {}
1;
