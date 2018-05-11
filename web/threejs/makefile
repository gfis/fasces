#!/bin/make

# for three.js experiments of fasces
# @(#) $Id$
# 2018-05-11: with *.css
# 2018-02-18, Georg Fischer

all: 
	echo either make deploy-windows or make deploy-linux
deploy-windows:
	cp -v *.js *.html *.css c:/users/gfis/xampp/htdocs/threejs
deploy-linux:
	sudo cp -v *.js *.html *.css         /var/www/html/threejs
	sudo chown -R georg:www-data         /var/www/html/threejs/*
	sudo chmod 750                       /var/www/html/threejs/* 
 