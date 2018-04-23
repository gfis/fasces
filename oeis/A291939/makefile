#!make

# draw Collatz sequences, OEIS A070165 -> A291939
# @(#) $Id$
# 2018-03-23, Georg Fischer
#----------
MODE=0
SIZE=100

all: bfile
#----------
wget:
	wget https://oeis.org/A070165/a070165.txt
bfile:
	perl a291939.pl $(MODE) a070165.txt | tee b291939.txt
a291939-3d.js: makefile a291939.pl a070165.txt
	grep -E "^[0-9]" a070165.txt | head -$(SIZE) > cs100.tmp
	perl a291939.pl 1 cs100.tmp > mode1.tmp 
	grep -E "# coords" mode1.tmp | cut -d " " -f 3 >> $@
	echo var vec = [0,0,0,1 > $@
	perl a291939.pl 1 cs100.tmp | grep -E "# coords" | cut -d " " -f 3 >> $@
	echo ]\; >> $@
	echo var colls = [0,0,0,1,1 >> $@
	grep -E "# collision" mode1.tmp | cut -d " " -f 3 >> $@
	echo ,0,0,0,0,0]\; >> $@
	cat $@
deploy: 
	echo either make deploy-windows or make deploy-linux
deploy-windows:
	cp -v *.js *.html c:/users/gfis/xampp/htdocs/threejs
deploy-linux:
	sudo cp -v *.js *.html        /var/www/html/threejs
	sudo chown -R georg:www-data  /var/www/html/threejs/*
	sudo chmod 750                /var/www/html/threejs/* 
deploy-server:
	scp a291939-3d.js a291939-3d.html       gfis@punctum.com:/var/www/html/teherba.org/threejs
#-----
# no more:
detab:
	perl deA070165.pl b070165.txt | tee a070165.tab
	