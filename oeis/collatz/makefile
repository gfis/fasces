#!make

# Order in the thicket of the Collatz graph
# @(#) $Id$
# 2019-08-07: segment V2.0
# 2018-12-21: a32tree.pl
# 2018-08-17, Georg Fischer 
#---------------------------------
N=800
K=64
D=0
S=22
I=18
M=html
SRC=comp.html

all: lists
lists: style dirs templates
#----
dirs: comp double detail atab degr super roots
comp: 
	perl segment.pl         -n $(N)    -d $(D)                 -a comp   > $@.html
double: 
	perl segment.pl         -n $(N)    -d $(D)                 -a double > $@.html
detail: 
	perl segment.pl         -n $(N)    -d $(D)                 -a detail > $@.html
super: 
	perl segment.pl         -n $(N)    -d $(D)                 -a super  > $@.html
roots: root1 root2_18 root2 root3 root4
root1: 
	perl segment.pl -r 1    -n $(N)    -d $(D)                 -a comp   > $@.html
root2_18: 
	perl segment.pl -r 2    -n $(N)    -d $(D) -s 4  -i 18     -a comp   > $@.html 
root2:  
	perl segment.pl -r 2    -n $(N)    -d $(D) -s 1  -i 3      -a comp   > $@.html 
root3:  
	perl segment.pl -r 3    -n $(N)    -d $(D) -s 1  -i 3      -a comp   > $@.html 
root4:  
	perl segment.pl -r 4    -n $(N)    -d $(D) -s 1  -i 3      -a comp   > $@.html 

t7_13_18:
	perl segment.pl         -n $(N)    -d $(D) -s 7,13    -i 18   -a comp   > $@.html
t10_18:                                                   
	# only lhs is yellow ("ending")
	perl segment.pl         -n $(N)    -d $(D) -s 10      -i 18   -a comp   > $@.html
t16_18:                                                   
	# yellow target                                       
	perl segment.pl         -n $(N)    -d $(D) -s 16      -i 18   -a comp   > $@.html
r9_10:                                                    
	# rules 9, 10; rather structured                
	# perl segment.pl         -n $(N)    -d $(D) -s 10,22   -i 24   -a comp   > $@.html
	perl segment.pl         -n $(N)    -d $(D) -s 2,6     -i 8    -a comp   > $@.html
#----                                                     
degr: degree2 degree3 degree4                                    
degree2:                                                  
	perl segment.pl         -n $(N)    -d $(D) -s 4       -i 6    -a comp   > $@.html
degree3:                                                  
	perl segment.pl         -n $(N)    -d $(D) -s 22      -i 36   -a comp   > $@.html
degree4:                                                  
	perl segment.pl         -n $(N)    -d $(D) -s 22      -i 108  -a comp   > $@.html
#----                                                     
t18:                                                      
	perl segment.pl         -n 10000   -d $(D) -s 7,16    -i 18   -a comp   > $@.html
tests: test1 test2                                        
test1:                                                    
	perl segment.pl         -n 100000  -d $(D) -m tsv             -a test1 | tee $@.html
test2:                                                    
	perl segment.pl         -n 100000  -d $(D) -m tsv             -a test2 | tee $@.html
#----
style:
	perl segment.pl -a style | tee stylesheet.css
atab:
	perl attachtab.pl -c 2> x.tmp | tee $@.wiki 
#----
templates: e1 exam2
e1:
	perl segment.pl -n 8  -m htm -a comp > $@.htm
exam2:
	perl segment.pl -n 62 -b 1000 -m htm -a comp \
	| perl filter_exam.pl -h 0 -l 7 -n 61 | tee $@.htm
deploy:
	scp stylesheet.css \
		comp.html double.html detail.html \
		super.html \
		root1.html root2.html root3.html root4.html \
		degree2.html degree3.html degree4.html \
		gfis@punctum.com:/var/www/html/teherba.org/fasces/oeis/collatz/
#--------
a32tab: a32t1 a32t2 a32t3 a32t4
a32t1:
	perl a32tab.pl 10000000 > a32tab.tmp
	sed -e "s/ /\n/g" a32tab.tmp | sort -n | uniq -c \
	| sed -e "s/^ *//" > a32_uniqc.tmp 
a32t2:
	# all counts are 1?
	grep -v "^1 " a32_uniqc.tmp	|| :
a32t3:
	cut -d " " -f 2 a32_uniqc.tmp                              > a32_d1.tmp
	cat -n a32_uniqc.tmp | sed -e "s/^ *//" | cut -d "	" -f 1 > a32_d2.tmp
a32t4:
	diff -w --suppress-common-lines --width=32 -y a32_d1.tmp a32_d2.tmp | head -8
# result for 10 mio. is (delta 16384):
#              > 65536
#              > 81920
#              > 90112
#              > 98304
#              > 118784
#              > 122880
#              > 131072
#              > 135168
a32tree:
	perl a32tree.pl
#==========================
ladder:
	perl long_ladder.pl -n $(N) > $@.1.tmp
	sort -n $@.1.tmp> $@.2.tmp
	cut -f 1 $@.2.tmp | uniq -c | grep -v " 1 " > $@.3.tmp
#==========================
# old targets

rails: 
	perl collatz_rails.pl   -n $(N)    -d $(D) -s $(S) -i $(I) -a simple > rails.html
eawefr: west east free
west: 
	perl collatz_rails.pl   -n $(N)    -d $(D) -s $(S) -i $(I) -a west   > west.html
east: 
	perl collatz_rails.pl   -n $(N)    -d $(D) -s $(S) -i $(I) -a east   > east.html
free: 
	perl collatz_rails.pl   -n $(N)    -d $(D) -s $(S) -i $(I) -a free   > free.html
crop: 
	perl collatz_rails.pl   -n $(N)    -d $(D) -s $(S) -i $(I) -a crop   > crop.html
roads: 
	perl collatz_roads.pl   -n $(N)    -d $(D) -s $(S) -i $(I) -a contig > roads.html
txt:
	perl collatz_roads.pl   -n $(N)    -d $(D) -s $(S) -i $(I) -a contig -m tsv > roads.txt
fract6:
	perl collatz_fract6.pl  -n $(N)    -s 4    -i 6    | tee fract6.html
sub4mod6:
	perl collatz_roads.pl   -n 150000  -m tsv > roads.txt
	perl sub4mod6.pl roads.txt > sub1.tmp
	sed -e "s/\t/\n/g"           sub1.tmp | sort -n | uniq -c > sub2.tmp
expand:
	perl expand32.pl -n 4096 | tee expand.tmp
tract_3xp1:
	perl traject.pl -mul 3 -add  1 -div 2 | tee $@.tmp
tract_3xm1:
	perl traject.pl -mul 3 -add -1 -div 2 | tee $@.tmp
tract_4xm1:
	perl traject.pl -mul 4 -add -1 -div 3 | tee $@.tmp
#------------------
kernels:
	lynx -dump rails.html | grep ">" | sed -e "s/^ *//" | cut -d " " -f 1 \
	> kernels.tmp
kerneval:
	perl kerneval.pl -n 256 kernels.tmp | tee kerneval.tmp
#------------------
invar6:
	perl gen_invariants.pl -i    6 -s -2   > invariants.html
invar36:                                  
	perl gen_invariants.pl -i   36 -s -14  > invariants.html
invar216:                                 
	perl gen_invariants.pl -i  216 -s -86  > invariants.html
invar1296:                                 
	perl gen_invariants.pl -i 1296 -s -518 > invariants.html
#------------------
graph:
	perl collatz_graph.pl   -n $(N) > graph.html
patt2:
	perl collatz_pattern.pl -n 4096    -s 6    -i 2    > patt2.html
patt6:
	perl collatz_pattern.pl -n 4096    -s 4    -i 6    > patt6.html
fractal:
	perl collatz_pattern.pl -n 1000000 -s 3280 -i 4374 > fractal.html
#------------------
lengths:
	grep -vE ",[0-5]" kernels.tmp
#---------------------------------------------------------------
nodes:
	echo "364, 182, 91, 274, 137, 412, 206, 103, 310, 155, 466, 233, 700, 350, 175, 526, 263, 790, 395, 1186, 593, 1780, 890, 445, 1336, 668, 334, 167, 502, 251, 754, 377, 1132, 566, 283, 850, 425, 1276, 638, 319, 958, 479, 1438, 719, 2158, 1079, 3238, 1619, 4858, 2429, 7288, 3644, 1822, 911, 2734, 1367, 4102, 2051, 6154, 3077, 9232, 4616, 2308, 1154, 577, 1732, 866, 433, 1300, 650, 325, 976, 488, 244, 122, 61, 184, 92, 46, 23, 70, 35, 106, 53, 160, 80, 40, 20, 10, 5, 16, 8, 4, 2, 1]" > x.tmp
	grep -f x.tmp A070165.txt | tee nodes.tmp
#------------------
once: once0 once1 once2 once3
once0:
	lynx -dump --width=300 comp.html | grep -v "[a-zA-Z]" | grep -E "[0-9]" \
	| sed -e "s/\[[0-9]*\]//g" -e "s/^ *//" -e "s/  */ /g" \
	| cut -d" " -f2- > once0.tmp
once1:
	cut -d" " -f1  once0.tmp \
	| sort -n | uniq -c > once1u.tmp
	grep -v "  1 "        once1u.tmp | tee once1.tmp
once2:
	cut -d" " -f2- once0.tmp | sed -e "s/ /\\n/g" \
	| sort -n | uniq -c > once2u.tmp
	grep -v "  1 "        once2u.tmp | tee once2.tmp
once3:
	sort -n once1u.tmp once2u.tmp | uniq -c | grep -v "  2 " || :
#-----------------------
coin:
	perl mod_coin.pl | tee coin2.txt
