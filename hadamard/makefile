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
	perl hadamard_prep.pl from_sage_1-26.txt | tee planes.inc

#--
square: # show notation for 2x2 blocks
	perl hadamard.pl -d $(D) -m square planes.inc | tee x.tmp
#--------------------------------------

