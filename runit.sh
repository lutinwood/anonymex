#!/bin/bash 

number="$1"
echo "generate copy"
perl rem.pl $number ua-pass.ldif
echo "generate sed file"
perl gen_sed $number
echo "replace uid"
sed -f $number'_hash.sed' -i $number'_ldap_base.ldif'
echo "delete the buggy entry"
sed '/2\/0/d' -i $number'_list.sed'
echo " process to delete all name non managed" 
sed -f $number'_list.sed' -i $number'_ldap_base.ldif'
