import java.util.HashMap;

/*
 *  Generate OEIS Sequence A131393 && its companions
 *  as defined by Clark Kimberling
 *  @(#) Id
 *  2019-07-25: prepared for Java
 *  2018-02-24, Georg Fischer
 * ------------------------------------------------------
 *  C.f. list of sequences in https://oeis.org/search?q=A257705
 *  usage:
 *    java NegPos rule s noeis noterms op a1 d1
 *        rule  = 1|2|3|4
 *        sub   = 0|1
 *        noeis = "131388|131389|131393|131394..." (without "A")
 *        noterms = length of sequence to be generated
 *        op    = ak, dk, cp, cn, dp(positive d(K)), dn(negative d(k)), in(inverse)
 *        a1    = starting value for a(1)
 *        d1    = starting value for d(1)
 * ------------------------------------------------------
 *  Formula (Rule 1):
 *  a(k) = a(k-1) + d(k)
 *  d(k) = max({s, s-1 ... 1-a(k-1)}) such that
 *    d(k) not in d(1..k-1) && //   a(k) not in a(1..k-1)
 *  if no such d(k) exists, then
 *  d(k) = min({1,2, ... a(k-1)}) such that
 *    d(k) not in d(1..k-1) && //   a(k) not in a(1..k-1)
 *  s = -1 for A131388, && s = min(-1, d(k-1)) for A131393
 * --------------------------------------------------------
 */

public class NegPos {
    protected int mRule;
    protected int mSub;
    protected int mVariant;
    protected int mK;
    protected int mAk;
    protected int mDk;
    protected int mAk_1;
    protected int mDk_1;
    protected int mA1;
    protected int mD1;
    protected HashMap<Integer, Integer> mASet;
    protected HashMap<Integer, Integer> mDSet;

    /**
     * No-args constructor
     */
    public NegPos() {
        this(1, 1, "ak", 1, 0);
    } // no-args constructor

    /**
     * Constructor with parameters.
     * @param rule major rule number according to Clark Kimberling
     * @param sub minor rule number
     * @param op operation: ak or dk
     * @param a1 start value of ak
     * @param d1 start value pf dk
     */
    public NegPos(int rule, int sub, String op, int a1, int d1) {
        mRule    = rule;
        mSub     = sub;
        mA1      = a1;
        mD1      = d1;
        mASet    = new HashMap<Integer, Integer>(2048);
        mDSet    = new HashMap<Integer, Integer>(2048);
        if (false) {
        } else if (op.equals("ak")) {
            mVariant = 1;
        } else if (op.equals("dk")) {
            mVariant = 2;
        } else {
            System.err.println("variant \"" + op + "\" not implemented");
            mVariant = 0;
        }       
        mK    = 1;
        mAk   = mA1;
        mAk_1 = mAk;
        mDk   = mD1;
        mDk_1 = mDk;
        mASet.put(mAk, mK);
        mDSet.put(mDk, mK); // dk is h
    } // no-args constructor

    /**
     * Compute the next term of the sequence
     */
    protected int next() {
        int result = 0;
        switch (mVariant) {
            case 1: // ak
                result = mAk;
                break;
            case 2: // dk
                result = mDk;
                break;
            default:
                result = 0;
        } // switch mVariant
        
        mK ++;
        { // implemented variants
            boolean busy = true;
            if (false) {
            } else if (mRule == 1 || mRule == 2) { // for A131388, A257705 et al.
                mDk = -1; // start downwards
                if (mRule == 2 && mDk_1 < 0) { // for A131393 et al.
                    mDk = mDk_1 - 1;
                }
                while (busy && mDk > mSub - mAk_1) { // downwards
                    mAk = mAk_1 + mDk;
                    if (mASet.get(mAk) == null && mDSet.get(mDk) == null && mAk > 0) {
                        busy = false;
                        mASet.put(mAk, mK);
                        mDSet.put(mDk, mK);
                    } else {
                        mDk --;
                    }
                } // while downwards
                if (busy) {
                    mDk = +1; // start upwards
                }
                while (busy                   ) { // upwards
                    mAk = mAk_1 + mDk;
                    if (mASet.get(mAk) == null && mDSet.get(mDk) == null) {
                        busy = false;
                        mASet.put(mAk, mK);
                        mDSet.put(mDk, mK);
                    } else {
                        mDk ++;
                    }
                } // while upwards
            } else if (mRule == 3) { // for A257905, 908
                mDk = mSub - mAk_1 + 1; // start upwards in negative
                while (busy && mDk < 0) {
                    mAk = mAk_1 + mDk;
                    if (mASet.get(mAk) == null && mDSet.get(mDk) == null && mAk > 0) {
                        busy = false;
                        mASet.put(mAk, mK);
                        mDSet.put(mDk, mK);
                    } else {
                        mDk ++;
                    }
                } // while negative
                if (busy) {
                    mDk = +1; // start upwards
                }
                while (busy                     ) { // upwards
                    mAk = mAk_1 + mDk;
                    if (mASet.get(mAk_1 - mDk) == null && mDSet.get(mDk) == null) {
                        busy = false;
                        mASet.put(mAk, mK);
                        mDSet.put(mDk, mK);
                    } else {
                        mDk ++;
                    }
                } // while upwards
            } else if (mRule == 4) { // "Algorithm" for A257883 et al.
                mDk = mSub - mAk + 1;
                while (busy                      ) { // upwards
                    mAk = mAk_1 + mDk;
                    if (mASet.get(mAk) == null && mDSet.get(mDk) == null && mAk > 0) {
                        busy = false;
                        mASet.put(mAk, mK);
                        mDSet.put(mDk, mK);
                    } else {
                        mDk ++;
                    }
                } // while upwards
            }
            mAk_1 = mAk;
            mDk_1 = mDk;
            mK ++; // iterate
        }
/*
        //--------
        if (! op.matches("ak|dk")) { // output of operations other than "ak", "dk"
            int ainv[4095] = sort(map { _ = sSystem.out.print(f("%06d %d", _, mASet.get(_))); _ } keys(%mASet));
            int dpos[4095] = sort(map { _ = sSystem.out.print(f("%06d %d", mDSet.get(_), _)); _ } keys(%mDSet));
            if (false) {
            } else if (op.matches("in")) {
                mK = 0;
                busy = 1;
                while (busy && mK < scalar(ainv[4095])) {
                    int (j, aj) = split(/ /, ainv[mK]);
                    j += 0; // removes the leading zeroes
                    busy = (j == mK + 1 ? 1 : 0);
                    if (busy) {
                        System.out.print("j aj\n");
                    }
                    mK ++;
                } // while mK
            } else if (op.matches("cp|dp|c0|d0")) {
                int mK = 0;
                System.out.print(join("", map { int (j, dj) = split(/\s+/));
                        j = (op.matches("\Ac")) ? j - 1 : j + 0;
                        _ = "";
                        if (dj > ((op.matches("0")) ? -1 : 0)) {
                            mK ++;
                            _ = "mK j\n";
                        }
                        _ } dpos[4095]) . "\n";
            } else if (op.matches("cn|dn")) {
                int mK = 0;
                System.out.print(join("", map { int (j, dj) = split(/\s+/));
                        j = (op.matches("\Ac")) ? j - 1 : j + 0;
                        _ = "";
                        if (dj < 0) {
                            mK ++;
                            _ = "mK j\n";
                        }
                        _ } dpos[4095]) . "\n";
            }
        } // other oper
*/
        return result;
    } // next

    //=====================================
    /*  Test method - outputs a b-file
     *  @param args command line arguments: rule sub noeis noterms op a1 d1
     */
    public static void main(String[] args) {
        int oeisNum = 131388;
        int noTerms = 1000;
        NegPos seq = null;
        if (args.length == 0) {
            seq = new NegPos();
        } else {
            try {
                int iarg = 0;
                seq = new NegPos
                        ( Integer.parseInt(args[iarg    ]) // rule
                        , Integer.parseInt(args[iarg + 1]) // sub
                        ,                  args[iarg + 4]  // op
                        , Integer.parseInt(args[iarg + 5]) // a1
                        , Integer.parseInt(args[iarg + 6]) // d1
                        );
                oeisNum = Integer.parseInt(args[iarg + 2]); // noeis
                noTerms = Integer.parseInt(args[iarg + 3]); // noTerms
            } catch (Exception exc) {
                System.err.println(exc.getMessage());
            }
        }
        seq.mNoTerms = noTerms;
        System.out.print("# A" + oeisNum + ": Table of n, a(n) for n = 1.." + noTerms + "\n");
        int n = 1;
        while (n < noTerms) {
            int result = seq.next();
            System.out.println(n + " " + result);
            n ++;
        } // while n
   } // main
   
} // class NegPos

