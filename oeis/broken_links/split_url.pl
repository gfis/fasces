#!/usr/bin/perl

# split a file with URLs
# 2009-01-10, Georg Fischer <punctum (at) punctum.com> 

use strict;

	while (<>) {
		s[\r?\n][]; # chompr
		if (m[\A\#\>(.+)]) { # new file's name
			my $file = "url/url.$1.lst";
			close OUT;
			open (OUT, ">", $file) or die "cannot write to $file\n";
			print STDERR "writing $file\n";
		} else {
			print OUT "$_\n";
		}
	} # while <>
	close OUT;
__DATA__
#>ftp
ftp://164.214.2.65/pub/gig/tr8350.2/wgs84fin.pdf
ftp://arp.anu.edu.au/pub/papers/slaney/finder/finder.ps.gz
ftp://ftp.ai.mit.edu/pub/cube-lovers/cube-mail-15.gz
ftp://ftp.ai.mit.edu/pub/cube-lovers/cube-mail-16.gz
ftp://ftp.ai.mit.edu/pub/cube-lovers/cube-mail-17.gz
ftp://ftp.ai.mit.edu/pub/cube-lovers/cube-mail-25.gz
ftp://ftp.ai.mit.edu/pub/cube-lovers/cube-mail-26.gz
ftp://ftp.ai.mit.edu/pub/cube-lovers/cube-mail-6.gz
ftp://ftp.cis.upenn.edu/pub/wilf/josephus.ps
ftp://ftp.comlab.ox.ac.uk/pub/Documents/techpapers/Richard.Brent/trinom/table.txt
ftp://ftp.cs.yale.edu/pub/mcdermott/software/pddl.tar.gz
ftp://ftp.dpmms.cam.ac.uk/pub/Carmichael/
ftp://ftp.dpmms.cam.ac.uk/pub/PSP/
ftp://ftp.dpmms.cam.ac.uk/pub/PSP/even-12
ftp://ftp.inria.fr/INRIA/publication/Theses/TU-0144/ch4.ps
ftp://ftp.mathe2.uni-bayreuth.de/axel/combalg/combalg.ps
ftp://ftp.mathe2.uni-bayreuth.de/axel/papers/noebauer:the_number_of_small_rings.ps
ftp://ftp.mathe2.uni-bayreuth.de/meringer/pdf/MathCombChemSCCE.pdf
ftp://ftp.math.tu-dresden.de/pub/reports/alg/poeschel/lispoepp.ps
ftp://ftp.reed.edu/users/jpb/
ftp://ftp.win.tue.nl/pub/techreports/cosor/98-17.ps
ftp://pi.super-computing.org/.1/
ftp://unix.ksu.edu/pub/pentadecet/proveprm.ps
ftp://www.algebra.uni-linz.ac.at/pub/noebauer/smallrings.ps.gz
ftp://www.algebra.uni-linz.ac.at/pub/noebauer/thesis.ps.gz
#>digits
http://11011110.livejournal.com/58994.html
http://11011110.livejournal.com/96470.html
http://11011110.livejournal.com/97325.html
http://134.129.111.8/scripts/wa.exe?A2=ind0003&L=nmbrthry&P=R44
http://134.129.111.8/scripts/wa.exe?A2=ind9609&L=nmbrthry&P=R23
http://134.76.163.65/agora_docs/38910TABLE_OF_CONTENTS.html
http://134.76.163.65/servlet/digbib?template=view.html&id=166640&startpage=132&endpage=148&image-path=http://134.76.176.141/cgi-bin/letgifsfly.cgi&image-subpath=/4229&image-subpath=4229&pagenumber=132&imageset-id=4229

