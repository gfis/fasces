#!make

# OEIS Sequences A136nnn from Jonathan Wellons
# @(#) $Id$
# 2018-10-28, Georg Fischer 
#---------------------------------
D=0

all: test
#----
test10:
	perl listref1.pl -d $(D) < 2018-October.txt
test09:
	perl listref1.pl -d $(D) < 2018-September.txt
grepfrom:
	grep "^From" *.txt
#------------
deploy: 
	scp A*-A*.html index.html gfis@punctum.com:/var/www/html/teherba.org/fasces/oeis/database

