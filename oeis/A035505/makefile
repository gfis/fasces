#!make

# Generate Kimberling's expulsion array in an HTML triangle
# @(#) $Id$
# 2018-05-02, Georg Fischer 
#---------------------------------
N=100
C=0

all: kea
kea:
	perl kea_html.pl $(N) $(C) > kea.html
#---------------------------------------------------------------
# simple triangle
exp1:
	perl expell.pl 40 | tee expell.tmp
exp2:
	perl expell.pl 120 | tee expell.tmp
#--------
