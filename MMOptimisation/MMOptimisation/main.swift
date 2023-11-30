//
//  main.swift
//  MMOptimisation
//
//  Created by George Tait on 19/10/2023.
//

import Foundation

print("Hello, World!")
//
let pathFromHomeDirectory = CommandLine.arguments[1]
//
////let dims = Array(1...200) + Array(stride(from: 201, through: 10_000, by: 100))
let dims = Array(stride(from: 2, through: 500, by: 10))
//let dims = Array(stride(from: 2, through: 512, by: 1)) + Array(stride(from: 520, through: 1000, by: 100)) + [1024]


//
////for nested arr
//
////let BFMM: (_ A: DoubleMatrixNestedArr, _ B: DoubleMatrixNestedArr) -> DoubleMatrixNestedArr = {A,B in return A.bruteForceMatrixMultiplication(B)}
////
////let DCMM: (_ A: DoubleMatrixNestedArr, _ B: DoubleMatrixNestedArr) -> DoubleMatrixNestedArr = {A,B in return A.divideAndConquerMatrixMultiplication(B)}
////
////let AMM: (_ A: DoubleMatrixNestedArr, _ B: DoubleMatrixNestedArr) -> DoubleMatrixNestedArr = {A,B in return A.accelerateFrameworkMatrixMultiplication(B)}
////
////storeElapsedTimeDataToFile(dims: dims, operations: [BFMM, DCMM, AMM], columnNames: ["Brute Force", "Divide and Conquer", "Accelerate"], pathFromHomeDirectory: pathFromHomeDirectory, logScaleX: true, logScaleY: true)
//
//
////row major
////
////
let BFMM: (_ A: DoubleMatrixRowMajor, _ B: DoubleMatrixRowMajor) -> DoubleMatrixRowMajor = {A,B in return A.bruteForceMatrixMultiplication(B)}

let SMM: (_ A: DoubleMatrixRowMajor, _ B: DoubleMatrixRowMajor) -> DoubleMatrixRowMajor = {A,B in return A.strassen(B)}

let AMM: (_ A: DoubleMatrixRowMajor, _ B: DoubleMatrixRowMajor) -> DoubleMatrixRowMajor = {A,B in return A.accelerateFrameworkMatrixMultiplication(B)}
//
//let (tcbf, bfr_sq, bf_lna, bftt) = estimateTimeComplexity(dims: dims, operation: BFMM)
//let (tca, ar_sq, a_lna, att) = estimateTimeComplexity(dims: dims, operation: AMM)
//let (tcs, sr_sq, s_lna, stt) = estimateTimeComplexity(dims: dims, operation: SMM)
//print(tcbf, bfr_sq, bf_lna, bftt)
//print(tca, ar_sq, a_lna, att)
//print(tcs, sr_sq, s_lna, stt)


storeElapsedTimeDataToFileRowMajor(dims: dims, operations: [SMM], columnNames: [ "Strassen"], pathFromHomeDirectory: pathFromHomeDirectory, logScaleX: true, logScaleY: true)

////
//
//
//let accelerateAdd: (_ A: DoubleMatrixRowMajor, _ B: DoubleMatrixRowMajor) -> DoubleMatrixRowMajor = {A,B in A.addAccelerate(B)}
//let naiveAdd: (_ A: DoubleMatrixRowMajor, _ B: DoubleMatrixRowMajor) -> DoubleMatrixRowMajor = {A,B in A+B}
//storeElapsedTimeDataToFileRowMajor(dims: dims, operations: [naiveAdd, accelerateAdd], columnNames: ["Naive", "Accelerate"], pathFromHomeDirectory: pathFromHomeDirectory, logScaleX: true, logScaleY: true)
//




