# fasces
## Generation and visualization of FASS curves

FASS curves are space-**F**illing, self-**A**voiding, **S**imple and self-**S**imilar curves.
Such curves were described by Peano and Hilbert. 
They may be two-, three- or multidimensional.

The initial motivation for this project was [OEIS sequence A220952](https://oeis.org/search?q=A220952) which was defined by Donald Knuth with the following comment:
> *As soon as a solution is published, I'll provide lots more info; the sequence is so fascinating, it has caused me to take three days off from writing The Art of Computer Programming, but I plan to use it in Chapter 8 some day.*

Further information on this project can be found under
http://www.teherba.org/index.php/OEIS/FASS_curves. 

Please write to dr point georg point fischer at gmail.com for any comments
or if you want to participate.

# OEIS
This subfolder contains various scripts for  [OEIS](https://oeis.org/) housekeeping projects and for individual sequences, among them
* broken link detection,
* coincidence search,
* mail list crossreference.

The scripts often generate colored HTML, SVG or three.js views, and htey are called by Unix makefiles.
