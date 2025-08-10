#!/usr/bin/make

# Hadamard pyramid
# @(#) $Id: 024cbfe673e20777f8a8e3fd8d2568fdfa3db1ba $  
# 2025-08-09: *VF=44
# 2025-07-21, Georg Fischer

APPL=fasces
SRC=src/main/java/org/teherba/fasces
TESTDIR=test
D=0

all:
	grep -P "^[a-z]" makefile
#-------------------------------------------------------------------
#--
square: # show notation for 2x2 blocks
	perl ../hadamard.pl -d $(D) -m square ../planes.inc | tee planes.tmp 
#----
# Pyramid for *VF=44
E=22
empty: # block with random opacity/color
	perl hapy_empty.pl  -e $(E) \
	>     hapyramid_blocks.js
	cp -v hapyramid_blocks.js c:/xampp/htdocs/threejs/

blocks: # block with hex encoded opacity/color
	perl hapy_blocks.pl -e $(E) planes.tmp \
	>     hapyramid_blocks.js
	cp -v hapyramid_blocks.js c:/xampp/htdocs/threejs/

deploy:
	cp -v hapyramid.html hapyramid_world.js hapyramid_blocks.js c:/xampp/htdocs/threejs

remote:
	scp hapyramid.html hapyramid_world.js hapyramid_blocks.js gfis@teherba.org:/var/www/html/teherba.org/threejs/