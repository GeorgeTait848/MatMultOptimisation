//
//  main.swift
//  MMOptimisation
//
//  Created by George Tait on 19/10/2023.
//

import Foundation

print("Hello, World!")

//let dims = [32,64,100,200,400]
//
//let BFMM: (_ A: DoubleMatrixNestedArr, _ B: DoubleMatrixNestedArr) -> DoubleMatrixNestedArr = {A,B in return A.bruteForceMatrixMultiplication(B)}
//
//let DCMM: (_ A: DoubleMatrixNestedArr, _ B: DoubleMatrixNestedArr) -> DoubleMatrixNestedArr = {A,B in return A.divideAndConquerMatrixMultiplication(B)}
//
//let AMM: (_ A: DoubleMatrixNestedArr, _ B: DoubleMatrixNestedArr) -> DoubleMatrixNestedArr = {A,B in return A.accelerateFrameworkMatrixMult(B)}
//
//
////let (bfmm_omega, bfmm_r_sq, bfmm_totalTime) = estimateMatMultTimeComplexity(dims: dims, operation: BFMM)
////let (dcmm_omega, dcmm_r_sq, dcmm_totalTime) = estimateMatMultTimeComplexity(dims: dims, operation: DCMM)
//let (amm_omega, amm_r_sq, amm_totalTime) = estimateMatMultTimeComplexity(dims: dims, operation: AMM)
//
//print("amm_omega: \(amm_omega)")
//print("amm_totalTime: \(amm_totalTime)")
//print("amm_r_sq: \(amm_r_sq)")
//


let x = DoubleMatrixNestedArr(dim: 25)
let y = DoubleMatrixNestedArr(dim: 25)


