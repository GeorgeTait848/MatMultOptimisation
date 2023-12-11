//
//  sparseDiagonalTC.swift
//  MMOptimisation
//
//  Created by George Tait on 07/12/2023.
//

import Foundation

//let pathFromHomeDirectory = CommandLine.arguments[1]
//
////let pathFromHomeDirectory = "Desktop/rtData/x.dat"
//let dims = Array(stride(from: 100, through: 2_000, by: 100))
//let sparseMM: (SparseMatrix, SparseMatrix) -> SparseMatrix = {A,B in return A*B}
//
//let lc = 50
//
//var lowDensities = [Double](repeating: 0.0, count: lc)
//
//for i in 0..<lowDensities.count {
//    lowDensities[i] += 0.1*Double(i)/Double(lc)
//}
//
//
//let hc = 18
//var highDensities = [Double](repeating: 0.0, count: hc)
//
//
//for i in 0..<hc {
//    highDensities[i] += 0.1 + 0.9*Double(i)/Double(hc)
//}
//
//let densities = lowDensities + highDensities
//let omegasGammasByDensity = getSparseMatrixTimeComplexityByDensityData(dims: dims, densities:densities)
//
//let omegas = omegasGammasByDensity.map{$0[0]}
//
//var dataToWrite = [[Double]](repeating: [0.0, 0.0], count: densities.count)
//
//for i in 0..<densities.count {
//    dataToWrite[i] = [densities[i], omegas[i]]
//}
//
//writeToFileByColumn(pathFromHome: pathFromHomeDirectory, data: dataToWrite, columnNames: ["densities", "omega"])
