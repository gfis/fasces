#!/bin/make

# makefile for OEIS URL checking
# 2009-01-07, Georg Fischer, punctum(at)punctum.com
# The database files are named like
#	http://www.research.att.com/~njas/sequences/eisBTfry00000.txt
#----------------------------------------
all: do not call make without a target
check: down geturls spider eval

geturls:
	rm -f url*.txt
	find -name "eisBT*.txt" | xargs -l -ißß perl grepurl.pl ßß >> url1.txt
	sort -k2 url1.txt | tee url2.txt

testdown:
	wget -r -l1 -nd --no-parent -A.jpg http://localhost/html/hroschmann.de/
	ls -al *.jpg
	rm -f *.jpg
prep:
	perl prep_files.pl > filenames.tmp
down:
	wget -i filenames.tmp
#	wget -r -l1 --no-parent --ignore-length --accept=.txt http://www.research.att.com/~njas/sequences/
testspider:
	wget --spider --tries=1 --timeout=2 --force-html --follow-ftp --base=http://localhost/html/punctum.com/ -i /var/www/html/punctum.com/index.html 2>&1 | tee spider.log
spider:
#	cut -f 2 url2.txt | sort | uniq > url3.txt
	wget --spider --tries=1 --timeout=2 -i url.tmp.lst --base=http://www.research.att.com/~njas/sequences/ 2>&1 | tee spider.mats.log
eval:
	perl eval_log.pl spider*.log | sort | tee access.eval
count:
	wc access.eval
	cut -f 1 access.eval | sort | uniq -c | tee access.uniq.txt
dirs:
	mkdir url
	mkdir done
	mkdir open
split:
	perl split_url.pl url.split.txt 
gather:
	rm -f url.tmp.lst
	find url -name "*.lst" | sort | xargs -l cat >> url.tmp.lst
	
