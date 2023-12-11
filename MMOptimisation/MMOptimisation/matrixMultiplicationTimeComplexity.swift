//
//  matrixMultiplicationTimeComplexity.swift
//  MMOptimisation
//
//  Created by George Tait on 07/12/2023.
//

import Foundation

////let dims = Array(1...200) + Array(stride(from: 201, through: 10_000, by: 100))
//let dims = Array(stride(from: 2, through: 500, by: 10))
//let dims = Array(stride(from: 2, through: 512, by: 1)) + Array(stride(from: 520, through: 1000, by: 100)) + [1024]


////row major
////
////
//let BFMM: (_ A: DoubleMatrixRowMajor, _ B: DoubleMatrixRowMajor) -> DoubleMatrixRowMajor = {A,B in return A.bruteForceMatrixMultiplication(B)}
//
//let SMM: (_ A: DoubleMatrixRowMajor, _ B: DoubleMatrixRowMajor) -> DoubleMatrixRowMajor = {A,B in return A.strassen(B)}
//
//let AMM: (_ A: DoubleMatrixRowMajor, _ B: DoubleMatrixRowMajor) -> DoubleMatrixRowMajor = {A,B in return A.accelerateFrameworkMatrixMultiplication(B)}
//
//let (tcbf, bfr_sq, bf_lna, bftt) = estimateTimeComplexity(dims: dims, operation: BFMM)
//let (tca, ar_sq, a_lna, att) = estimateTimeComplexity(dims: dims, operation: AMM)
//let (tcs, sr_sq, s_lna, stt) = estimateTimeComplexity(dims: dims, operation: SMM)
//print(tcbf, bfr_sq, bf_lna, bftt)
//print(tca, ar_sq, a_lna, att)
//print(tcs, sr_sq, s_lna, stt)


//storeElapsedTimeDataToFileRowMajor(dims: dims, operations: [SMM], columnNames: [ "Strassen"], pathFromHomeDirectory: pathFromHomeDirectory, logScaleX: true, logScaleY: true)
//
//
//
