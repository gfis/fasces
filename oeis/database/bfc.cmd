cut -d" " -f 2 ../bfiles/b%1.txt > x.tmp
cut -d" " -f 2 ../bfiles/b%2.txt > y.tmp
diff -y --width=64 x.tmp y.tmp | tee z.tmp | less
grep -E "[\<\>]" z.tmp
