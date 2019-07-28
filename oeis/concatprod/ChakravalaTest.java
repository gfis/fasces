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
        long sqrtn = Math.pow(n, 0.5);
        if (args.length > 0) {
            try {
                n = Integer.parseInt(args[0]);
            } catch (Exception exc) {
            }
        }
        System.out.println("Solve x^2 - " + n + " * y^2 = 1");
        int size = 32767;
        long[] p = new long[size];
        long[] q = new long[size];
        long[] m = new long[size];
        long[] x = new long[size];
        p[0] = (int) Math.pow(n,0.5);
        q[0] = 1;
        m[0] = p[0] * p[0] - n;
        x[0] = p[0];
        int i = 0;
        while (m[i] != 1) {
            System.out.println("p = " + p[i] + ", q = " + q[i] + ", m = " + m[i]);
            int j = 1;
            long ami = Math.abs(m[i]);
            while(     j >= sqrtn
                    || j <= sqrtn - ami
                    || (j + x[i]) % ami != 0) {
                j ++;
            } // while
            x[i + 1] = j;
            p[i + 1] = (p[i] * j + n * q[i]) / ami;
            q[i + 1] = (p[i] + j     * q[i]) / ami;
            m[i + 1] = (j *    j - n)        / m[i];
            i ++;
        } // while i
        System.out.println("Solution: " + p[i] + "^2 - " + n + " * " + q[i] + "^2 = 1");
    } //main
} // ChakravalaTest
