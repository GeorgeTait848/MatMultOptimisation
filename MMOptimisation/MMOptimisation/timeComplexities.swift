//
//  timeComplexities.swift
//
//
//  Created by George Tait on 05/10/2023.
//

import Foundation



public func estimateMatMultTimeComplexity(dims: [Int], operation: (DoubleMatrixNestedArr, DoubleMatrixNestedArr) -> DoubleMatrixNestedArr) -> (Double, Double, Double) {
    
    
    let elapsedTimes = getElapsedTimeData(dims: dims, operation: operation)
    let totalTime = elapsedTimes.reduce(0, +)
    let logElapsedTimes = elapsedTimes.map{ log($0) }
    
    let logDims = dims.map{ log(Double($0)) }

    let (omega, _) = getLinearFitCoefficientsFromLeastSquaresMethod(logDims, logElapsedTimes)
    
    let r_sq = getRSquaredCoefficient(logDims, logElapsedTimes)
    return (omega, r_sq, totalTime)
    
}


public func getElapsedTimeData(dims: [Int], operation: (DoubleMatrixNestedArr, DoubleMatrixNestedArr) -> DoubleMatrixNestedArr) -> [Double] {

    
    let lhs = dims.map{DoubleMatrixNestedArr(elements: [[Double]](repeating: [Double](repeating: Double(Int.random(in: 0..<3)), count: $0), count: $0))}
    let rhs = dims.map{DoubleMatrixNestedArr(elements: [[Double]](repeating: [Double](repeating: Double(Int.random(in: 0..<3)), count: $0), count: $0))}
    
    var times = [Double](repeating: 0, count: dims.count)
    
    for i in 0..<dims.count {
        let startTime = clock()
        let _ = operation(lhs[i], rhs[i])
        let endTime = clock()
        
        let elapsedTime = Double((endTime - startTime))/Double(CLOCKS_PER_SEC/1_000)
        
        times[i] = elapsedTime
    }
    
    
    return times
}



public func storeElapsedTimeDataToFile(dims: [Int], operation: (DoubleMatrixNestedArr,DoubleMatrixNestedArr) -> DoubleMatrixNestedArr, filename: String) {
    
    let outputText = convertElapsedTimeDataToWriteableFormat(dims: dims, operation: operation)
    
    let pathToFile = FileManager.default.homeDirectoryForCurrentUser.path + "/Desktop/rtData/"
    let writeFilename = pathToFile + "'\(filename)'"
    
    _ = FileManager.default.createFile(atPath: writeFilename, contents: nil, attributes: nil)
    
    do {
    
    try  outputText.write(toFile: writeFilename, atomically: false, encoding: .utf8) }
    
    catch {print("Unexpected Error: Could not write to file")}
    
    
}

public func convertElapsedTimeDataToWriteableFormat(dims: [Int], operation: (DoubleMatrixNestedArr,DoubleMatrixNestedArr) -> DoubleMatrixNestedArr) -> String {
    
    let times = getElapsedTimeData(dims: dims, operation: operation)
    var outputText = ""
    
    for i in 0..<dims.count {
        
        outputText += "\(dims[i]) \t \(times[i]) \n"
        
    }
    
    return outputText
}


public func getRSquaredCoefficient(_ x: [Double], _ y: [Double]) -> Double {
    
//  Method from https://en.wikipedia.org/wiki/Coefficient_of_determination
    
    let (estimatingSlope, estimatingIntercept) = getLinearFitCoefficientsFromLeastSquaresMethod(x, y)
    let ybar = y.reduce(0.0, +)/Double(y.count)
    
    var sumOfResSquares = 0.0
    var totalSumOfSquares = 0.0
    
    for i in 0..<x.count {
        
        let f_i = x[i]*estimatingSlope + estimatingIntercept
        
        sumOfResSquares += (y[i] - f_i) * (y[i] - f_i)
        totalSumOfSquares += (y[i] - ybar) * (y[i] - ybar)
        
    }
    
    return 1.0 - sumOfResSquares/totalSumOfSquares
    
}

public func getLinearFitCoefficientsFromLeastSquaresMethod(_ x: [Double], _ y: [Double]) -> (Double, Double) {
    
//    Method from: https://www.varsitytutors.com/hotmath/hotmath_help/topics/line-of-best-fit

    
    let xbar = x.reduce(0.0, +)/Double(x.count)
    let ybar = y.reduce(0.0, +)/Double(y.count)
    
    var numerator = 0.0
    var denom = 0.0
    
    for i in 0..<x.count {
        
        numerator += (x[i] - xbar)*(y[i] - ybar)
        denom += (x[i] - xbar)*(x[i] - xbar)
    }
    
    let slope = numerator/denom
    let intercept = ybar - slope*xbar
    
    return (slope,intercept)
    
}


