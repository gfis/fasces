#!/bin/make

# Continued fractions of sqrt(n)
# @(#) $Id$
# 2021-02-18: sqrt20k.txt
# 2019-06-30, Georg Fischer
#
GITS=../../..
COMMON=$(GITS)/OEIS-mat/common
CFSQ=sqrt20k.txt

all:

sqrt20k:
	java -cp ../../../ramath/dist/ramath.jar org.teherba.ramath.ContinuedFraction -sqrt2 0 20000 \
	> $@.txt
#----
# Central element(s) in continued fraction expansion of sqrt(n) or 0 if no such element exists or -1 if n is a square
b308778:
#----
# First element of the period of the continued fraction expansion of sqrt(k), where the period has length 3
# 66	8;8,16
a308780:
	head -n 600  $(CFSQ) \
	| perl -ne 'if (m{\A\d+\s+\d+\;(\d+)\,\d+\s+\Z}) { print "$$1, ";}' \
	| tee $@.data
