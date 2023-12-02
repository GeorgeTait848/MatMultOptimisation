import Foundation

public struct SparseMatrix {
    
    let size: Int
    public var values: [CoordinateStorage]
    
    public init(from matrix: DoubleMatrixRowMajor) {
        size = matrix.size
        values = []
        for i in 0 ..< size {
            for j in 0 ..< size {
                if matrix[i,j] != 0.0 {
                    values.append(CoordinateStorage(value: matrix[i,j], row: i, col: j))
                }
            }
        }
        values.sort()
    }
    public init (size: Int) {
        self.size=size
        self.values = []
        
    }
    
    public init (values: [CoordinateStorage], size: Int) {
        self.size=size
        self.values = values.sorted()
    }
    
    
    public init(diag: Int, size: Int) {
        //used for benchmarking, diagonalised sparse matrices.
        
        assert(diag >= 1-size && diag <= size - 1, "Invalid Diagonal value, must be between \(-size + 1) and \(size - 1)")
        self.size = size
        values = []
        
        var i: Int
        
        if diag < 0 {
            i = -diag*size
        } else {
            i = diag
        }
        
        while i < size * size {
            let row = i / size
            let col = i % size
            values.append(CoordinateStorage(value: Double(Int.random(in: 0..<3)), row: row, col: col))
            i += size + 1
        }
    }
    // MARK: Arithmatic
    public static func * (left: Self, right: Double) -> Self {
        return Self(values: left.values.map( { $0 * right }), size: left.size)
    }
    
    public static func * (left: Double, right: Self) -> Self {
        return Self(values: right.values.map( { $0 * left }), size: right.size)
    }
    
    
    public static func / (left: Self, right: Double) -> Self {
        return Self(values: left.values.map( { $0 / right }), size: left.size)
    }
    
    public static func / (left: Double, right: Self) -> Self {
        return Self(values: right.values.map( { $0 / left }), size: right.size)
    }
    
    
    
    public static func scalarBinaryOperationAdditionLogic(
        lhs: SparseMatrix,
        rhs: SparseMatrix,
        operation: (Double,Double)->Double)
    -> SparseMatrix {
        assert (lhs.size == rhs.size)
        
        var out = SparseMatrix(size: lhs.size)
        var lhs_position = 0
        var rhs_position = 0
        
        while ( lhs_position < lhs.values.count && rhs_position < rhs.values.count ) {
            
            let right = rhs.values[rhs_position]
            let left = lhs.values[lhs_position]
            
            if ( right < left ) {
                out.values.append(right)
                rhs_position += 1
            } else if ( left < right ) {
                out.values.append(left)
                lhs_position += 1
            } else { // at the same position in matrix
                // if these add to zero its inefficient but unlikely to happen often
                out.values.append(CoordinateStorage(value: operation(left.value,  right.value), row: left.row, col: left.col))
                lhs_position += 1
                rhs_position += 1
            }
        }
        while (lhs_position < lhs.values.count) {
            out.values.append(lhs.values[lhs_position])
            lhs_position += 1
        }
        while (rhs_position < rhs.values.count) {
            out.values.append(rhs.values[rhs_position])
            rhs_position += 1
        }
        return out
    }
    
    public static func + (lhs: SparseMatrix,
                          rhs: SparseMatrix)
    -> SparseMatrix {
        return Self.scalarBinaryOperationAdditionLogic(lhs: lhs, rhs: rhs, operation: +)
    }
    
    public static func - (lhs: SparseMatrix,
                          rhs: SparseMatrix)
    -> SparseMatrix {
        return Self.scalarBinaryOperationAdditionLogic(lhs: lhs, rhs: rhs, operation: -)
    }
    
    public static func * (lhs: SparseMatrix, rhs: SparseMatrix) -> SparseMatrix {
        /*
         The code below was not added during the "week of coding" instead the above commented out
         code was used (it was needed only to conform to OperatorType and a proper sparse
         implementation was not needed for performance at that time).
         
         The below code was added to produce a figure Figure 10.4 after the week of coding and
         is based on some old java code of mine written with Peter Stiffell.
         
         It does not conform to my current view of clean code and needs to be re-written
         for clarity. This should only be done once a final sparse representation has been
         decided.
         */
        assert(lhs.size==rhs.size, "Cannot multiply sparse matrices of different sizes.")
        
        let dim = lhs.size
        
        var cntr = 0
        var kk = 0
        var k = 0
        
        var output = SparseMatrix(size: lhs.size)
        var B_el_t = rhs.transpose()
        
        var values = lhs.values
        values.sort()
        B_el_t.values.sort()
        
        for  i in 0 ..< dim {
            var l = 0
            for j in 0 ..< dim {
                var sum = 0.0
                var activePoint = false
                k = kk
                times2 : while ( k < values.count ) {
                    if (values[k].row == i) {
                        times1 : while( l < B_el_t.values.count ) {
                            if(B_el_t.values[l].row == j) {
                                if(values[k].col == B_el_t.values[l].col) {
                                    sum = sum + (values[k].value * B_el_t.values[l].value)
                                    activePoint = true
                                    break times1
                                } else if (B_el_t.values[l].col < values[k].col) {
                                    l += 1
                                } else {
                                    break times1
                                }
                            } else if (B_el_t.values[l].row < j) {
                                l += 1
                            } else {
                                break times1
                            }
                        }
                        k += 1
                    } else {
                        break times2
                    }
                }
                if(activePoint) {
                    output.values.append(CoordinateStorage(value: sum, row: i, col: j))
                    cntr += 1
                }
            }
            kk = k
        }
        output.values.sort()
        return output
    }
    
    
    public func transpose() -> SparseMatrix {
        var output = SparseMatrix(size: self.size)
        for element in self.values {
            output.values.append(CoordinateStorage(value: element.value, row: element.col, col: element.row))
        }
        return output
    }
    
}
     
    // multiplication by vector not required for current scope
    
//    public static func * (lhs: SparseMatrix,
//                          rhs: Vector) -> Vector {
    
    
//        assert(lhs.columns == rhs.space.dimension, "Index out of range")
//        assert(lhs.space == rhs.space, "Matrix operators and vector must be in same space")
//
//        var output = Vector(in: lhs.space)
//
//        for matrixElement in lhs.values {
//            let col = matrixElement.col
//            let row = matrixElement.row
//            let temp = matrixElement.value * rhs[col]
//            output[row] = output[row] + temp
//        }
//        return output
//    }
//}

extension DoubleMatrixRowMajor {
    public init(fromSparse matrix: SparseMatrix)  {
        size = matrix.size
        elements = Array.init(repeating: 0.0, count: size*size)
        for element in matrix.values {
            self[element.row,element.col] = element.value
        }
    }
}
// MARK: - Coodinate Storage

public struct CoordinateStorage {
    public init(value: Double, row: Int, col: Int) {
        self.value = value
        self.row = row
        self.col = col
    }
    
    public var value: Double
    public var row: Int
    public var col: Int
    
    
    
}

extension CoordinateStorage: Equatable {
    public static func == (lhs: CoordinateStorage, rhs: CoordinateStorage) -> Bool {
        let colsEqual   = lhs.col == rhs.col
        let rowsEqual   = lhs.row == rhs.row
        let valuesEqual = lhs.value == rhs.value
        
        return colsEqual && rowsEqual && valuesEqual
    }
}

extension CoordinateStorage {
    public static func / (left: CoordinateStorage, right: Double) -> CoordinateStorage {
        return CoordinateStorage(value: left.value / right , row: left.row, col: left.col)
    }
    
    public static func * (left: CoordinateStorage, right: Double) -> CoordinateStorage {
        return CoordinateStorage(value: left.value * right , row: left.row, col: left.col)
    }
    
    public static func * (left: Double, right: CoordinateStorage) -> CoordinateStorage {
        return CoordinateStorage(value: right.value * left , row: right.row, col: right.col)
    }
}


extension CoordinateStorage {
    public static prefix func - (value: CoordinateStorage) -> CoordinateStorage {
        return CoordinateStorage(value: -value.value, row: value.row, col: value.col)
    }
    
    
}
extension CoordinateStorage: CustomStringConvertible {
    public var description: String {
        return "[\(row),\(col)] = \(value)"
    }
}
// need to be able to order stored values to add and equate arrays of CoordinateStorage
// note that the Value itself is not needed and may not even be meaningful if scalar is an unordered field
extension CoordinateStorage: Comparable {
    public static func < (lhs: CoordinateStorage, rhs: CoordinateStorage) -> Bool {
        return ( lhs.row < rhs.row || ((lhs.row == rhs.row) ) && (lhs.col < rhs.col))
    }
}

//extension SparseMatrix: providesDoubleAndIntMultiplication where T: ComplexNumber {}
//  Created by M J Everitt on 20/01/2022.
