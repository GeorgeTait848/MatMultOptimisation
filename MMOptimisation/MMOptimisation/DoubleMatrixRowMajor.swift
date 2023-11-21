////
////  DoubleMatrixRowMajor.swift
////  MMOptimisation
////
////  Created by George Tait on 24/10/2023.
////

import Foundation
import Accelerate

public struct DoubleMatrixRowMajor {
    public var elements: [Double]
    public var size: Int // assuming matrices are always square for simplicity
 
    init(size: Int, elements: [Double]) {
        self.size = size
        self.elements = elements
    }
    
    init(size: Int) {
        self.init(size: size, elements: [Double](repeating: 0.0, count: size*size))
    }
 
    public subscript(row: Int, col: Int) -> Double {
        get { return elements[row * size + col] }
        set { elements[row * size + col] = newValue }
    }
 
    private init(topleft: DoubleMatrixRowMajor, topright: DoubleMatrixRowMajor, bottomleft: DoubleMatrixRowMajor, bottomright: DoubleMatrixRowMajor) {
        let size = topleft.size * 2
        var elements = [Double](repeating: 0.0, count: size * size)
        
        // Copy values to the new matrix
        for i in 0..<topleft.size {
            for j in 0..<topleft.size {
                elements[i * size + j] = topleft[i, j]
                elements[i * size + j + topleft.size] = topright[i, j]
                elements[(i + topleft.size) * size + j] = bottomleft[i, j]
                elements[(i + topleft.size) * size + j + topleft.size] = bottomright[i, j]
            }
        }
        
        self.init(size: size, elements: elements)
    }
    
    public func addPadding() -> DoubleMatrixRowMajor {
        let newSize = size + 1
        var newElements = [Double](repeating: 0.0, count: newSize * newSize)
 
        for i in 0..<size {
            for j in 0..<size {
                newElements[i * newSize + j] = self[i, j]
            }
        }
        return DoubleMatrixRowMajor(size: newSize, elements: newElements)
    }
 
    public func removePadding() -> DoubleMatrixRowMajor {
        let newSize = size - 1
        var newElements = [Double](repeating: 0.0, count: newSize * newSize)
 
        for i in 0..<newSize {
            for j in 0..<newSize {
                newElements[i * newSize + j] = self[i, j]
            }
        }
 
        return DoubleMatrixRowMajor(size: newSize, elements: newElements)
    }
 
    public static func + (lhs: DoubleMatrixRowMajor, rhs: DoubleMatrixRowMajor) -> DoubleMatrixRowMajor {
        var result = lhs
        for i in 0..<lhs.size {
            for j in 0..<lhs.size {
                result[i, j] += rhs[i, j]
            }
        }
        return result
    }
    
    public static func - (lhs: DoubleMatrixRowMajor, rhs: DoubleMatrixRowMajor) -> DoubleMatrixRowMajor {
        var result = lhs
        for i in 0..<lhs.size {
            for j in 0..<lhs.size {
                result[i, j] -= rhs[i, j]
            }
        }
        return result
    }
 
    // In-place extraction of sub-matrices
    public func subMatrix(rowOffset: Int, colOffset: Int) -> DoubleMatrixRowMajor {
        let halfSize = size / 2
        var subElements = [Double](repeating: 0.0, count: halfSize * halfSize)
        for i in 0..<halfSize {
            for j in 0..<halfSize {
                subElements[i * halfSize + j] = self[i + rowOffset, j + colOffset]
            }
        }
        return DoubleMatrixRowMajor(size: halfSize, elements: subElements)
    }
 
    public func divideAndConquerMatrixMultiplication(_ rhs: DoubleMatrixRowMajor) -> DoubleMatrixRowMajor {
        assert(size == rhs.size, "Matrix sizes must match for multiplication")
 
        // Base case: 2x2 matrix multiplication
        if size == 2 {
            let a = self[0, 0], b = self[0, 1], c = self[1, 0], d = self[1, 1]
            let e = rhs[0, 0], f = rhs[0, 1], g = rhs[1, 0], h = rhs[1, 1]
 
            return DoubleMatrixRowMajor(size: 2, elements: [
                a * e + b * g, a * f + b * h,
                c * e + d * g, c * f + d * h
            ])
        }
 
        if size % 2 != 0 {
            let lhsPadded = addPadding()
            let rhsPadded = rhs.addPadding()
            return lhsPadded.divideAndConquerMatrixMultiplication(rhsPadded).removePadding()
        }
 
        let a = subMatrix(rowOffset: 0, colOffset: 0)
        let b = subMatrix(rowOffset: 0, colOffset: size/2)
        let c = subMatrix(rowOffset: size/2, colOffset: 0)
        let d = subMatrix(rowOffset: size/2, colOffset: size/2)
 
        let e = rhs.subMatrix(rowOffset: 0, colOffset: 0)
        let f = rhs.subMatrix(rowOffset: 0, colOffset: size/2)
        let g = rhs.subMatrix(rowOffset: size/2, colOffset: 0)
        let h = rhs.subMatrix(rowOffset: size/2, colOffset: size/2)
 
        let ae = a.divideAndConquerMatrixMultiplication(e)
        let bg = b.divideAndConquerMatrixMultiplication(g)
        let af = a.divideAndConquerMatrixMultiplication(f)
        let bh = b.divideAndConquerMatrixMultiplication(h)
        let ce = c.divideAndConquerMatrixMultiplication(e)
        let dg = d.divideAndConquerMatrixMultiplication(g)
        let cf = c.divideAndConquerMatrixMultiplication(f)
        let dh = d.divideAndConquerMatrixMultiplication(h)
 
        var resultElements = [Double](repeating: 0.0, count: size * size)
        for i in 0..<size {
            for j in 0..<size {
                if i < size/2 && j < size/2 {
                    resultElements[i * size + j] = ae[i, j] + bg[i, j]
                } else if i < size/2 && j >= size/2 {
                    resultElements[i * size + j] = af[i, j - size/2] + bh[i, j - size/2]
                } else if i >= size/2 && j < size/2 {
                    resultElements[i * size + j] = ce[i - size/2, j] + dg[i - size/2, j]
                } else {
                    resultElements[i * size + j] = cf[i - size/2, j - size/2] + dh[i - size/2, j - size/2]
                }
            }
        }
 
        return DoubleMatrixRowMajor(size: size, elements: resultElements)
    }
    
    public func bruteForceMatrixMultiplication(_ rhs: DoubleMatrixRowMajor) -> DoubleMatrixRowMajor {
        
        let dim = self.size
        var output = Self(size: dim)
        
        for i in 0 ..< dim {
            for j in 0 ..< dim {
                for k in 0 ..< dim {
                    output[i, j] = output[i, j] + self[i, k] * rhs[k, j]
                }
            }
        }
        return output
    }
    
    public func accelerateFrameworkMatrixMultiplication(_ rhs: DoubleMatrixRowMajor) -> DoubleMatrixRowMajor {
        
        let dim = self.size
        var outputElements = [Double](repeating: 0.0, count: dim*dim)
        
        vDSP_mmulD(self.elements, vDSP_Stride(1), rhs.elements, vDSP_Stride(1), &outputElements, vDSP_Stride(1),
                   vDSP_Length(dim), vDSP_Length(dim), vDSP_Length(dim))
        
        return DoubleMatrixRowMajor(size: dim, elements: outputElements)
    }

    
    public func strassen(_ rhs: DoubleMatrixRowMajor) -> DoubleMatrixRowMajor {
    //https://en.wikipedia.org/wiki/Strassen_algorithm
        
        if size == 2 {
            let a = self[0, 0], b = self[0, 1], c = self[1, 0], d = self[1, 1]
            let e = rhs[0, 0], f = rhs[0, 1], g = rhs[1, 0], h = rhs[1, 1]
 
            return DoubleMatrixRowMajor(size: 2, elements: [
                a * e + b * g, a * f + b * h,
                c * e + d * g, c * f + d * h
            ])
        }
 
        if size % 2 != 0 {
            let lhsPadded = addPadding()
            let rhsPadded = rhs.addPadding()
            return lhsPadded.strassen(rhsPadded).removePadding()
        }
        
        let a11 = subMatrix(rowOffset: 0, colOffset: 0)
        let a12 = subMatrix(rowOffset: 0, colOffset: size/2)
        let a21 = subMatrix(rowOffset: size/2, colOffset: 0)
        let a22 = subMatrix(rowOffset: size/2, colOffset: size/2)
 
        let b11 = rhs.subMatrix(rowOffset: 0, colOffset: 0)
        let b12 = rhs.subMatrix(rowOffset: 0, colOffset: size/2)
        let b21 = rhs.subMatrix(rowOffset: size/2, colOffset: 0)
        let b22 = rhs.subMatrix(rowOffset: size/2, colOffset: size/2)
        
        
        let m1 = (a11 + a22).strassen(b11 + b22)
        let m2 = (a21 + a22).strassen(b11)
        let m3 = a11.strassen(b12 - b22)
        let m4 = a22.strassen(b21 - b11)
        let m5 = (a11 + a12).strassen(b22)
        let m6 = (a21 - a22).strassen(b11 + b12)
        let m7 = (a12-a22).strassen(b21 + b22)
        
        let topleft = m1 + m4 - m5 + m7
        let topright = m3 + m5
        let bottomleft = m2 + m4
        let bottomright = m1 - m2 + m3 + m6
        
        let res = DoubleMatrixRowMajor(topleft: topleft, topright: topright, bottomleft: bottomleft, bottomright: bottomright)
        
        return res
        
    }
    
    public func addAccelerate(_ rhs: DoubleMatrixRowMajor) -> DoubleMatrixRowMajor {
        
        var elem = [Double](repeating: 0.0, count: elements.count)
        vDSP_vaddD(elements, vDSP_Stride(1), rhs.elements, vDSP_Stride(1), &elem, 1, vDSP_Length(elements.count))
        
        
        return DoubleMatrixRowMajor(size: self.size, elements: elem)
    }
}
