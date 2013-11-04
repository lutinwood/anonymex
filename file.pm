#!/usr/bin/perl -w

package file;
sub test_parameter{
	# test nombre de paramètre 
	if($ARGV[0] eq ''){
		die "Le fichier source est manquant ! \n";
		
	}else{
		if($ARGV[1] eq ''){
				die "le fichier destination est manquant !\n";
		}
	}
}
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

#END {}
1;