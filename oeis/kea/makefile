#!make

# Generate Kimberling's expulsion array in an HTML triangle
# @(#) $Id$
# 2020-07-05: revival with diagonals
# 2018-05-02, Georg Fischer 
#---------------------------------
N=128
BASE=10
CENT=1
DEBUG=0
HTML=1
KNOWN=1
MAIN=1
PLACE=1
SUB=0

all: kea
kea:
	perl $(W) kea_html.pl $(N) -d $(DEBUG) \
	    -base $(BASE) -cent $(C) -known $(K) -main $(M) -place $(P) -html $(HTML) -sub $(SUB) \
	    > kea.html 2> kea.tmp
#---------------------------------------------------------------
# simple triangle
exp1:
	perl expell.pl 40 | tee expell.tmp
exp2:
	perl expell.pl 120 | tee expell.tmp
#--------
