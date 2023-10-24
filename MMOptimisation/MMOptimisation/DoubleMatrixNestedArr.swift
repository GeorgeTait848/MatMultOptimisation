//
//  DoubleMatrixNestedArr.swift
//  MMOptimisation
//
//  Created by George Tait on 19/10/2023.
// SQUARE MATRICES ONLY

import Foundation
import Accelerate

public struct DoubleMatrixNestedArr {
    
    var elements: [[Double]]
    
    public init(elements: [[Double]]) {
        self.elements = elements
    }
    
    public init(dim: Int) {
        self.elements = [[Double]](repeating: [Double](repeating: 0.0, count: dim), count: dim)
    }
    
    public init(topLeft: [[Double]], topRight: [[Double]], bottomLeft: [[Double]], bottomRight: [[Double]]) {
        
        let dim = 2*topLeft.count
        var elem: [[Double]] = []
        
        for i in 0..<dim/2 {
            elem.append(topLeft[i] + topRight[i])
        }
        for i in 0..<dim/2 {
            elem.append(bottomLeft[i] + bottomRight[i])
        }
        
        self.elements = elem
        
    }
    
    public subscript (row: Int) -> [Double]{
        return self.elements[row]
    }
    
    public subscript (row: Int, col: Int) -> Double {
        get {
            assert(row >= 0 && row < elements.count && col >= 0 && col < elements.count)
            return elements[row][col]
        }
        
        set {
            assert(row >= 0 && row < elements.count && col >= 0 && col < elements.count)
            elements[row][col] = newValue
        }
    }
    
    
    public func bruteForceMatrixMultiplication(_ rhs: DoubleMatrixNestedArr) -> DoubleMatrixNestedArr {
        let dim = elements.count
        var output = Self(dim: dim)
        
        for i in 0 ..< dim {
            for j in 0 ..< dim {
                for k in 0 ..< dim {
                    output[i, j] = output[i, j] + self[i, k] * rhs[k, j]
                }
            }
        }
        return output
    }
    
    public static func + (lhs: DoubleMatrixNestedArr, rhs: DoubleMatrixNestedArr) -> DoubleMatrixNestedArr {
        let dim = lhs.elements.count
        var output = Self(dim: dim)
        
        for i in 0..<dim {
            for j in 0..<dim {
                
                output[i,j] = lhs[i,j] + rhs[i,j]
            }
        }
        return output
        
    }
    
    
    public func accelerateFrameworkMatrixMult(_ rhs: DoubleMatrixNestedArr) -> DoubleMatrixNestedArr {
        
        let dim = self.elements.count
        var outputElementsFlat = [Double](repeating: 0.0, count: dim*dim)
        
        vDSP_mmulD(self.elements.flatMap{$0}, vDSP_Stride(1), rhs.elements.flatMap{$0}, vDSP_Stride(1), &outputElementsFlat, vDSP_Stride(1),
                   vDSP_Length(dim), vDSP_Length(dim), vDSP_Length(dim))
        
        var outputElements = [[Double]](repeating: [Double](repeating: 0.0, count: dim), count: dim)
        
        for i in 0..<dim {
            
            outputElements[i] = Array(outputElementsFlat[i*dim..<(i+1)*dim])
            
        }
        
        return DoubleMatrixNestedArr(elements: outputElements)
    }
    
    public func divideAndConquerMatrixMultiplication(_ rhs: DoubleMatrixNestedArr) -> DoubleMatrixNestedArr {
        
        let dim = elements.count
        
        if dim == 2 {
            
            return Self(elements: [
                [self[0,0]*rhs[0,0] + self[0,1]*rhs[1,0], self[0,0]*rhs[0,1] + self[0,1]*rhs[1,1]],
                [self[1,0]*rhs[0,0] + self[1,1]*rhs[1,0], self[1,0]*rhs[0,1] + self[1,1]*rhs[1,1]]
                    ])
        }
        
        if dim % 2 != 0 {
            let newlhs = self.addPadding()
            let newrhs = rhs.addPadding()
            return newlhs.divideAndConquerMatrixMultiplication(newrhs).removePadding()
        }
        
        let (a,b,c,d) = self.quartets()
        let (e,f,g,h) = rhs.quartets()
        
        let outputTopLeft = a.divideAndConquerMatrixMultiplication(e) + b.divideAndConquerMatrixMultiplication(g)
        let outputTopRight = a.divideAndConquerMatrixMultiplication(f) + b.divideAndConquerMatrixMultiplication(h)
        let outputBottomLeft = c.divideAndConquerMatrixMultiplication(e) + d.divideAndConquerMatrixMultiplication(g)
        let outputBottomRight = c.divideAndConquerMatrixMultiplication(f) + d.divideAndConquerMatrixMultiplication(h)
        
        return Self(topLeft: outputTopLeft.elements, topRight: outputTopRight.elements, bottomLeft: outputBottomLeft.elements, bottomRight: outputBottomRight.elements)
        
        
    }
    
    public func quartets() -> (DoubleMatrixNestedArr, DoubleMatrixNestedArr, DoubleMatrixNestedArr, DoubleMatrixNestedArr) {
        
        let dim = elements.count
        assert(dim % 2 == 0, "can only get quartets for even sized matrix")
        
        var topLeft: [[Double]] = []
        var topRight: [[Double]] = []
        var bottomLeft: [[Double]] = []
        var bottomRight: [[Double]] = []
        
        for i in 0..<dim/2 {
            topLeft.append(Array(elements[i][0..<dim/2]))
            topRight.append(Array(elements[i][dim/2..<dim]))
        }
        
        for i in dim/2..<dim {
            bottomLeft.append(Array(elements[i][0..<dim/2]))
            bottomRight.append(Array(elements[i][dim/2..<dim]))
        }
        
        return (Self(elements: topLeft), DoubleMatrixNestedArr(elements: topRight), DoubleMatrixNestedArr(elements: bottomLeft), DoubleMatrixNestedArr(elements: bottomRight))
        
    }
    
    public func addPadding() -> DoubleMatrixNestedArr {
        var output = elements
        for i in 0..<output.count {
            output[i].append(0.0)
        }
        output.append([Double](repeating: 0.0, count: elements.count + 1))
        return DoubleMatrixNestedArr(elements: output)
    }
    
    public func parallelAddPadding() -> DoubleMatrixNestedArr {
        
        var output = elements
        let padRows: (_ index: Int) -> Void = {index in output[index].append(0.0)}
        
        DispatchQueue.concurrentPerform(iterations: output.count, execute: padRows)
        
        output.append([Double](repeating: 0.0, count: elements.count + 1))
        
        return DoubleMatrixNestedArr(elements: output)
        
    }

    public func removePadding() -> DoubleMatrixNestedArr {
        var output = elements
        output.removeLast()
        for i in 0..<output.count {
            output[i].removeLast()
        }
        return DoubleMatrixNestedArr(elements: output)
    }
    
    
}
