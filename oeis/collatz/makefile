#!make

# Roads in the thicket of the Collatz graph
# @(#) $Id$
# 2018-08-17, Georg Fischer 
#---------------------------------
N=3290
K=64
D=0
S=4
I=6
M=html

all: roads
roads: 
	perl collatz_roads.pl   -n $(N)    -d $(D) -s $(S) -i $(I) -a contig > roads.html
roads.txt: 
	perl collatz_roads.pl   -n $(N)    -d $(D) -s $(S) -i $(I) -a contig -m tsv > roads.txt
fract6:
	perl collatz_fract6.pl  -n $(N)    -s 4    -i 6    | tee fract6.html
sub4mod6:
	perl collatz_roads.pl   -n 150000  -m tsv > roads.txt
	perl sub4mod6.pl roads.txt > sub1.tmp
	sed -e "s/\t/\n/g"           sub1.tmp | sort -n | uniq -c > sub2.tmp
#------------------
graph:
	perl collatz_graph.pl   -n $(N) > graph.html
patt2:
	perl collatz_pattern.pl -n 4096    -s 6    -i 2    > patt2.html
patt6:
	perl collatz_pattern.pl -n 4096    -s 4    -i 6    > patt6.html
fractal:
	perl collatz_pattern.pl -n 1000000 -s 3280 -i 4374 > fractal.html

#---------------------------------------------------------------
nodes:
	echo "364, 182, 91, 274, 137, 412, 206, 103, 310, 155, 466, 233, 700, 350, 175, 526, 263, 790, 395, 1186, 593, 1780, 890, 445, 1336, 668, 334, 167, 502, 251, 754, 377, 1132, 566, 283, 850, 425, 1276, 638, 319, 958, 479, 1438, 719, 2158, 1079, 3238, 1619, 4858, 2429, 7288, 3644, 1822, 911, 2734, 1367, 4102, 2051, 6154, 3077, 9232, 4616, 2308, 1154, 577, 1732, 866, 433, 1300, 650, 325, 976, 488, 244, 122, 61, 184, 92, 46, 23, 70, 35, 106, 53, 160, 80, 40, 20, 10, 5, 16, 8, 4, 2, 1]" > x.tmp
	grep -f x.tmp A070165.txt | tee nodes.tmp
