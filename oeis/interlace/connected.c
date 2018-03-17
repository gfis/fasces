/*!perl */

/* Fill triangles with interlaced rows */
/* defined by Clark Kimberling */
/* @(#) Id */
/* 2018-03-15, Georg Fischer: 7th attempt, generated from connected.pl 
for 6: > 25.000.000.000
*/
/*------------------------------------------------------ */
/* usage: */
/*    ./connected [max_row [debug]] */
/*-------------------------------------------------------- */
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
PRIVATE long count  = 0l; /* number of triangles which fulfill the interlacing condition */
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
/* */
/*       larm   rarm */
/*      /   \   /   \ */
/*   lsib   FOCUS   rsib */
/*      \   /   \   / */
/*       lleg   rleg */
/* */
/*----------------------- */
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
        if (larm < elem && elem < rarm ||
            larm > elem && elem > rarm) {
                /* ok */
        } else {
            result = FAIL;
        }
        focus ++;
    } /* while focus */
    return result;
} /* check_all */

PRIVATE void evaluate(int elem, int fpos, int arm) {
    int epos; /* where to allocate elem */
    int lsib, rsib, leg1, leg2, conj;
    if (arm == 0) { /* in last row */
        epos = fpos;
    } else if (arm < 0) { /* take left arm */
        epos = polarm[fpos];
    } else { 
        epos = porarm[fpos];
    }
    int result = SUCC;
    if (trel[epos] == empty) { /* and therefore != nonex */
        if (arm == 0) { /* last row */
            lsib = trel[polsib[epos]];
            if (lsib < size) { /* != nonex and != empty */
                if (abs(lsib - elem) <= 1) {
                    result = FAIL;
                }
                /* int larm = trel[polarm[epos]]; */
            }
            if (result == SUCC) {
                rsib = trel[porsib[epos]];
                if (rsib < size) { /* != nonex and != empty */
                    if (abs(rsib - elem) <= 1) {
                        result = FAIL;
                    }
                    /* int rarm = trel[porarm[epos]]; */
                } /* rsib exists */
            }
        } else { /* not last row */
            leg1 = trel[fpos]; /* != nonex, were we came from, == lelem */
            leg2 = trel[arm < 0 ? polleg[epos] : porleg[epos]];
            if (leg2 < size) { /* != nonex and != empty */
                if (leg1 < elem && elem < leg2 ||
                    leg1 > elem && elem > leg2) {
                    /* ok */
                } else {
                    result = FAIL;
                }
            }
        } /* not last */
        if (result == SUCC) { /* is possible */
            /* allocate(elem, epos); */
            investigated ++;
            filled ++;
            trel[epos] = elem;
            elpo[elem] = epos;
            if (filled < size) {
                conj = size - 1 - elem;
                if (elem < conj) {
                    test_rset(conj    );
                } else {
                    test_lset(conj + 1);
                }
            } else { /* all elements exhausted, check, count and maybe print */
                /* check whole triangle again */
                result = check_all();
                /*
                */
                if (result == SUCC) {
                    if (debug >= 1) {
                        int ind = 0;
                        while (ind < size) {
                            printf("%d ", trel[ind]);
                            ind ++;
                        } 
                        printf("\n");
                    }
                    count ++;
                } else { /* constructed, but still not possible */
                    missed ++;
                }
            } /* all exhausted */
            /* remove(elem, epos); */
            filled --;
            trel[epos] = empty;
            elpo[elem] = nonex;
        } /* was possible */
    } /* was empty */
} /* evaluate */

PRIVATE void test_lset(int elem) {
    int result = FAIL;
    int fpos;
    int lelem = elem - 1; /* element of lset */
    while (lelem >= 0) { /* try all arms of the lset */
        fpos = elpo[lelem]; /* must be allocated (by construction) */
        evaluate(elem, fpos, -1); /* look at left  arm */
        evaluate(elem, fpos, +1); /* look at right arm */
        lelem --;
    } /* while lelem */
    fpos = srow[last_row];
    while (fpos < erow[last_row]) { /* look at some empty in the last row */
        evaluate(elem, fpos,  0);
        fpos ++;
    } /* while last */
} /* test_lset */

PRIVATE void test_rset(int elem) {
    int result = FAIL;
    int fpos;
    int relem = elem + 1; /* element of rset */
    while (relem < size) { /* try all arms of the rset */
        fpos = elpo[relem]; /* must be allocated (by construction) */
        evaluate(elem, fpos, -1); /* look at left  arm */
        evaluate(elem, fpos, +1); /* look at right arm */
        relem ++;
    } /* while relem */
    fpos = erow[last_row] - 1;
    while (fpos >= srow[last_row]) { /* look at some empty in the last row */
        evaluate(elem, fpos,  0);
        fpos --;
    } /* while last */
} /* test_rset */

PUBLIC int main(int argc, char *argv[]) {
    cind = 0; /* current index */
    int iarg = 1;
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

    test_lset(0); /* start with elem = 0 in lset */

    gettimeofday(&timecheck, NULL);
    end = (long) timecheck.tv_sec * 1000 + (long) timecheck.tv_usec / 1000;
    printf("# %ld triangles found in %ld ms\n", count, end - start);
    printf("# %ld investigated, %ld triangles failed the final test\n", investigated, missed);
    return 0;
/*
282963869598 investigated, 42262921216 found
282964279740 investigated, 42262986752 found
42263042752 triangles found in 0.000 s
282964613990 investigated, 0 triangles failed the

real    2013m20.191s
user    1995m30.233s
sys     2m8.265s

gfis@sirus /cygdrive/c/Users/gfis/work/gits/fasces
*/
} /* main */
