//
//  tcAndDensity.swift
//  MMOptimisation
//
//  Created by George Tait on 07/12/2023.
//

import Foundation


public func getSparseMatrixTimeComplexityByDensityData(dims: [Int], densities: [Double]) -> [[Double]] {
    
    let sparseMM: (SparseMatrix, SparseMatrix) -> SparseMatrix = {A,B in return A*B}
    
    print("Calculating Time Complexities")
    let tcs = densities.map{estimateTimeComplexity(dims: dims, operation: sparseMM, initMethod: "density", density: $0)}
    
    var omegasGammas = [[Double]](repeating: [0.0, 0.0], count: densities.count)
    
    for i in 0..<densities.count {
        omegasGammas[i] = [tcs[i].0, tcs[i].2]
    }
    
    return omegasGammas
    
}

// need to generalise writing data to file to avoid having to copy code any longer, but for now will just copy from timeComplexities file and amend.

public func writeToFileByColumn(pathFromHome: String, data: [[Double]], columnNames: [String]) {
    
    let pathToFile = FileManager.default.homeDirectoryForCurrentUser.path() + pathFromHome
    let fileExists =  FileManager.default.fileExists(atPath: pathToFile)
    
    if !fileExists {
        let success = FileManager.default.createFile(atPath: pathToFile, contents: nil, attributes: nil)
        if success {
            print("Created file at \(pathToFile)")
        }
        
    }
    
    let columnsText = columnNames.joined(separator: "\t") + "\n"
    
    var outputText = columnsText
    
    for row in 0..<data.count {

        for col in 0..<data[0].count-1 {
            outputText += "\(String(format: "%4.3f", data[row][col]))\t"
        }
        outputText += "\(String(format: "%4.3f", data[row][data[0].count-1]))\n"
    }
    do {
    
    try  outputText.write(toFile: pathToFile, atomically: true, encoding: .utf8)
        print("successfully written to file")
    }
    
    catch {print("Unexpected Error: Could not write to file")}
    
}
