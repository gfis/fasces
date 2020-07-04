#!make

# Generate Kimberling's expulsion array in an HTML triangle
# @(#) $Id$
# 2018-05-02, Georg Fischer 
#---------------------------------
N=160
C=1
D=0
K=1
M=1
P=1
W=
B=9

all: kea
kea:
	perl $(W) kea_html.pl $(N) -b $(B) -c $(C) -d $(D) -k $(K) -m $(M) -p $(P) > kea.html 2> kea.tmp
#---------------------------------------------------------------
# simple triangle
exp1:
	perl expell.pl 40 | tee expell.tmp
exp2:
	perl expell.pl 120 | tee expell.tmp
#--------
