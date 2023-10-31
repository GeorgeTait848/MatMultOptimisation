//
//  main.swift
//  MMOptimisation
//
//  Created by George Tait on 19/10/2023.
//

import Foundation

print("Hello, World!\n")

let dims = [32,64,128,256,512]

let BFMM: (_ A: DoubleMatrixNestedArr, _ B: DoubleMatrixNestedArr) -> DoubleMatrixNestedArr = {A,B in return A.bruteForceMatrixMultiplication(B)}

let DCMM: (_ A: DoubleMatrixNestedArr, _ B: DoubleMatrixNestedArr) -> DoubleMatrixNestedArr = {A,B in return A.divideAndConquerMatrixMultiplication(B)}

let AMM: (_ A: DoubleMatrixNestedArr, _ B: DoubleMatrixNestedArr) -> DoubleMatrixNestedArr = {A,B in return A.accelerateFrameworkMatrixMultiplication(B)}

storeElapsedTimeDataToFile(dims: dims, operations: [BFMM, DCMM, AMM], columnNames: ["BFMM", "DCMM", "AMM"], pathFromHomeDirectory: "Desktop/rtData/timeComplexities.tsv")

