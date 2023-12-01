//
//  timeComplexities.swift
//
//
//  Created by George Tait on 05/10/2023.
//

import Foundation





public func estimateTimeComplexity(dims: [Int], operation: (DoubleMatrixRowMajor, DoubleMatrixRowMajor)-> DoubleMatrixRowMajor) -> (Double, Double, Double, Double) {
    
    let elapsedTimes = getElapsedTimeData(dims: dims, operation: operation)
    let totalTime = elapsedTimes.reduce(0, +)
    let logElapsedTimes = elapsedTimes.map{ log($0) }
    
    let logDims = dims.map{ log(Double($0)) }

    let (omega, intercept) = getLinearFitCoefficientsFromLeastSquaresMethod(logDims, logElapsedTimes)
    
    let r_sq = getRSquaredCoefficient(logDims, logElapsedTimes)
    return (omega, r_sq, intercept, totalTime)
    
    
}

public func estimateTimeComplexity(dims: [Int], operation: (DoubleMatrixRowMajor) -> DoubleMatrixRowMajor) -> (Double, Double, Double) {
    
    let elapsedTimes = getElapsedTimeData(dims: dims, operation: operation)
    let totalTime = elapsedTimes.reduce(0, +)
    let logElapsedTimes = elapsedTimes.map{ log($0) }
    
    let logDims = dims.map{ log(Double($0)) }

    let (omega, _) = getLinearFitCoefficientsFromLeastSquaresMethod(logDims, logElapsedTimes)
    
    let r_sq = getRSquaredCoefficient(logDims, logElapsedTimes)
    return (omega, r_sq, totalTime)
}




public func getElapsedTimeData(dims: [Int], operation: (DoubleMatrixRowMajor) -> DoubleMatrixRowMajor) -> [Double] {

    
    let temp = dims.map{DoubleMatrixRowMajor(size: $0, elements: [Double](repeating: Double(Int.random(in: 0..<3)), count: $0*$0))}
    
    var times = [Double](repeating: 0, count: dims.count)
    
    for i in 0..<dims.count {
        let startTime = clock()
        let _ = operation(temp[i])
        let endTime = clock()
        
        let elapsedTime = Double((endTime - startTime))/Double(CLOCKS_PER_SEC/1_000)
        
        times[i] = elapsedTime
    }
    
    
    return times
}


public func getElapsedTimeData(dims: [Int], operation: (DoubleMatrixRowMajor, DoubleMatrixRowMajor) -> DoubleMatrixRowMajor) -> [Double] {

    
    let lhs = dims.map{DoubleMatrixRowMajor(size: $0, elements: [Double](repeating: Double(Int.random(in: 0..<3)), count: $0*$0))}
    let rhs = dims.map{DoubleMatrixRowMajor(size: $0, elements: [Double](repeating: Double(Int.random(in: 0..<3)), count: $0*$0))}
    
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






public func storeElapsedTimeDataToFileRowMajor(dims: [Int], operations: [(DoubleMatrixRowMajor,DoubleMatrixRowMajor) -> DoubleMatrixRowMajor], columnNames: [String], pathFromHomeDirectory: String, logScaleX: Bool = false, logScaleY: Bool = false) {

    let pathToFile = FileManager.default.homeDirectoryForCurrentUser.path() + pathFromHomeDirectory
    let fileExists =  FileManager.default.fileExists(atPath: pathToFile)
    
    if !fileExists {
        let success = FileManager.default.createFile(atPath: pathToFile, contents: nil, attributes: nil)
        if success {
            print("Created file at \(pathToFile)")
        }
    }
    
    let columnsText = "dims\t" + columnNames.joined(separator: "\t") + "\n"
    let outputText = columnsText + convertElapsedTimeDataToWriteableFormatRowMajor(dims: dims, operations: operations, logScaleX: logScaleX, logScaleY: logScaleY)
    
    do {
    
    try  outputText.write(toFile: pathToFile, atomically: true, encoding: .utf8) }
    
    catch {print("Unexpected Error: Could not write to file")}
    
    
}



public func convertElapsedTimeDataToWriteableFormatRowMajor(dims: [Int], operations: [(DoubleMatrixRowMajor,DoubleMatrixRowMajor) -> DoubleMatrixRowMajor], logScaleX: Bool = false, logScaleY: Bool = false) -> String {
    
    var times = [[Double]](repeating: [Double](repeating: 0.0, count: dims.count), count: operations.count)

    for i in 0..<operations.count {
        let currTimes = getElapsedTimeData(dims: dims, operation: operations[i])
        
        if logScaleY { times[i] = currTimes.map{log($0)}}
        else {times[i] = currTimes}
    }
    
    var outputText = ""
    
    for i in 0..<dims.count {
        
        if logScaleX { outputText += "\(log(Double(dims[i])))\t" }
        else { outputText += "\(dims[i])\t" }
        
        for j in 0..<operations.count-1 {
            outputText += "\(String(format: "%4.3f", times[j][i]))\t"
        }
        outputText += "\(String(format: "%4.3f",times[operations.count-1][i]))\n"
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


