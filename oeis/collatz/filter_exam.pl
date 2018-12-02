#!perl

# Filter example HTM files 
# @(#) $Id$
# 2018-12-02, Georg Fischer
#------------------------------------------------------
# Usage:
#   perl filter_exam.pl [-mul mult] [-add add] [-div div] [-l limit] [-n maxn] [-d debug]
#
#--------------------------------------------------------
use strict;
use integer;
my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime (time);
my $TIMESTAMP = sprintf ("%04d-%02d-%02d %02d:%02d:%02d"
        , $year + 1900, $mon + 1, $mday, $hour, $min, $sec);
#----------------
# get commandline options
my $debug  = 0;
my $head   = 1;  # whether table headers should be shown
my $limit  = 7;  # index of last example segment to be shown
my $maxn   = 61; # index of last segment to be shown

while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A\-})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt =~ m{\A\-h}) {
        $head   = shift(@ARGV);
    } elsif ($opt =~ m{\A\-d}) {
        $debug  = shift(@ARGV);
    } elsif ($opt =~ m{\A\-l}) {
        $limit  = shift(@ARGV);
    } elsif ($opt =~ m{\A\-n}) {
        $maxn  = shift(@ARGV);
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while $opt
#----------------
# processing 
my $iseg;
while (<>) {
	s{\s+\Z}{}; # chompr
	my $line = $_;
	if (0) {
	} elsif ($head == 0 and ($line =~ m{\A\<(\/?tr\>\Z|td )})) {
		# skip
	} elsif ($line =~ m{\"\>(\d+)\<\/td}) { # table body row
		;
		$iseg = $1;
		if (0) {
		} elsif ($iseg == $limit) {
			print "$line\n";
			&ellipsis();
		} elsif ($iseg == $maxn ) {
			print "$line\n";
			&ellipsis();
		} elsif ($iseg <  $limit) {
			print "$line\n";
		}
		# table body row
	} else {
		print "$line\n";
	}
} # while $itr

# end main
#================================
sub ellipsis {
	print "<tr><td>...</td></tr>\n";
} # ellipsis
#----------------
__DATA__
<!-- 3x+1  Compressed Segment Directory C -->
<table style="border-collapse: collapse; text-align: right;  padding-right: 4px;">
<tr>
<td class="arl bot" colspan="4">Column</td>
<td class="arc">1</td>
<td class="arc">5</td>
<td class="arc">6</td>
<td class="arc">9</td>
<td class="arc">10</td>
<td class="arc">13</td>
<td class="arc">14</td>
<td class="arc">17</td>
<td class="arc">18</td>
<td class="arc">21</td>
<td class="arc">22</td>
</tr>
<tr>
<td class="arc">i</td><td class="arc">k</td>
<td class="arc bor           ">SR</td>
<td class="arc bor           ">TdR</td>
<td class="arc bor           ">LS</td>
<td class="arc bor seg rule5 ">&micro;&micro;</td>
<td class="arc bor seg rule6 ">&delta;&micro;&micro;</td>
<td class="arc bor seg rule9 ">&micro;&micro;&sigma;<sup>1</sup></td>
<td class="arc bor seg rule10">&delta;&micro;&micro;&sigma;<sup>1</sup></td>
<td class="arc bor seg rule13">&micro;&micro;&sigma;<sup>2</sup></td>
<td class="arc bor seg rule14">&delta;&micro;&micro;&sigma;<sup>2</sup></td>
<td class="arc bor seg rule17">&micro;&micro;&sigma;<sup>3</sup></td>
<td class="arc bor seg rule18">&delta;&micro;&micro;&sigma;<sup>3</sup></td>
<td class="arc bor seg rule21">&micro;&micro;&sigma;<sup>4</sup></td>
<td class="arc bor seg rule22">&delta;&micro;&micro;&sigma;<sup>4</sup></td>
</tr>
<tr><td class="arc">1</td><td class="arc bor">0</td><td class="arc rule6" title="(6)-1">6</td><td class="arc bor">&nbsp;</td><td title="(6)-4" class="super1 bor" id="A4">4</td><td id="16" title="(5)-4" class="super1 bor seg">16</td><td id="4" title="(6)-4" class="super1 bor seg">4</td><td id="10" title="(9)-4" class="super1 bor seg">10</td></tr>
<tr><td class="arc">2</td><td class="arc bor">0</td><td class="arc rule9" title="(9)-1">9</td><td class="arc bor">&nbsp;</td><td title="(9)-4" class="super1 bor" id="A10">10</td><td id="40" title="(5)-10" class="super1 bor seg">40</td></tr>
<tr><td class="arc">3</td><td class="arc bor">0</td><td class="arc rule5" title="(5)-1">5</td><td class="arc bor">&nbsp;</td><td title="(5)-4" class="super1 bor" id="A16">16</td><td id="64" title="(5)-16" class="super1 bor seg">64</td></tr>
<tr><td class="arc">4</td><td class="arc bor">0</td><td class="arc rule14" title="(14)-7">14</td><td class="arc rule5" title="(5)-2">5</td><td title="(14)-40" class="super2 bor" id="A22">22</td><td id="88" title="(5)-22" class="super1 bor seg">88</td><td id="28" title="(6)-22" class="super1 bor seg">28</td><td id="58" title="(9)-22" class="super2 bor seg">58</td></tr>
<tr><td class="arc">5</td><td class="arc bor">1</td><td class="arc rule6" title="(6)-4">6</td><td class="arc bor">&nbsp;</td><td title="(6)-22" class="super1 bor" id="A28">28</td><td id="112" title="(5)-28" class="super1 bor seg">112</td></tr>
<tr><td class="arc">6</td><td class="arc bor">0</td><td class="arc rule10" title="(10)-7">10</td><td class="arc rule5" title="(5)-2">5</td><td title="(10)-40" class="super1 bor" id="A34">34</td><td id="136" title="(5)-34" class="super1 bor seg">136</td></tr>
<tr><td class="arc">7</td><td class="arc bor">1</td><td class="arc rule5" title="(5)-2">5</td><td class="arc bor">&nbsp;</td><td title="(5)-10" class="super1 bor" id="A40">40</td><td id="160" title="(5)-40" class="super1 bor seg">160</td><td id="52" title="(6)-40" class="super1 bor seg">52</td><td id="106" title="(9)-40" class="super1 bor seg">106</td><td id="34" title="(10)-40" class="super1 bor seg">34</td><td id="70" title="(13)-40" class="super1 bor seg">70</td><td id="22" title="(14)-40" class="super2 bor seg">22</td><td id="46" title="(17)-40" class="super1 bor seg">46</td></tr>
<tr><td class="arc">8</td><td class="arc bor">0</td><td class="arc rule17" title="(17)-7">17</td><td class="arc bor">&nbsp;</td><td title="(17)-40" class="super1 bor" id="A46">46</td><td id="184" title="(5)-46" class="super1 bor seg">184</td></tr>
<tr><td class="arc">9</td><td class="arc bor">2</td><td class="arc rule6" title="(6)-7">6</td><td class="arc bor">&nbsp;</td><td title="(6)-40" class="super1 bor" id="A52">52</td><td id="208" title="(5)-52" class="super1 bor seg">208</td></tr>
<tr><td class="arc">10</td><td class="arc bor">1</td><td class="arc rule9" title="(9)-4">9</td><td class="arc bor">&nbsp;</td><td title="(9)-22" class="super2 bor" id="A58">58</td><td id="232" title="(5)-58" class="super1 bor seg">232</td><td id="76" title="(6)-58" class="super1 bor seg">76</td><td id="154" title="(9)-58" class="super1 bor seg">154</td></tr>
<tr><td class="arc">11</td><td class="arc bor">2</td><td class="arc rule5" title="(5)-3">5</td><td class="arc bor">&nbsp;</td><td title="(5)-16" class="super1 bor" id="A64">64</td><td id="256" title="(5)-64" class="super1 bor seg">256</td></tr>
<tr><td class="arc">12</td><td class="arc bor">0</td><td class="arc rule13" title="(13)-7">13</td><td class="arc bor">&nbsp;</td><td title="(13)-40" class="super1 bor" id="A70">70</td><td id="280" title="(5)-70" class="super1 bor seg">280</td></tr>
<tr><td class="arc">13</td><td class="arc bor">3</td><td class="arc rule6" title="(6)-10">6</td><td class="arc bor">&nbsp;</td><td title="(6)-58" class="super1 bor" id="A76">76</td><td id="304" title="(5)-76" class="super1 bor seg">304</td><td id="100" title="(6)-76" class="super1 bor seg">100</td><td id="202" title="(9)-76" class="super2 bor seg">202</td></tr>
<tr><td class="arc">14</td><td class="arc bor">1</td><td class="arc rule10" title="(10)-16">10</td><td class="arc super2" title="(22)-61">94</td><td title="(10)-94" class="super1 bor" id="A82">82</td><td id="328" title="(5)-82" class="super1 bor seg">328</td></tr>
<tr><td class="arc">15</td><td class="arc bor">3</td><td class="arc rule5" title="(5)-4">5</td><td class="arc bor">&nbsp;</td><td title="(5)-22" class="super1 bor" id="A88">88</td><td id="352" title="(5)-88" class="super1 bor seg">352</td></tr>
<tr><td class="arc">16</td><td class="arc bor">0</td><td class="arc rule22" title="(22)-61">22</td><td class="arc rule6" title="(6)-46">6</td><td title="(22)-364" class="super2 bor" id="A94">94</td><td id="376" title="(5)-94" class="super1 bor seg">376</td><td id="124" title="(6)-94" class="super1 bor seg">124</td><td id="250" title="(9)-94" class="super1 bor seg">250</td><td id="82" title="(10)-94" class="super1 bor seg">82</td><td id="166" title="(13)-94" class="super2 bor seg">166</td></tr>
<tr><td class="arc">17</td><td class="arc bor">4</td><td class="arc rule6" title="(6)-13">6</td><td class="arc bor">&nbsp;</td><td title="(6)-76" class="super1 bor" id="A100">100</td><td id="400" title="(5)-100" class="super1 bor seg">400</td></tr>
<tr><td class="arc">18</td><td class="arc bor">2</td><td class="arc rule9" title="(9)-7">9</td><td class="arc bor">&nbsp;</td><td title="(9)-40" class="super1 bor" id="A106">106</td><td id="424" title="(5)-106" class="super1 bor seg">424</td></tr>
<tr><td class="arc">19</td><td class="arc bor">4</td><td class="arc rule5" title="(5)-5">5</td><td class="arc bor">&nbsp;</td><td title="(5)-28" class="super1 bor" id="A112">112</td><td id="448" title="(5)-112" class="super1 bor seg">448</td><td id="148" title="(6)-112" class="super1 bor seg">148</td><td id="298" title="(9)-112" class="super1 bor seg">298</td></tr>
<tr><td class="arc">20</td><td class="arc bor">1</td><td class="arc rule14" title="(14)-34">14</td><td class="arc super2" title="(9)-13">202</td><td title="(14)-202" class="super1 bor" id="A118">118</td><td id="472" title="(5)-118" class="super1 bor seg">472</td></tr>
<tr><td class="arc">21</td><td class="arc bor">5</td><td class="arc rule6" title="(6)-16">6</td><td class="arc bor">&nbsp;</td><td title="(6)-94" class="super1 bor" id="A124">124</td><td id="496" title="(5)-124" class="super1 bor seg">496</td></tr>
<tr><td class="arc">22</td><td class="arc bor">2</td><td class="arc rule10" title="(10)-25">10</td><td class="arc rule6" title="(6)-19">6</td><td title="(10)-148" class="super3 bor" id="A130">130</td><td id="520" title="(5)-130" class="super1 bor seg">520</td><td id="172" title="(6)-130" class="super1 bor seg">172</td><td id="346" title="(9)-130" class="super3 bor seg">346</td></tr>
<tr><td class="arc">23</td><td class="arc bor">5</td><td class="arc rule5" title="(5)-6">5</td><td class="arc bor">&nbsp;</td><td title="(5)-34" class="super1 bor" id="A136">136</td><td id="544" title="(5)-136" class="super1 bor seg">544</td></tr>
<tr><td class="arc">24</td><td class="arc bor">0</td><td class="arc rule18" title="(18)-61">18</td><td class="arc rule6" title="(6)-46">6</td><td title="(18)-364" class="super1 bor" id="A142">142</td><td id="568" title="(5)-142" class="super1 bor seg">568</td></tr>
<tr><td class="arc">25</td><td class="arc bor">6</td><td class="arc rule6" title="(6)-19">6</td><td class="arc bor">&nbsp;</td><td title="(6)-112" class="super1 bor" id="A148">148</td><td id="592" title="(5)-148" class="super1 bor seg">592</td><td id="196" title="(6)-148" class="super1 bor seg">196</td><td id="394" title="(9)-148" class="super1 bor seg">394</td><td id="130" title="(10)-148" class="super3 bor seg">130</td><td id="262" title="(13)-148" class="super1 bor seg">262</td></tr>
<tr><td class="arc">26</td><td class="arc bor">3</td><td class="arc rule9" title="(9)-10">9</td><td class="arc bor">&nbsp;</td><td title="(9)-58" class="super1 bor" id="A154">154</td><td id="616" title="(5)-154" class="super1 bor seg">616</td></tr>
<tr><td class="arc">27</td><td class="arc bor">6</td><td class="arc rule5" title="(5)-7">5</td><td class="arc bor">&nbsp;</td><td title="(5)-40" class="super1 bor" id="A160">160</td><td id="640" title="(5)-160" class="super1 bor seg">640</td></tr>
<tr><td class="arc">28</td><td class="arc bor">1</td><td class="arc rule13" title="(13)-16">13</td><td class="arc bor">&nbsp;</td><td title="(13)-94" class="super2 bor" id="A166">166</td><td id="664" title="(5)-166" class="super1 bor seg">664</td><td id="220" title="(6)-166" class="super1 bor seg">220</td><td id="442" title="(9)-166" class="super1 bor seg">442</td></tr>
<tr><td class="arc">29</td><td class="arc bor">7</td><td class="arc rule6" title="(6)-22">6</td><td class="arc bor">&nbsp;</td><td title="(6)-130" class="super1 bor" id="A172">172</td><td id="688" title="(5)-172" class="super1 bor seg">688</td></tr>
<tr><td class="arc">30</td><td class="arc bor">3</td><td class="arc rule10" title="(10)-34">10</td><td class="arc super2" title="(9)-13">202</td><td title="(10)-202" class="super1 bor" id="A178">178</td><td id="712" title="(5)-178" class="super1 bor seg">712</td></tr>
<tr><td class="arc">31</td><td class="arc bor">7</td><td class="arc rule5" title="(5)-8">5</td><td class="arc bor">&nbsp;</td><td title="(5)-46" class="super1 bor" id="A184">184</td><td id="736" title="(5)-184" class="super1 bor seg">736</td><td id="244" title="(6)-184" class="super1 bor seg">244</td><td id="490" title="(9)-184" class="super2 bor seg">490</td></tr>
<tr><td class="arc">32</td><td class="arc bor">0</td><td class="arc rule25" title="(25)-61">25</td><td class="arc rule6" title="(6)-46">6</td><td title="(25)-364" class="super1 bor" id="A190">190</td><td id="760" title="(5)-190" class="super1 bor seg">760</td></tr>
<tr><td class="arc">33</td><td class="arc bor">8</td><td class="arc rule6" title="(6)-25">6</td><td class="arc bor">&nbsp;</td><td title="(6)-148" class="super1 bor" id="A196">196</td><td id="784" title="(5)-196" class="super1 bor seg">784</td></tr>
<tr><td class="arc">34</td><td class="arc bor">4</td><td class="arc rule9" title="(9)-13">9</td><td class="arc bor">&nbsp;</td><td title="(9)-76" class="super2 bor" id="A202">202</td><td id="808" title="(5)-202" class="super1 bor seg">808</td><td id="268" title="(6)-202" class="super1 bor seg">268</td><td id="538" title="(9)-202" class="super1 bor seg">538</td><td id="178" title="(10)-202" class="super1 bor seg">178</td><td id="358" title="(13)-202" class="super1 bor seg">358</td><td id="118" title="(14)-202" class="super1 bor seg">118</td><td id="238" title="(17)-202" class="super2 bor seg">238</td></tr>
<tr><td class="arc">35</td><td class="arc bor">8</td><td class="arc rule5" title="(5)-9">5</td><td class="arc bor">&nbsp;</td><td title="(5)-52" class="super1 bor" id="A208">208</td><td id="832" title="(5)-208" class="super1 bor seg">832</td></tr>
<tr><td class="arc">36</td><td class="arc bor">2</td><td class="arc rule14" title="(14)-61">14</td><td class="arc rule6" title="(6)-46">6</td><td title="(14)-364" class="super1 bor" id="A214">214</td><td id="856" title="(5)-214" class="super1 bor seg">856</td></tr>
<tr><td class="arc">37</td><td class="arc bor">9</td><td class="arc rule6" title="(6)-28">6</td><td class="arc bor">&nbsp;</td><td title="(6)-166" class="super1 bor" id="A220">220</td><td id="880" title="(5)-220" class="super1 bor seg">880</td><td id="292" title="(6)-220" class="super1 bor seg">292</td><td id="586" title="(9)-220" class="super1 bor seg">586</td></tr>
<tr><td class="arc">38</td><td class="arc bor">4</td><td class="arc rule10" title="(10)-43">10</td><td class="arc rule5" title="(5)-11">5</td><td title="(10)-256" class="super1 bor" id="A226">226</td><td id="904" title="(5)-226" class="super1 bor seg">904</td></tr>
<tr><td class="arc">39</td><td class="arc bor">9</td><td class="arc rule5" title="(5)-10">5</td><td class="arc bor">&nbsp;</td><td title="(5)-58" class="super1 bor" id="A232">232</td><td id="928" title="(5)-232" class="super1 bor seg">928</td></tr>
<tr><td class="arc">40</td><td class="arc bor">1</td><td class="arc rule17" title="(17)-34">17</td><td class="arc bor">&nbsp;</td><td title="(17)-202" class="super2 bor" id="A238">238</td><td id="952" title="(5)-238" class="super1 bor seg">952</td><td id="316" title="(6)-238" class="super1 bor seg">316</td><td id="634" title="(9)-238" class="super2 bor seg">634</td></tr>
<tr><td class="arc">41</td><td class="arc bor">10</td><td class="arc rule6" title="(6)-31">6</td><td class="arc bor">&nbsp;</td><td title="(6)-184" class="super1 bor" id="A244">244</td><td id="976" title="(5)-244" class="super1 bor seg">976</td></tr>
<tr><td class="arc">42</td><td class="arc bor">5</td><td class="arc rule9" title="(9)-16">9</td><td class="arc bor">&nbsp;</td><td title="(9)-94" class="super1 bor" id="A250">250</td><td id="1000" title="(5)-250" class="super1 bor seg">1000</td></tr>
<tr><td class="arc">43</td><td class="arc bor">10</td><td class="arc rule5" title="(5)-11">5</td><td class="arc bor">&nbsp;</td><td title="(5)-64" class="super1 bor" id="A256">256</td><td id="1024" title="(5)-256" class="super1 bor seg">1024</td><td id="340" title="(6)-256" class="super1 bor seg">340</td><td id="682" title="(9)-256" class="super1 bor seg">682</td><td id="226" title="(10)-256" class="super1 bor seg">226</td><td id="454" title="(13)-256" class="super2 bor seg">454</td></tr>
<tr><td class="arc">44</td><td class="arc bor">2</td><td class="arc rule13" title="(13)-25">13</td><td class="arc bor">&nbsp;</td><td title="(13)-148" class="super1 bor" id="A262">262</td><td id="1048" title="(5)-262" class="super1 bor seg">1048</td></tr>
<tr><td class="arc">45</td><td class="arc bor">11</td><td class="arc rule6" title="(6)-34">6</td><td class="arc bor">&nbsp;</td><td title="(6)-202" class="super1 bor" id="A268">268</td><td id="1072" title="(5)-268" class="super1 bor seg">1072</td></tr>
<tr><td class="arc">46</td><td class="arc bor">5</td><td class="arc rule10" title="(10)-52">10</td><td class="arc super2" title="(14)-88">310</td><td title="(10)-310" class="super2 bor" id="A274">274</td><td id="1096" title="(5)-274" class="super1 bor seg">1096</td><td id="364" title="(6)-274" class="super1 bor seg">364</td><td id="730" title="(9)-274" class="super1 bor seg">730</td></tr>
<tr><td class="arc">47</td><td class="arc bor">11</td><td class="arc rule5" title="(5)-12">5</td><td class="arc bor">&nbsp;</td><td title="(5)-70" class="super1 bor" id="A280">280</td><td id="1120" title="(5)-280" class="super1 bor seg">1120</td></tr>
<tr><td class="arc">48</td><td class="arc bor">0</td><td class="arc rule21" title="(21)-61">21</td><td class="arc rule6" title="(6)-46">6</td><td title="(21)-364" class="super1 bor" id="A286">286</td><td id="1144" title="(5)-286" class="super1 bor seg">1144</td></tr>
<tr><td class="arc">49</td><td class="arc bor">12</td><td class="arc rule6" title="(6)-37">6</td><td class="arc bor">&nbsp;</td><td title="(6)-220" class="super1 bor" id="A292">292</td><td id="1168" title="(5)-292" class="super1 bor seg">1168</td><td id="388" title="(6)-292" class="super1 bor seg">388</td><td id="778" title="(9)-292" class="super4 bor seg">778</td></tr>
<tr><td class="arc">50</td><td class="arc bor">6</td><td class="arc rule9" title="(9)-19">9</td><td class="arc bor">&nbsp;</td><td title="(9)-112" class="super1 bor" id="A298">298</td><td id="1192" title="(5)-298" class="super1 bor seg">1192</td></tr>
<tr><td class="arc">51</td><td class="arc bor">12</td><td class="arc rule5" title="(5)-13">5</td><td class="arc bor">&nbsp;</td><td title="(5)-76" class="super1 bor" id="A304">304</td><td id="1216" title="(5)-304" class="super1 bor seg">1216</td></tr>
<tr><td class="arc">52</td><td class="arc bor">3</td><td class="arc rule14" title="(14)-88">14</td><td class="arc super2" title="(18)-223">526</td><td title="(14)-526" class="super2 bor" id="A310">310</td><td id="1240" title="(5)-310" class="super1 bor seg">1240</td><td id="412" title="(6)-310" class="super1 bor seg">412</td><td id="826" title="(9)-310" class="super1 bor seg">826</td><td id="274" title="(10)-310" class="super2 bor seg">274</td><td id="550" title="(13)-310" class="super1 bor seg">550</td></tr>
<tr><td class="arc">53</td><td class="arc bor">13</td><td class="arc rule6" title="(6)-40">6</td><td class="arc bor">&nbsp;</td><td title="(6)-238" class="super1 bor" id="A316">316</td><td id="1264" title="(5)-316" class="super1 bor seg">1264</td></tr>
<tr><td class="arc">54</td><td class="arc bor">6</td><td class="arc rule10" title="(10)-61">10</td><td class="arc rule6" title="(6)-46">6</td><td title="(10)-364" class="super1 bor" id="A322">322</td><td id="1288" title="(5)-322" class="super1 bor seg">1288</td></tr>
<tr><td class="arc">55</td><td class="arc bor">13</td><td class="arc rule5" title="(5)-14">5</td><td class="arc bor">&nbsp;</td><td title="(5)-82" class="super1 bor" id="A328">328</td><td id="1312" title="(5)-328" class="super1 bor seg">1312</td><td id="436" title="(6)-328" class="super1 bor seg">436</td><td id="874" title="(9)-328" class="super1 bor seg">874</td></tr>
<tr><td class="arc">56</td><td class="arc bor">1</td><td class="arc rule18" title="(18)-142">18</td><td class="arc super2" title="(10)-160">850</td><td title="(18)-850" class="super1 bor" id="A334">334</td><td id="1336" title="(5)-334" class="super1 bor seg">1336</td></tr>
<tr><td class="arc">57</td><td class="arc bor">14</td><td class="arc rule6" title="(6)-43">6</td><td class="arc bor">&nbsp;</td><td title="(6)-256" class="super1 bor" id="A340">340</td><td id="1360" title="(5)-340" class="super1 bor seg">1360</td></tr>
<tr><td class="arc">58</td><td class="arc bor">7</td><td class="arc rule9" title="(9)-22">9</td><td class="arc bor">&nbsp;</td><td title="(9)-130" class="super3 bor" id="A346">346</td><td id="1384" title="(5)-346" class="super1 bor seg">1384</td><td id="460" title="(6)-346" class="super1 bor seg">460</td><td id="922" title="(9)-346" class="super2 bor seg">922</td></tr>
<tr><td class="arc">59</td><td class="arc bor">14</td><td class="arc rule5" title="(5)-15">5</td><td class="arc bor">&nbsp;</td><td title="(5)-88" class="super1 bor" id="A352">352</td><td id="1408" title="(5)-352" class="super1 bor seg">1408</td></tr>
<tr><td class="arc">60</td><td class="arc bor">3</td><td class="arc rule13" title="(13)-34">13</td><td class="arc bor">&nbsp;</td><td title="(13)-202" class="super1 bor" id="A358">358</td><td id="1432" title="(5)-358" class="super1 bor seg">1432</td></tr>
<tr><td class="arc">61</td><td class="arc bor">15</td><td class="arc rule6" title="(6)-46">6</td><td class="arc bor">&nbsp;</td><td title="(6)-274" class="super1 bor" id="A364">364</td><td id="1456" title="(5)-364" class="super1 bor seg">1456</td><td id="484" title="(6)-364" class="super1 bor seg">484</td><td id="970" title="(9)-364" class="super1 bor seg">970</td><td id="322" title="(10)-364" class="super1 bor seg">322</td><td id="646" title="(13)-364" class="super1 bor seg">646</td><td id="214" title="(14)-364" class="super1 bor seg">214</td><td id="430" title="(17)-364" class="super1 bor seg">430</td><td id="142" title="(18)-364" class="super1 bor seg">142</td><td id="286" title="(21)-364" class="super1 bor seg">286</td><td id="94" title="(22)-364" class="super2 bor seg">94</td><td id="190" title="(25)-364" class="super1 bor seg">190</td></tr>
</table>
<!-- End of directory -->
