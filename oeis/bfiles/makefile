#!make

all:

count:
	ls -1 *.txt | wc -l
comment:
	grep -iHE "\#" * | grep -v "synthesized" | cut -b 1-7 | sort | uniq | wc -
	
	