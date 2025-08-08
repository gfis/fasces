#!/usr/bin/make

# Hadamard pyramid
# @(#) $Id: 024cbfe673e20777f8a8e3fd8d2568fdfa3db1ba $
# 2025-07-21, Georg Fischer

APPL=fasces
SRC=src/main/java/org/teherba/fasces
TESTDIR=test
D=0

all:
	grep -P "^[a-z]" makefile
#-------------------------------------------------------------------
prep: # prepare the matrices obtained from SageMath
	perl hadamard_prep.pl from_sage_1-33.txt | tee planes.inc

#--
square: # show notation for 2x2 blocks
	perl hadamard.pl -d $(D) -m square planes.inc | tee planes.tmp 
svgen:
	perl svgen.pl planes.tmp 
#--------------------------------------
sagen: # generate Hadamard matrices with sage in raw format; must be called under Ubuntu in directory /mnt/c/Users/drgeo/work/gits/fasces/hadamard
	mkdir -p raw 
	seq 1 256 | xargs -innn make sagen1 SEQ=nnn
sagen1:
	sage hadamard.sage $(SEQ) > raw/h$(SEQ).raw
	echo raw/h$(SEQ) generated
h92:
	perl hadamard_prep.pl from_sage.92.txt | tee plane.$@.inc
	perl hadamard.pl -d $(D) -m square plane.$@.inc | tee plane.$@.tmp
	perl svgen.pl plane.$@.tmp 
h65:
	perl hadamard_prep.pl from_sage.1-65.txt        > plane.$@.inc
	perl hadamard.pl -d $(D) -m square plane.$@.inc > plane.$@.tmp
	perl svgen.pl                                     plane.$@.tmp
#----
# Pyramid for *VF=44
deploy:
	cp -v hapyramid.html hapyramid_world.js hapyramid_blocks.js c:/xampp/htdocs/threejs	 
