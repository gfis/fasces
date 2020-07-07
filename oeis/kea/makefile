#!make

# Generate Kimberling's expulsion array in an HTML triangle
# @(#) $Id$
# 2020-07-05: revival with diagonals
# 2018-05-02, Georg Fischer 
#---------------------------------
N=128
BASE=10
CENT=0
DEBUG=0
HTML=1
KNOWN=1
S=1

all: kea
kea:
	perl $(W) kea_html.pl $(N) -d $(DEBUG) -base $(BASE) -cent $(CENT) -known $(KNOWN) -html $(HTML) -s $(S) > kea.html 2> kea.tmp
	grep -E "relation [0-9]" kea.html
#---------------------------------------------------------------
# simple triangle
exp1:
	perl expell.pl 40 | tee expell.tmp
exp2:
	perl expell.pl 120 | tee expell.tmp
#--------
