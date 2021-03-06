/*!perl */

/* Fill triangles with interlaced rows */
/* defined by Clark Kimberling */
/* @(#) Id */
/* 2018-03-16, Georg Fischer: 8th attempt, copied from connect.c */
/* time measurement taken from https://stackoverflow.com/questions/13156031/measuring-time-in-c */
/*------------------------------------------------------ */
/* usage:                                                */
/*   time ./armleg [max_row [debug]]                     */
/* Only half of the triangles is computed.               */
/* The numbers in the output must be doubled.            */
/*------------------------------------------------------ */
#include <stdio.h>
#include <stdlib.h>
#include <sys/time.h>

#define PRIVATE static
#define PUBLIC  extern
#define FAIL 0
#define SUCC 1
#define MAX_TRI 128

PRIVATE int max_row;
PRIVATE int last_row;
PRIVATE int rowno;
PRIVATE int cind;
PRIVATE int size; /* number of elements in the triangle */
PRIVATE int debug; /* 0 = none, 1 = some, 2 = more */
PRIVATE int  filled = 0;
PRIVATE long long count  = 0l; /* number of triangles which fulfill the interlacing condition */
PRIVATE long long prevc  = 0l; /* previous value of 'count' */
PRIVATE int  cnt = 0;
PRIVATE long missed = 0l; /* number of triangles which were constructed, but failed the final test */
PRIVATE long investigated = 0l; /* number of empty positions which were tried */

PRIVATE int srow[MAX_TRI]; /* start index of a row */
PRIVATE int erow[MAX_TRI]; /* end   index of a row + 1 */
PRIVATE int nrow[MAX_TRI]; /* row number for a position in the triangle */
PRIVATE int trel[MAX_TRI]; /* element which fills the position in the triangle, or empty */
PRIVATE int elpo[MAX_TRI]; /* position in the triangle where an element was allocated, or nonex */
PRIVATE int nonex; /* indicates that a position does not exist */
PRIVATE int empty; /* indicates that a position in the triangle is not filled by an element */
/* positions of the neighbours of the focus element */
PRIVATE int polarm[MAX_TRI];
PRIVATE int porarm[MAX_TRI];
PRIVATE int polsib[MAX_TRI];
PRIVATE int porsib[MAX_TRI];
PRIVATE int polleg[MAX_TRI];
PRIVATE int porleg[MAX_TRI];
/* */
/* Naming of the neighbours of element focus: */
/*                         */
/*       larm   rarm       */
/*      /   \   /   \      */
/*   lsib   FOCUS   rsib   */
/*      \   /   \   /      */
/*       lleg   rleg       */
/*                         */
/*-------------------------*/
PRIVATE void test_lset(int elem);
PRIVATE void test_rset(int elem);

PRIVATE int check_all() {
    /* check all positions */
    int result = SUCC;
    int focus = 0;
    int elem, larm, rarm;
    while (focus < srow[last_row]) {
        elem = trel[focus];
        larm = trel[polleg[focus]];
        rarm = trel[porleg[focus]];
        if (! (larm < elem && elem < rarm ||
               larm > elem && elem > rarm   )) {
            result = FAIL;
        }
        focus ++;
    } /* while focus */
    return result;
} /* check_all */

PRIVATE void evaluate(int elem, int fpos, int arm) {
    int epos; /* where to allocate elem */
    int lsib, rsib, leg1, leg2;
    switch (arm) {
        default:
        case 0: /* in last row */
            epos = fpos;
            break;
        case -1: /* take left  arm */
            epos = polarm[fpos];
            break;
        case +1: /* take right arm */
            epos = porarm[fpos];
            break;
    } /* switch arm */
    int result = SUCC;
    if (trel[epos] == empty) { /* and therefore != nonex */
        switch (arm) {
            default:
            case  0:
                lsib = trel[polsib[epos]];
                if (lsib < size) { /* != nonex and != empty */
                    if (abs(lsib - elem) <= 1) {
                        result = FAIL;
                    }
                }
                if (result == SUCC) {
                    rsib = trel[porsib[epos]];
                    if (rsib < size) { /* != nonex and != empty */
                        if (abs(rsib - elem) <= 1) {
                            result = FAIL;
                        }
                    } /* rsib exists */
                }
                break;
            case -1: /* leg2 / elem \ leg1 */
                leg1 = trel[fpos]; /* != nonex, were we came from, == lelem */
                leg2 = trel[polleg[epos]];
                if (leg2 < size && ! (
                    leg1 < elem && elem < leg2 ||
                    leg1 > elem && elem > leg2    )) { result = FAIL; }
                break;
            case +1: /* leg1 / elem \ leg2 */
                leg1 = trel[fpos]; /* != nonex, were we came from, == lelem */
                leg2 = trel[porleg[epos]];
                if (leg2 < size && ! (
                    leg1 < elem && elem < leg2 ||
                    leg1 > elem && elem > leg2    )) { result = FAIL; }
                break;
        } /* switch arm */
        if (result == SUCC) { /* is possible */
            /* allocate(elem, epos); */
#undef check
#ifdef check
            investigated ++;
#endif
            filled ++;
            trel[epos] = elem;
            elpo[elem] = epos;
            if (filled < size) {
                int conj = size - 1 - elem;
                if (elem < conj) {
                    test_rset(conj    );
                } else { /* elem >= conj */
                    test_lset(conj + 1);
                } /* elem >= conj */
            } else { /* all elements exhausted, check, count and maybe print */
                /* check whole triangle again */
#ifdef check
                result = check_all();
                if (result == SUCC) {
#endif
                    count ++;
#ifdef check
                    if (debug >= 1) {
                        int ind = 0;
                        while (ind < size) {
                            printf("%d ", trel[ind]);
                            ind ++;
                        }
                        if (debug >= 2) {
                            printf(" # %ld new, %ld total\n", count - prevc, count);
                            prevc = count;
                        } else {
                            printf("\n");
                        }
                    }
#endif
#ifdef check
                } else { /* constructed, but still not possible */
                    missed ++;
                }
#endif
            } /* all exhausted */
            /* remove(elem, epos); */
            filled --;
            trel[epos] = empty;
            elpo[elem] = nonex;
        } /* was possible */
    } /* was empty */
} /* evaluate */

PRIVATE void test_rset(int elem) {
    int fpos, relem;
    for (relem = size; relem > elem; relem --) { /* try all arms of the rset */
        fpos = elpo[relem]; /* must be allocated (by construction) */
        evaluate(elem, fpos, -1); /* look at left  arm */
        evaluate(elem, fpos, +1); /* look at right arm */
    } /* while relem */
    for (fpos = erow[last_row] - 1; fpos >= srow[last_row]; fpos --) { /* look at some empty in the last row */
        evaluate(elem, fpos,  0);
    } /* while last */
} /* test_rset */

PRIVATE void test_lset(int elem) {
    int fpos, lelem;
    for (lelem = 0; lelem < elem  ; lelem ++) { /* try all arms of the lset */
        fpos = elpo[lelem]; /* must be allocated (by construction) */
        evaluate(elem, fpos, -1); /* look at left  arm */
        evaluate(elem, fpos, +1); /* look at right arm */
    } /* while lelem */
    for (fpos = srow[last_row]    ; fpos < erow[last_row]; fpos ++) { /* look at some empty in the last row */
        evaluate(elem, fpos,  0);
    } /* while last */
} /* test_lset */

PRIVATE void test_lset0() {
    int elem = 0;
    int fpos, lelem;
    for (fpos = srow[last_row]    ; fpos < erow[last_row]; fpos ++) { /* look at some empty in the last row */
        evaluate(elem, fpos,  0);
    } /* while last */
} /* test_lset */

PUBLIC int main(int argc, char *argv[]) {
    cind = 0; /* current index */
    int iarg = 1;
    prevc = 0l;
    count = 0l; 
    sscanf(argv[iarg ++], "%d", & max_row); /* rowno runs from 0 to max_row - 1 */
    last_row = max_row - 1; /* last row, lowest row */
    if (argc >= 3) {
        sscanf(argv[iarg ++], "%d", & debug);
    }
    size = (max_row * (max_row + 1)) / 2; /* number of elements in the triangle */
    nonex = size;     /* indicates that a position does not exist */
    empty = size + 1; /* indicates that a position in the triangle is not filled by an element */
    trel[nonex] = nonex;
    trel[empty] = nonex;
    rowno = 0; /* current row */
    int nind;
    while (rowno <= last_row) { /* all rows except for the last */
        nind = cind + rowno + 1; /* index of the start of the next row */
        srow[rowno] = cind;
        erow[rowno] = nind;
        while (cind < nind) {
            nrow  [cind] = rowno;
            trel  [cind] = empty;
            elpo  [cind] = nonex;
            polarm[cind] = empty;
            porarm[cind] = empty;
            polsib[cind] = empty;
            porsib[cind] = empty;
            if (cind > srow[rowno]    ) { /* does not apply for row 0 */
                polsib[cind] = cind - 1;
                polarm[cind] = srow[rowno - 1] + polsib[cind] - srow[rowno];
            } else { /* no arm and sibling */
                polsib[cind] = nonex;
                polarm[cind] = nonex;
            }
            if (cind < erow[rowno] - 1) { /* does not apply for row 0 */
                porsib[cind] = cind + 1;
                porarm[cind] = srow[rowno - 1] + cind          - srow[rowno];
            } else { /* no arm and sibling */
                porsib[cind] = nonex;
                porarm[cind] = nonex;
            }
            if (rowno < last_row) { /* legs exist */
                polleg[cind] = erow[rowno] + cind - srow[rowno];
                porleg[cind] = polleg[cind] + 1;
            } else { /* no legs for last row */
                polleg[cind] = nonex;
                porleg[cind] = nonex;
            } /* no legs for last row */
            cind ++;
        } /* while cind */
        rowno ++;
    } /* while rowno ++ */

    printf("# arrange %d numbers in a triangle with %d rows\n", size, rowno);
    long start, end;
    struct timeval timecheck;

    gettimeofday(&timecheck, NULL);
    start = (long) timecheck.tv_sec * 1000 + (long) timecheck.tv_usec / 1000;
    int ele0 = 0;
    int pos0, pos9;
    for (pos0 = srow[last_row]; pos0 < erow[last_row]; pos0 ++) {
        filled ++;
        trel[pos0] = ele0;
        elpo[ele0] = pos0;
        int ele9 = size - 1;
#undef half
#ifdef half
        for (pos9 = pos0 + 1; pos9 < erow[last_row]; pos9 ++) {
#else
        for (pos9 = srow[last_row]; pos9 < erow[last_row]; pos9 ++) {
#endif
            if (pos0 != pos9) {
                filled ++;
                trel[pos9] = ele9;
                elpo[ele9] = pos9;
                test_lset(1);
                int ind = srow[last_row];
                while (ind < size) {
                    printf("%d ", trel[ind]);
                    ind ++;
                }
                printf("# %lld %lld\n", count - prevc, count);
                prevc = count;
                filled --;
                trel[pos9] = empty;
                elpo[ele9] = nonex;
            } /* if pos0 != pos9 */
        } /* for pos9 */
        filled --;
        trel[pos0] = empty;
        elpo[ele0] = nonex;
    } /* for pos0 */
    /* replacement for the loop above
    test_lset(0); 
    */
    gettimeofday(&timecheck, NULL);
    end = (long) timecheck.tv_sec * 1000 + (long) timecheck.tv_usec / 1000;
    printf("# %lld triangles found in %ld ms\n", count, end - start);
#ifdef check
    printf("# %ld investigated", investigated);
    printf("%ld triangles failed the final test", missed);
    printf("\n");
#endif
    return 0;
/*
C:\Users\gfis\work\gits\fasces\oeis\interlace>armleg 4
# arrange 10 numbers in a triangle with 4 rows
0 9 11 11 # 160 160
0 11 9 11 # 110 270
0 11 11 9 # 68 338
9 0 11 11 # 160 498
11 0 9 11 # 264 762
11 0 11 9 # 110 872
9 11 0 11 # 110 982
11 9 0 11 # 264 1246
11 11 0 9 # 160 1406
9 11 11 0 # 68 1474
11 9 11 0 # 110 1584
11 11 9 0 # 160 1744
# 1744 triangles found in 7 ms

C:\Users\gfis\work\gits\fasces\oeis\interlace>armleg 5
# arrange 15 numbers in a triangle with 5 rows
0 14 16 16 16 # 90594 90594
0 16 14 16 16 # 76886 167480
0 16 16 14 16 # 58672 226152
0 16 16 16 14 # 37368 263520
14 0 16 16 16 # 90594 354114
16 0 14 16 16 # 197886 552000
16 0 16 14 16 # 115840 667840
16 0 16 16 14 # 58672 726512
14 16 0 16 16 # 76886 803398
16 14 0 16 16 # 197886 1001284
16 16 0 14 16 # 197886 1199170
16 16 0 16 14 # 76886 1276056
14 16 16 0 16 # 58672 1334728
16 14 16 0 16 # 115840 1450568
16 16 14 0 16 # 197886 1648454
16 16 16 0 14 # 90594 1739048
14 16 16 16 0 # 37368 1776416
16 14 16 16 0 # 58672 1835088
16 16 14 16 0 # 76886 1911974
16 16 16 14 0 # 90594 2002568
# 2002568 triangles found in 1549 ms

C:\Users\gfis\work\gits\fasces\oeis\interlace>armleg 6
# arrange 21 numbers in a triangle with 6 rows
0 20 22 22 22 22 # 1003632544 1003632544
0 22 20 22 22 22 # 980045344 1983677888
0 22 22 20 22 22 # 859876748 2843554636
0 22 22 22 20 22 # 716124908 3559679544
0 22 22 22 22 20 # 400001016 3959680560
20 0 22 22 22 22 # 1003632544 4963313104
22 0 20 22 22 22 # 2580078688 7543391792
22 0 22 20 22 22 # 1919079636 9462471428
22 0 22 22 20 22 # 1121553520 10584024948
22 0 22 22 22 20 # 716124908 11300149856
20 22 0 22 22 22 # 980045344 12280195200
22 20 0 22 22 22 # 2580078688 14860273888
22 22 0 20 22 22 # 3492291104 18352564992
22 22 0 22 20 22 # 1919079636 20271644628
22 22 0 22 22 20 # 859876748 21131521376
20 22 22 0 22 22 # 859876748 21991398124
22 20 22 0 22 22 # 1919079636 23910477760
22 22 20 0 22 22 # 3492291104 27402768864
22 22 22 0 20 22 # 2580078688 29982847552
22 22 22 0 22 20 # 980045344 30962892896
20 22 22 22 0 22 # 716124908 31679017804
22 20 22 22 0 22 # 1121553520 32800571324
22 22 20 22 0 22 # 1919079636 34719650960
22 22 22 20 0 22 # 2580078688 37299729648
22 22 22 22 0 20 # 1003632544 38303362192
20 22 22 22 22 0 # 400001016 38703363208
22 20 22 22 22 0 # 716124908 39419488116
22 22 20 22 22 0 # 859876748 40279364864
22 22 22 20 22 0 # 980045344 41259410208
22 22 22 22 20 0 # 1003632544 42263042752
# 42263042752 triangles found in 85809211 ms

C:\Users\gfis\work\gits\fasces\oeis\interlace>
} /* main */
