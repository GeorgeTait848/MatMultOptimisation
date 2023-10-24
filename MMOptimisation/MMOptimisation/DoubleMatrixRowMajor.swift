//
//  DoubleMatrixRowMajor.swift
//  MMOptimisation
//
//  Created by George Tait on 24/10/2023.
//

import Foundation


public struct DoubleMatrixRowMajor {
        
    public var elements: [Double]
    public var dim: Int
    
    public init (dim: Int, elements: [Double]) {
        self.elements = elements
        self.dim = dim
    }
    
    public init (dim: Int) {
        self.init(dim: dim, elements: [Double](repeating: 0.0, count: dim*dim))
    }
    
    public subscript(position: Int) -> Double {
        get {return elements[position]}
        set {self.elements[position] = newValue}
    }
    
    public subscript(row: Int, col: Int) -> Double {
        
        get {
            let index = row*dim + col
            assert(index < elements.count, "Index out of range getting vector value")
            return elements[index]
        }
        set {
            let index = row*dim + col
            assert(index < elements.count, "Index out of range setting vector value")
            elements[index] = newValue
        }
    }
    
    public func addPaddingToGetEvenDimensions() -> DoubleMatrixRowMajor {
        
        var temp = Self(dim: dim+1)
        
        for i in 0..<self.dim {
            for j in 0..<self.dim {
                temp[i,j] = self[i,j]
            }
        }
        
        return temp
    }

}
