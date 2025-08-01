#!sage

# hadamard.sage - generate a Hadamard matrix of order 4*i
# @(#) $Id$
# 2025-07-31, Georg Fischer
#
# Usage:
#   sage hadamard.sage i
#----
from sage.combinat.matrices.hadamard_matrix import hadamard_matrix, skew_hadamard_matrix
i = int(sys.argv[1])
# print("construction=", hadamard_matrix(4*i, existence=True, construction_name=True))
H = hadamard_matrix(4*i)
print ("planes[", i, "]")
print (H.str()) 
print ("====");
