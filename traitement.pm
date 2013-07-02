package traitement;
require "gen_name.pm";

sub IdModOne{
   my $genID = $_[0];
   my $entry = $_[1];

   $entry->replace(
   	uid 	=> 	$genID->{uid},
	sn 	=> 	$genID->{noms},
	cn 	=> 	$genID->{prenoms}. " " . $genID->{noms}
	);

	}

# ayant un attribut auastatut
sub IdModTwo{
   my $genID = $_[0];
   my $entry = $_[1];
                        
   $entry->replace(
   	givenName       => $genID->{prenoms},
	displayName     => $genID->{noms} ." ". $genID->{prenoms} 
	);
}
sub SpecMod{
   my $genID = $_[0];
   my $entry = $_[1];
   my $field = $_[2];

   if 	($field eq 'homeDirectory'){
	if ($entry->get_value('homeDirectory')){
	$entry->replace(
	homeDirectory => my $hd = gen_name::hd(
					$entry->get_value('homeDirectory'),
					$genID->{uid}
                			));
					}
        }
   elsif($field ~~ [qw( mail auaEmailRenvoi auaAliasEmail supannMailPerso)]){
	# Récupération du serveur d'origine ($host)
	 if($entry->get_value($field)){
	(my $pseudo ,my $host) = ($entry->get_value('mail') =~ /(.*)@(.*)/);
	# Génération de la variable 
	my $mail = $genID->{prenoms} . '.' . $genID->{noms}.'@'.$host;
			$entry->replace($field => $mail);
			}
	}
   elsif($field eq 'postalAddress'){
	   if ($entry->get_value('postalAddress')){
	     $entry->replace(postalAddress => gen_name::gen_address());
		}
	}
   elsif($field ~~ [qw( telephoneNumber supannAutreTelephone)]){
		if($entry->get_value($field)){
			$entry->replace($field => gen_name::gen_phone());
			}
		}
  elsif($field eq 'sambaSID'){
		if ($entry->get_value('sambaSID')){
		$entry->replace(sambaSID => $genID->{uid});
		}	
	}
	else{
	}
}

sub keep_old_uid{
 my $limit=$_[0];
my $string = $_[1];
my %ptr = %$string; 
## Conservation d'un tableau associatif des correspondance old and neuw uid 
# dans un fichier 
open(COR_FILE, ">".$limit."_cor.txt")or die('Could not open COR File ');
	while ((my $c,my $v) = each(%ptr)) {
  print COR_FILE "$c:$v\n";
}
close(COR_FILE);
#End 
}
sub keep_unwanted{
my $limit=$_[0];
my $string = $_[1];
my @ptr = @$string; 
open(COR_FILE, ">".$limit."_unwant.txt")or die('Could not open unwant File ');
	foreach my $uid (@ptr){
	print COR_FILE "$uid\n";
  
}
close(COR_FILE);
#End 
}

# Lecture ligne a ligne d'un fichier  + omission 
# des lignes copntenant des termes d'une liste
sub readthrough{
	# acces a une reference de liste par le biais d'un scalaire
	my $cpt=0;
	my $tmp =$_[1];
	my $limit = $_[0];

	my $input = $limit."_ldap_base.ldif";
	my $output = $limit."_RSD.ldif";

	my @liste = @$tmp;

print scalar(@liste);
#while(scalar(@liste)>0){
#my $item=pop(@liste);
open my $in , "<", $input  or die ("Can't open $input\n");
open my $out , ">", $output or die ("Can't open $output\n");
	# Parcours du fichier 
print "Debut parcour\n";
#print $item."\n";
	while (<$in>){
		#print $cpt."\n";
		my ($n) = split(/s\*|\s*/);
		#print $_ unless $n eq "1";
		#print $_ unless $_ =~ m/@item/g;
		print $out $_ unless findit($n,\@liste);
		$cpt++;	
	}
close $out;
close $in;

}
sub readnmodify{
my $limit = $_[0];
my $input = $limit."_RSD.ldif";
my $output =$limit."_clean.ldif";
my $string = $_[1];
my %ptr = %$string;

open my $in, "<",$input or die("Could not open RNM INPUT file.\n");
open my $out, ">",$output or die("Could not open RNM OUTPUT\n");
while ( my ($key, $value) = each(%ptr) ) {
        s/$key/$value/g;
        print $out $_;
        }
close $in;
close $out;
}


# contrôle de la présence d'un terme dans une liste
sub findit{
my $term = $_[0];
my $temp = $_[1];
my @col = @$temp;
# Si l'occurence est trouvé renvoie faux
if (grep(/$term/,@col)){
	return 1;
	}else{
	return 0;
	}
}
#END {}
1;
