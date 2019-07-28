/*  ChakravalaTest
    @(#) $Id$
    This method is used to the smallest integer solution to the equation
    x^2 - n*y^2 = 1, where n is a positive non-square integer.
    2019-07-28, Georg Fischer
    
    Adapted from https://code.sololearn.com/cc5UmOuxsTGs/#java
    or           https://code.sololearn.com/cC1rcZ8b2pGQ/#java
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
        long xo = po;
        int i = 1;
        while (mo != 1) {
            int j = 1;
            long ami = Math.abs(mo);
            while(     j >  sqrtn 
                    || j <= sqrtn - ami
                    || (j + xo) % (ami) != 0) {
                j++;
            } // while j
            xo = j;
            pn = (po * j + n * qo) / ami;
            qo = (po +     j * qo) / ami;
            mo = (j * j - n) / mo;
            po = pn;
            System.out.println("p = " + po + ", q = " + qo + ", m = " + mo + ", x = " + xo);
        } // while i
        System.out.println("Solution: " + po + "^2 - " + n + " * " + qo + "^2 = 1");
    }
}
