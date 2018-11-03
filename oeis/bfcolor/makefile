#!make

# Colorized b-files
# @(#) $Id$
# 2018-10-31, Georg Fischer 
#---------------------------------

all: bfcolor1
#------------
bfcolors:
	make bfcolor1 FILE=b136942
	# make bfcolor1 FILE=b136808
	make bfcolor1 FILE=b136820
	make bfcolor1 FILE=b136872
	make bfcolor1 FILE=b136854
	make bfcolor1 FILE=b116130
	make bfcolor1 FILE=b116229
bfcolor1:
	perl bfcolorize.pl -b $(FILE) \
	| tidy --quiet yes --replace-color yes -o $(FILE).html
#------------
deploy: 
	scp bfcolor4.html gfis@punctum.com:/var/www/html/teherba.org/fasces/oeis/bfcolor
