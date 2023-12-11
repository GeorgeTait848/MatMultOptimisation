//
//  testDiagMMAlgorithm.swift
//  MMOptimisation
//
//  Created by George Tait on 11/12/2023.
//

import Foundation

/*
 Written an algorithm to multiply matrices on arbitrary diagonals in linear time. This code is to check that the test cases used in my lab book give the same output elements as the usual sparse matrix multiplication.
 The algorithm gives the same results so does work.
 
 The general sparse matrix multiplication algorithm was used to test against pen and paper calculations, to show that the algorithm is mathematically sound
 The diagMM algorithm is used to check that the coding implementation is correct. 
 */


//let A1 = SparseMatrix(values: [CoordinateStorage(value: 1, row: 0, col: 1), CoordinateStorage(value: 2, row: 1, col: 2), CoordinateStorage(value: 3, row: 2, col: 3), CoordinateStorage(value: 4, row: 3, col: 4)], size: 5)
//let B1 = SparseMatrix(values: [CoordinateStorage(value: 2, row: 0, col: 2), CoordinateStorage(value: 7, row: 1, col: 3), CoordinateStorage(value: 9, row: 2, col: 4)], size: 5)
//
//let A2 = SparseMatrix(values: [CoordinateStorage(value: 1, row: 0, col: 1), CoordinateStorage(value: 2, row: 1, col: 2), CoordinateStorage(value: 3, row: 2, col: 3), CoordinateStorage(value: 4, row: 3, col: 4)], size: 5)
//let B2  = SparseMatrix(values: [CoordinateStorage(value: 1, row: 1, col: 0), CoordinateStorage(value: 2, row: 2, col: 1), CoordinateStorage(value: 3, row: 3, col: 2), CoordinateStorage(value: 4, row: 4, col: 3)], size: 5)
//
//let A3 = SparseMatrix(values: [CoordinateStorage(value: 1, row: 0, col: 1), CoordinateStorage(value: 2, row: 1, col: 2), CoordinateStorage(value: 3, row: 2, col: 3), CoordinateStorage(value: 4, row: 3, col: 4)], size: 5)
//let B3 = SparseMatrix(values: [CoordinateStorage(value: 2, row: 2, col: 0), CoordinateStorage(value: 7, row: 3, col: 1), CoordinateStorage(value: 9, row: 4, col: 2)], size: 5)
//
//let A4 = SparseMatrix(values: [CoordinateStorage(value: 1, row: 1, col: 0), CoordinateStorage(value: 2, row: 2, col: 1), CoordinateStorage(value: 3, row: 3, col: 2), CoordinateStorage(value: 4, row: 4, col: 3)], size: 5)
//let B4 = B1
//
//let A5 = A4
//let B5 = A5
//
//print(A1*B1)
//print(A2*B2)
//print(A3*B3)
//print(A4*B4)
//print(A5*B5)


//print(A1.diagMM(rhs: B1))
//print(A2.diagMM(rhs: B2))
//print(A3.diagMM(rhs: B3))
//print(A4.diagMM(rhs: B4))
//print(A5.diagMM(rhs: B5))
