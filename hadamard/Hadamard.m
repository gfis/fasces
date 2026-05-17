(* Paley's Construction of Hadamard Matrices *)

(* September 1993 Levent Kitis lk3a@kelvin.seas.virginia.edu *)

BeginPackage["Hadamard`"]

Hadamard::usage =
    "Hadamard[n] returns randomly chosen n x n Hadamard matrices for n < 1001,
    if a Paley construction for n exists. One matrix for each factorization
    of n as given in the list class[n] is returned. Hadamard[n, k, t] returns 
    t randomly chosen n x n Hadamard matrices, each for a factorization of n
    given by class[n][[k]]. The default value of t is 1."

class::usage =
    "class[m] returns all possible {class, e, q, n} for m = 2^e(q^n + 1), where
    class = 0 if q = 0, class = 1 if Mod[q - 3, 4]==0, class = 2 if 
    Mod[q - 1, 4]==0."

Kronecker::usage =
    "Kronecker[a, b] returns the Kronecker product of the matrices a and b."

Begin["`Private`"]

Hadamard[1] := {{1}}

Hadamard[2] := {{1, 1},{1, -1}}

Hadamard[n_Integer] :=  Map[Paley, class[n], 1] /; 2 < n < 1001

Hadamard[n_Integer, k_Integer?Positive, t_Integer:1] := 
    With[ { A = class[n] },
        If[ A=={} || k > Length[A] || t < 1, {}, Paley[ A[[k]], t ] ]
        ] /; 1 < n < 1001

Hadamard[__] := {}

Paley[{0, e_, q_, n_}, t_:1] :=  Paley[0, e, q, n]

Paley[{c_, e_, q_, n_}, t_:1] :=  
    Module[ { G, G2, x },
        {G, G2} = If[ n==1, GF[q], GF[q, n, x] ];
        If[ t==1, Paley[c, e, q, n, G, G2], 
                  Apply[ Paley, Array[{c, e, q, n, G, G2}&, t], 1]]
          ]

Paley[0, 0, 0, 1] := Hadamard[1]

Paley[0, 1, 0, 1] := Hadamard[2]

Paley[0, e_, 0, 1] := Kronecker[ Hadamard[2], Paley[0, e - 1, 0, 1] ] 

Paley[1, 0, q_, n_, G_, G2_] :=
    With[ {A = fill[Q[G, G2, q, n], -1] /. {0 -> -1}},
        Join[ {Array[1&, q^n + 1]}, Prepend[#, 1]& /@ A ]
        ]

Paley[1, e_, q_, n_, G_, G2_] := Kronecker[ Paley[0, e, 0, 1], Paley[1, 0, q, n, G, G2] ]

Paley[2, 1, q_, n_, G_, G2_] := 
    With[ { B = {{1, -1}, {-1, -1}} },
     Kronecker[ H2[G, G2,q, n], Hadamard[2] ] + Kronecker[ IdentityMatrix[q^n + 1], B ]
        ]

Paley[2, e_, q_, n_, G_, G2_] :=
    Kronecker[ Paley[2, 1, q, n, G, G2], Paley[0, e - 1, 0, 1] ]

H2[G_, G2_, q_, n_] := 
    Join[ {Prepend[Array[1&, q^n], 0]}, Prepend[#, 1]& /@ fill[Q[G, G2, q, n]] ]


pmod[Q_, P_, q_] := PolynomialMod[ PolynomialMod[Q, P], q ]

paleypower :={{3, 2}, {3, 3}, {3, 4}, {3, 5}, {5, 2}, {5, 3}, {7, 2}, {7, 3}, 
              {11, 2}, {13, 2}, {17, 2}, {19, 2}}

basis[x_] := {2 + x + x^2, 1 + 2 x + x^3, 2 + x + x^4, 1 + 2 x + x^5, 
              2 + x + x^2, 2 + 3 x + x^3, 3 + x + x^2, 2 + 3 x + x^3,
              7 + x + x^2, 2 + x + x^2,   3 + x + x^2, 2 + x + x^2}

pgen[q_, n_, x_] := 
    Module[ {k},
        {{k}} = Position[ paleypower, {q, n} ];
        Part[ basis[x], k ]
          ]

pgen[__] := {}

GF[p_] :=
    With[ { G = Range[0, p - 1] },
        {G, Union[PowerMod[ Rest[G], 2, p]]} 
        ] 

GF[q_, n_, x_] :=
    Module[ { Q = pgen[q, n, x], G, G2},
        G = Prepend[ pmod[ x^Range[q^n -1], Q, q ], 0 ];
        G2 = Union[ Rest[ pmod[ G^2, Q, q] ] ];
        {G, G2}
          ]

rperm[A_] := Map[ #[[2]] &, Sort[Array[{Random[], A[[#]]} &, Length[A]] ] ]

ksi[0, X_] := 0

ksi[s_, X_] := 1 /; MemberQ[X, s]

ksi[s_, X_] := -1

zerorow[n_] := Array[0 &, n]

fill[m_, sym_:1] := 
    Module[{n = Length[m], A},
        A = Append[ MapThread[Join, {zerorow /@ Range[n], m}], zerorow[n + 1] ];
        A + Sign[sym] Transpose[A]
          ]

Kronecker[a_, b_] := Flatten[Apply[AppendRow, Outer[Times, a, b], 1], 1]

AppendRow[{}, {}] := {}

AppendRow[(m__)?MatrixQ] := Apply[Join, Transpose[{m}], 1] /; SameRowSize[{m}]
 
SameRowSize[m_List] := Apply[SameQ, (Dimensions[#1][[1]] & ) /@ m]

paley[n_Integer?Positive] := 
    Module[ { fc, seq },
        seq =  Range[ 0, FactorInteger[n][[1, 2]] ];
        fc = Prepend[ FactorInteger[ n/2^# - 1 ], #] & /@  seq;
        fc = Partition[ Flatten[ Select[ fc, Length[#] == 2 & ] ], 3 ];
        DeleteCases[ fc, {_, 2, _} ]
           ] /; Mod[n, 4] == 0 && n < 1001

paley[n_] := {}

class[{}]:= {}

class[{a_, b_, c_}] := With[ { n = b^c },
    Which[b == 0, 0, Mod[n - 3, 4] == 0, 1, Mod[n - 1, 4] == 0 && a > 0, 2]
                           ]

class[n_] := With[ {A = paley[n]}, AppendRow[ Partition[class /@ A, 1], A] ]

upper[u_] :=
    With[ {A =  Rest[u], n =  Length[u] - 2 },
        NestList[ Rest, A, n ] - Drop[u, -1]
        ]

Q[ G_, G2_, q_, 1] :=
    With[ { A = Map [Mod[#, q] &, upper[rperm[G]], {2}] },
        Map[ ksi[#, G2] &, A, {2}]
        ]

Q[ G_, G2_, q_, n_] :=
    With[ { A = Map[ PolynomialMod[#, q ] &, upper[ rperm[G] ], {2} ] },
        Map[ ksi[#, G2] &, A, {2}]
        ]

End[]
EndPackage[]


