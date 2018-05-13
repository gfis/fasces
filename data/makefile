#!make

# in fasces/data
# @(#) $Id$
# 2018-05-10: even bases
# 2018-02-19: parse path expressions
# 2017-08-17
#-------------------------------------
B=5
D=0

all:
	# please use a specific makefile target: 
	grep -E "^[a-zA-Z0-9]+\:" makefile | head -n 20
#-------------------------------
# A220952 - Knuth's adjacency matrix
# compare results of expanded path expressions with Mathar's b-files
pexpr: pexpr5
pexpr3:
	perl gen_expr.pl 3 Kn | perl expand_expr.pl   > $@.pe.tmp
	tail -2 $@.pe.tmp     | perl vector_b-file.pl > $@.bf.tmp
	diff -w -C0  mathar.125.txt $@.bf.tmp
pexpr4:
	perl gen_expr.pl 4 Kn | perl expand_expr.pl   > $@.pe.tmp
	tail -2 $@.pe.tmp     | perl vector_b-file.pl > $@.bf.tmp
	diff -w -C0  mathar.625.txt $@.bf.tmp
pexpr5:
	perl gen_expr.pl 5 Kn | perl expand_expr.pl   > $@.pe.tmp
	tail -2 $@.pe.tmp     | perl vector_b-file.pl > $@.bf.tmp
	diff -w -C0 mathar.3125.txt $@.bf.tmp
#-------------------------------
# the millionth element is 132332103(5) = 667778(10)
# 5     6      7      8       9        10      <- exponents 
# 3125, 15625, 78125, 390625, 1953125, 9765625 <- powers of 5
pexpr9:
	perl gen_expr.pl 9 Kn | tee $@.ps.tmp
	perl expand_expr.pl $@.ps.tmp > $@.pd.tmp
	tail -2 $@.pd.tmp  | perl vector_b-file.pl \
	| head -n 1000003  | tail -4
	# x1M = 132332103 in base 5
# time make pexpr9 shows:
# 999998 132332202
# 999999 132332203
# 1000000 132332103
# 1000001 132332102
# # x1M = 132332103 in base 5
# 
# real	0m9.559s
# user	0m9.124s
# sys	0m0.580s
single:
	perl gen_expr.pl -1000000
	# Kn[1000000] 132332103(5)
#-------------------------------
# Fs adjacency matrix
pfs3:
	perl gen_expr.pl 3 Fs | perl expand_expr.pl   > $@.pe.tmp
	tail -2 $@.pe.tmp     | perl vector_b-file.pl > $@.bf.tmp
	perl gen_meander.pl  -i Fs -f -l 125 -b 5 -p "0,1,2,3,4,9,14,19,18,13,8,7,12,17,16,11,6,5,10,15,20,21,22,23,24"\
		> $@.gm.tmp
	diff -C1 -w $@.bf.tmp $@.gm.tmp
pfs5:
	perl gen_expr.pl 5 Fs | perl expand_expr.pl   > $@.pe.tmp
	tail -2 $@.pe.tmp     | perl vector_b-file.pl > $@.bf.tmp
	perl gen_meander.pl  -i Fs -f -l 3125 -b 5 -p "0,1,2,3,4,9,14,19,18,13,8,7,12,17,16,11,6,5,10,15,20,21,22,23,24"\
		> $@.gm.tmp
	diff -C1 -w $@.bf.tmp $@.gm.tmp
#-------------------------------
# partial 12222...
pr75:
	perl gen_meander.pl  -i r7 -f -l 3125 -b 5 -p "0,1,2,7,12,17,16,11,6,5,10,15,20,21,22,23,18,13,8,3,4,9,14,19,24"\
		> $@.gm.tmp
#-------------------------------
pls5a:
	perl gen_expr.pl 5 Fs | perl expand_expr.pl   > $@.pe.tmp
	tail -2 $@.pe.tmp     | perl vector_b-file.pl > $@.bf.tmp
pls5:
	perl gen_meander.pl  -i Ls -f -l 3125 -b 5 -p ="0,1,2,3,4,9,8,7,6,5,10,15,20,21,16,11,12,17,22,23,18,13,14,19,24"\
		> $@.gm.tmp
#-------------------------------
paths.2-6: paths.2 paths.3 paths.4 paths.5 paths.6
paths: 
	perl gen_paths.pl -b $(B) | tee paths.$(B).tmp
paths.2:
	perl gen_paths.pl -b 2    | tee $@.tmp
paths.3:
	perl gen_paths.pl -b 3    | tee $@.tmp
paths.4:
	perl gen_paths.pl -b 4    | tee $@.tmp
paths.5:
	perl gen_paths.pl -b 5    | tee $@.tmp
paths.6:
	perl gen_paths.pl -b 6    | tee $@.tmp
paths.7:
	perl gen_paths.pl -b 7 -s | tee $@.tmp
paths.9:
	perl gen_paths.pl -b 9 -s | tee $@.tmp
#----
rec_paths: rp1 rp2
rp1:
	perl gen_rec_paths.pl > rec_paths.tmp
rp2:
	perl rec_paths.tmp -b $(B) -d $(D) | tee rec_paths.$(B).tmp 
#----
3d_paths: 
	perl gen_3d_paths.pl > 3d_paths.tmp
	perl 3d_paths.tmp -b $(B) -d $(D) | tee 3d_paths.$(B).tmp 
#----
meander: meander5
meander.2:
	perl -w gen_paths.pl    -b 2 | grep " path=" | sed -e "s/ *path=//" | xargs  -l -iqqq \
	perl -w gen_meander.pl  -b 2 -l  1024 -p qqq | tee $@.tmp
meander.3:
	perl -w gen_paths.pl    -b 3 | grep " path=" | sed -e "s/ *path=//" | xargs  -l -iqqq \
	perl -w gen_meander.pl  -b 3 -l   729 -p qqq -f | tee $@.tmp
meander.4:
	perl -w gen_paths.pl    -b 4 | grep " path=" | sed -e "s/ *path=//" | xargs  -l -iqqq \
	perl -w gen_meander.pl  -b 4 -l  4096 -p qqq | tee $@.tmp
meander.5:
	perl -w gen_paths.pl    -b 5 | grep " path=" | sed -e "s/ *path=//" | xargs  -l -iqqq \
	perl -w gen_meander.pl  -b 5 -l  3125 -p qqq | tee $@.tmp
#----
mea0:
	perl gen_meander.pl -l 24 -b 5 -p "0,1,2,3,4,9,14,19,18,17,16,11,12,13,8,7,6,5,10,15,20,21,22,23,24"\
	| tee meander.25.tmp
#	perl gen_meander.pl -l 625 | tee meander.625.tmp
mea47:
	perl gen_meander.pl -l 125 -b 5 -f -p "0,1,2,3,4,9,8,7,6,5,10,15,20,21,16,11,12,17,22,23,18,13,14,19,24" \
	| tee meander.47.tmp
#-------------------------------
rebase:
	perl -w b-file_rebase.pl -f 16 -t 4 b-file_rebase.test.txt | tee b4.tmp
	perl -w b-file_rebase.pl -f 4       b4.tmp 
	perl -w b-file_rebase.pl            b4.tmp 
mathar:
	perl -w b-file_rebase.pl -f 10 -t 5 -z mathar.txt | grep -vE "^#" | head -63 | tee mathar5.tmp
	perl mirror5.pl mathar5.tmp | tee mathar125.tmp
	perl b-file_rebase.pl -f 5 -t 10 mathar125.tmp > m1.tmp
	perl mathar.pl 125 > m2.tmp
	diff -w m1.tmp m2.tmp
#-------------------------------
# old stuff
b53:
	cut -b 6-8   b53.man  > b1.tmp
	cut -b 48-50 b53.man >> b1.tmp
	sort b1.tmp > b2.tmp
	wc b2.tmp
	uniq -c b2.tmp | tee b3.tmp
	grep -v " 1 " b3.tmp
b53kr:
	sort -rn b53k.man > b53kr.tmp
	perl count.pl 625 > 625.tmp
svg: svge svgk svg4k
svge:
	perl b5_svg.pl -m 5 b53e.man > b53e.svg
svgk:
	perl b5_svg.pl -m 5 b53k.man > b53k.svg
svg4k:
	perl b5_svg.pl -m 5 b54k.man > b54k.svg
kalt3:
	perl kalt3.pl | grep -vE "^\#" | tee kalt3.tmp
	perl b5_svg.pl -m 5 kalt3.tmp > kalt3.svg
kalt4:
	perl kalt3.pl 4 | grep -vE "^\#" | tee kalt4.tmp
	perl b5_svg.pl -m 5 kalt4.tmp > kalt4.svg
zorro: zorro3 zorro4
zorro2:
	rm -f b52f*.gen
	perl zorroa.pl 2 | tee zorro2.tmp
	make z5svg
zorro3:
	perl zorroa.pl 3 | grep -vE "^\#" | tee zorro3.tmp
	perl b5_svg.pl -m 5                     zorro3.tmp > zorro3.svg
zorro4:
	perl zorroa.pl 4 | grep -vE "^\#" | tee zorro4.tmp
	perl b5_svg.pl -m 5                     zorro4.tmp > zorro4.svg
z5: z5a
z5a:
	rm -f b53f*.gen
	perl zorroa.pl 3 
z5svg:
	find . -iname "*.gen" | xargs -l -iqqq make z5svg1 GEN=qqq
z5svg1:
	perl b5_svg.pl -m 5 $(GEN) > $(GEN).svg
z3:
	rm -f b53f*.gen
	perl zorroa.pl 3
sums:
	md5sum *.gen | cut -d " " -f 1 | sort | uniq -c | grep -v " 1 " 
find:
	grep -iH -E "^43" *.gen
z53:
	perl mirror5.pl z53.half.man > z53.bf
	perl b5_svg.pl -m 5 z53.bf > z53.svg
mathar_svg:
	perl b5_svg.pl -d 5 b220952.txt > a220952.mathar.svg
gen2z:
	perl gen2zc.pl 3 | grep -vE "^\#" > gen2z.tmp
	perl b5_svg.pl -m 5 gen2z.tmp > gen2z.svg
	cut -d " " -f 1 gen2z.tmp  > g1.tmp
	cut -d " " -f 2 gen2z.tmp >> g1.tmp
	sort -n g1.tmp > g2.tmp
	wc g2.tmp
	tail -4 g2.tmp
	uniq -c g2.tmp | grep -v " 2 "
vertex:
	perl vertex.pl -m 5 gen2z.tmpq	
#-------------------------------
# Generate SVG for n = 0..625
svg6: Fs6 Kn6 Ls6 Ln6 nn6 nI6

Fs:
	perl gen_meander.pl  -i Fs -l 124 -b 5 -p "0,1,2,3,4,9,14,19,18,13,8,7,12,17,16,11,6,5,10,15,20,21,22,23,24" \
	                      > Fs.tmp
	grep -vE "[\<\=\@]"     Fs.tmp \
	| perl b5_svg.pl -m 5 > Fs.svg
Fs6:
	perl gen_meander.pl  -i Fs -l 624 -b 5 -p "0,1,2,3,4,9,14,19,18,13,8,7,12,17,16,11,6,5,10,15,20,21,22,23,24" \
	                      > Fs6.tmp
	grep -vE "[\<\=\@]"     Fs6.tmp \
	| perl b5_svg.pl -m 5 > Fs6.svg
Kn:
	perl gen_meander.pl  -i Kn -l 124 -b 5 -p "0,1,2,3,4,9,14,19,18,17,16,11,12,13,8,7,6,5,10,15,20,21,22,23,24" \
	                      > Kn.tmp
	grep -vE "[\<\=\@]"     Kn.tmp \
	| perl b5_svg.pl -m 5 > Kn.svg
Kn6:
	perl gen_meander.pl  -i Kn -l 624 -b 5 -p "0,1,2,3,4,9,14,19,18,17,16,11,12,13,8,7,6,5,10,15,20,21,22,23,24" \
	                      > Kn6.tmp
	grep -vE "[\<\=\@]"     Kn6.tmp \
	| perl b5_svg.pl -m 5 > Kn6.svg
Ls6:
	perl gen_meander.pl  -i Ls -l 624 -b 5 -p "0,1,2,3,4,9,8,7,6,5,10,15,20,21,16,11,12,17,22,23,18,13,14,19,24" \
	                      > Ls6.tmp
	grep -vE "[\<\=\@]"     Ls6.tmp \
	| perl b5_svg.pl -m 5 > Ls6.svg
Ln6:
	perl gen_meander.pl  -i Ln -l 624 -b 5 -p "0,1,2,3,4,9,8,7,6,5,10,15,20,21,16,11,12,13,14,19,18,17,22,23,24" \
	                      > Ln6.tmp
	grep -vE "[\<\=\@]"     Ln6.tmp \
	| perl b5_svg.pl -m 5 > Ln6.svg
nn6:
	perl gen_meander.pl  -i nn -l 624 -b 5 -p "0,1,2,7,6,5,10,11,12,17,16,15,20,21,22,23,18,13,8,3,4,9,14,19,24" \
	                      > nn6.tmp
	grep -vE "[\<\=\@]"     nn6.tmp \
	| perl b5_svg.pl -m 5 > nn6.svg
nI6:
	perl gen_meander.pl  -i nI -l 624 -b 5 -p "0,1,2,7,6,5,10,11,12,13,8,3,4,9,14,19,18,17,16,15,20,21,22,23,24" \
	                      > nI6.tmp
	grep -vE "[\<\=\@]"     nI6.tmp \
	| perl b5_svg.pl -m 5 > nI6.svg
#------------------------------------
flatKn:
	perl gen_meander.pl -l 125        -b 5 -p "0,1,2,3,4,9,14,19,18,17,16,11,12,13,8,7,6,5,10,15,20,21,22,23,24" \
	> flatKn1.tmp
	perl flatten.pl -d 0 flatKn1.tmp | tee flatKn2.tmp 
flatFs:
	perl gen_meander.pl -l 125        -b 5 -p "0,1,2,3,4,9,14,19,18,13,8,7,12,17,16,11,6,5,10,15,20,21,22,23,24" \
	> flatFs1.tmp
	perl flatten.pl -d 0 flatFs1.tmp | tee flatFs2.tmp 
#------------------------------------
# JavaScript preparation
Knjs:	
	perl gen_meander.pl  -i Kn -l 124 -b 5 -p "0,1,2,3,4,9,14,19,18,17,16,11,12,13,8,7,6,5,10,15,20,21,22,23,24" \
	                      > Kn.tmp
	grep -vE "[\<\=\@]"     Kn.tmp \
	| grep -E "[0-9]" \
	| cut -d " " -f 2 \
	| sed -e "s/^/,/g" \
	| tee $@.tmp
Fsjs:	
	perl gen_meander.pl  -i Fs -l 124 -b 5 -f -p "0,1,2,3,4,9,14,19,18,13,8,7,12,17,16,11,6,5,10,15,20,21,22,23,24" \
	                      > Fs.tmp
	grep -vE "[\<\=\@]"     Fs.tmp \
	| grep -E "[0-9]" \
	| cut -d " " -f 2 \
	| sed -e "s/^/,/g" \
	| perl -Ep "s/\\n//"\
	| tee $@.tmp
Fujs:	
	perl gen_meander.pl  -i Fu -l 124 -b 5 -p "0,1,2,3,4,9,8,7,6,5,10,15,20,21,16,11,12,17,22,23,18,13,14,19,24" \
	                      > Fu.tmp
	grep -vE "[\<\=\@]"     Fu.tmp \
	| grep -E "[0-9]" \
	| cut -d " " -f 2 \
	| sed -e "s/^/,/g" \
	| tee $@.tmp
	
proof1:
	perl gen_meander.pl -p "0,1,2,5,4,3,6,7,8" -b 3 -l 81 -f | tee r3.tmp
