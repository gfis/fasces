#!/usr/bin/make

# Experiments for FASS curves
# @(#) $Id: 024cbfe673e20777f8a8e3fd8d2568fdfa3db1ba $
# 2018-02-18, Georg Fischer

APPL=fasces
SRC=src/main/java/org/teherba/fasces
TESTDIR=test

all: regression
#-------------------------------------------------------------------
# Perform a regression test 
regression: 
	java -cp dist/$(APPL).jar \
			org.teherba.common.RegressionTester $(TESTDIR)/all.tests $(TEST) 2>&1 \
	| tee $(TESTDIR)/regression.log
	grep FAILED $(TESTDIR)/regression.log
#
# Recreate all testcases which failed (i.e. remove xxx.prev.tst)
# Handle with care!
# Failing testcases are turned into "passed" and are manifested by this target!
recreate: recr1 regr2
recr1:
	grep -E '> FAILED' $(TESTDIR)/regression*.log | cut -f 3 -d ' ' | xargs -l -ißß rm -v test/ßß.prev.tst
regr2:
	make regression TEST=$(TEST) > x.tmp
#---------------------------------------------------
# show manifests of appl.jar and appl-core.jar
manifests:
	unzip -p dist/$(APPL)-core.jar META-INF/MANIFEST.MF
	unzip -p dist/$(APPL).jar      META-INF/MANIFEST.MF
#---------------------------------------------------
jfind:
	find src -iname "*.java" | xargs -l grep -iH "$(JF)"
rmbak:
	find etc src web -iname "*.bak" | xargs -l rm -v
#--------------------------------------
zipart:
	zip -r fasce.part.`date +%Y-%m-%d`.zip \
	src \
	etc \
	$(TESTDIR)/all.tests \
	web \
	makefile
#--------------------------------------
test1:
	perl src/main/perl/Kn_syntax.pl 5

