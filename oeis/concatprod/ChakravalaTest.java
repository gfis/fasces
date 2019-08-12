/*  ChakravalaTest
    @(#) $Id$
    This method is used to find the (smallest) integer solution to the equation
    x^2 - n*y^2 = 1, where n is a positive non-square integer.
    2019-07-28, Georg Fischer
    
    Adapted from <https://code.sololearn.com/cC1rcZ8b2pGQ/#java>
    Cf. also     <https://code.sololearn.com/cc5UmOuxsTGs/#java> (enhanced)
    Feedback and suggestions in any form are welcome at furia.dhaval@gmail.com
*/

import java.lang.Math;

public class ChakravalaTest {
    public static void main(String[] args) {
        int n = 61;
        if (args.length > 0) {
            try {
                n = Integer.parseInt(args[0]);
            } catch (Exception exc) {
            }
        }
        long sqrtn = (int) Math.pow(n, 0.5);
        System.out.println("Solve x^2 - " + n + " * y^2 = 1");
        long pn = 0;
        long po = sqrtn;
        long qo = 1;
        long mo = po * po - n;
        if (mo == 0) {
            System.out.println(n + " is square => trivial solution 1^2 - " + n + " * 0^2 = 1");
            return;
        }
        long xo = po;
        int i = 1;
        while (mo != 1) {
            int j = 1;
            long abs_mo = Math.abs(mo);
            while(j >  sqrtn || j <= sqrtn - abs_mo || (j + xo) % abs_mo != 0) {
                j++;
            } // while j
            xo = j;
            pn = (po * j + n * qo) / abs_mo;
            qo = (po     + j * qo) / abs_mo;
            mo = (j * j - n) / mo;
            po = pn;
            System.out.println("p = " + po + ", q = " + qo + ", m = " + mo + ", x = " + xo);
        } // while i
        System.out.println("Solution: " + po + "^2 - " + n + " * " + qo + "^2 = 1");
    } // main
} // ChakravalaTest
