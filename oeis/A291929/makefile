#!make

# Collatz sequences, OEIS A070165, A291939
# @(#) $Id$
# 2018-03-23, Georg Fischer

all: bfile
#----------
wget:
	wget https://oeis.org/A070165/a070165.txt
bfile:
	perl a291939.pl 0 a070165.txt | tee b291939.txt
#-----
detab:
	perl deA070165.pl b070165.txt | tee a070165.tab
	