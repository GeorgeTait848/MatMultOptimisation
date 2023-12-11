import Foundation


public enum SparseMatrixErrors: Error {
    case InvalidInputElementsSize
}
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
    
    public init(from rowMajorElements: [Double], size: Int) {
        
        self.size = size
        values = []
        for i in 0 ..< size*size {
            if rowMajorElements[i] == 0.0 { continue }
            let row = i / size
            let col = i % size
            values.append(CoordinateStorage(value: rowMajorElements[i], row: row, col: col))
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
    
    public init(size: Int, density: Double) {
        self.size = size
        
        if density == 0.0 {
            values = []
            return
        }
        
        values = []
        let doubleSz = Double(size)
        let numElem = density*doubleSz*doubleSz
        let step = Int((doubleSz*doubleSz-1)/(numElem - 1))
        var i = 0
        
        while i < size*size {
            let row = i/size
            let col = i % size
            values.append(CoordinateStorage(value: 1, row: row, col: col))
            i += step
        }
        
        values.sort()
        
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
        assert(lhs.size==rhs.size, "Cannot multiply sparse matrices of different sizes.")
        let dim = lhs.size
        var lhsCurrRowIdx = 0
        var lhsCurrIdx = 0
        
        var output = SparseMatrix(size: lhs.size)
        var rhs_transpose = rhs.transpose()
        
        var lhsvals = lhs.values
        lhsvals.sort()
        rhs_transpose.values.sort()
        
        for row in 0 ..< dim {
            var rhs_idx = 0
            for col in 0 ..< dim {
                var currOutputVal = 0.0
                var activePoint = false
                lhsCurrIdx = lhsCurrRowIdx
                lhsRowChecker : while ( lhsCurrIdx < lhsvals.count ) {
                    
                    if (lhsvals[lhsCurrIdx].row != row) { break lhsRowChecker }
        
                    rhsIndexChecker : while( rhs_idx < rhs_transpose.values.count ) {
                        
                        if rhs_transpose.values[rhs_idx].row < col {
                            rhs_idx += 1
                            continue rhsIndexChecker
                        }
                        if rhs_transpose.values[rhs_idx].row > col { break rhsIndexChecker }
                        
                        if rhs_transpose.values[rhs_idx].col < lhsvals[lhsCurrIdx].col {
                            rhs_idx += 1
                            continue rhsIndexChecker
                        }
                        
                        if rhs_transpose.values[rhs_idx].col > lhsvals[lhsCurrIdx].col { break rhsIndexChecker }
    
                        currOutputVal += (lhsvals[lhsCurrIdx].value * rhs_transpose.values[rhs_idx].value)
                        activePoint = true
                        break rhsIndexChecker
                    }
                    lhsCurrIdx += 1
                }
                if(activePoint) {
                    output.values.append(CoordinateStorage(value: currOutputVal, row: row, col: col))
                }
            }
            lhsCurrRowIdx = lhsCurrIdx
        }
        output.values.sort()
        return output
    }
    

    
    public func diagMM(rhs: SparseMatrix) -> SparseMatrix {
        
        let lhsDiag = getDiag()
        let rhsDiag = rhs.getDiag()
        let outputDiag = lhsDiag + rhsDiag
        
        if outputDiag >= self.size { return SparseMatrix(size: self.size)}
        
        let (startRow, endRow) = getOutputRowLimits(diag: lhsDiag, outputDiag: outputDiag)
        
        let numOutputElem = endRow - startRow + 1
        let (lhsOffset, rhsOffset) = getMultiplicationOffsets(numOutputElem: numOutputElem, diag: lhsDiag, rhsDiag: rhsDiag, outputDiag: outputDiag)
        
        var output = SparseMatrix(size: size)
        
        for i in 0..<numOutputElem {
            let val = self.values[i + lhsOffset].value * rhs.values[i + rhsOffset].value
            
            output.values.append(CoordinateStorage(value: val, row: startRow + i, col: startRow + i + outputDiag))
        }
        
        return output
    }
    
    private func getDiag() -> Int {
        
        if self.values[0].row == 0 {
            return self.values[0].col
        }
        
        return -self.values[0].row
    }
    
    private func getOutputRowLimits(diag: Int, outputDiag: Int) -> (Int, Int) {
        
        var startRow: Int
        var endRow: Int
        
        if outputDiag <= 0 {
            if diag <= 0 {
                startRow =  -min(diag, outputDiag)
                endRow = self.size - 1
            }
            else {
                startRow =  -outputDiag
                endRow = self.size - diag - 1
            }
        }
        
        else {
            if diag <= 0 {
                startRow = -diag
                endRow = self.size - outputDiag - 1
            }
            else {
                startRow = 0
                endRow = self.size - max(diag, outputDiag) - 1
            }
        }
        
        return (startRow, endRow)
    }
    
    private func getMultiplicationOffsets(numOutputElem: Int, diag: Int, rhsDiag: Int, outputDiag: Int) -> (Int, Int) {
        var lhsOffset: Int
        var rhsOffset: Int
        
        if diag <= outputDiag {
            lhsOffset = 0
            rhsOffset = size - abs(rhsDiag) - numOutputElem
        }
        else {
            lhsOffset = size - abs(diag) - numOutputElem
            rhsOffset = 0
        }
        
        return (lhsOffset, rhsOffset)
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
