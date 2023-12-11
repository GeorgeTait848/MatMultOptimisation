//
//  main.swift
//  MMOptimisation
//
//  Created by George Tait on 19/10/2023.
//

import Foundation

print("Hello, World!")
let pathFromHomeDirectory = CommandLine.arguments[1]

let dims = Array(stride(from: 100_000, through: 5_000_000, by: 100_000))
let diagMM: (SparseMatrix, SparseMatrix) -> SparseMatrix = {A,B in A.diagMM(rhs: B)}

let (omega, r_sq, lnA, t_total) = estimateTimeComplexity(dims: dims, operation: diagMM, initMethod: "diagonal", diag: 0)

print("omega = ", omega)
print("r^2 = ", r_sq)
print("intercept = ", lnA)
print("total time = ", t_total)

storeElapsedTimeDataToFileSparse(dims: dims, operations: [diagMM], columnNames: ["Diagonal Matrix"], pathFromHomeDirectory: pathFromHomeDirectory, logScaleX: true, logScaleY: true)



