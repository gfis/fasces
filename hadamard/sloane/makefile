#!/usr/bin/make

# Neil Sloane's directory of Hadamard matrices
# @(#) $Id$
# 2026-06-08, Georg Fischer; *FP=12; *RP=78

D=0

all:
	grep -P "^[a-z]" makefile
#----------------
# read from Sloane's directory with "wget https://neilsloane.com/hadamard/had.92.will.txt -q -O -"
index: # get Neil's main page
	wget https://neilsloane.com/hadamard/ -O index.html
get: # A= ; get 1 file*.txt
	wget https://neilsloane.com/hadamard/$(A).txt 
list: # get the list of all his matrices
	grep -P "\<a href=\"had\." index.html \
	| perl -ne 'if (m{\<a href=\"(had[^\"]+)}) { print "$$1\n"; }' \
	| tee list.txt
