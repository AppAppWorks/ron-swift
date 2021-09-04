//
//  Matrix.swift
//  
//
//  Created by Lau Chun Kai on 3/8/2021.
//

import RonCore_xx

public extension Ron {
    enum Matrix {}
}

public extension Ron.Matrix {
    struct Index {
        public var first: Ron.FSize
        public var second: Ron.FSize
        
        @usableFromInline
        init(first: Ron.FSize,
             second: Ron.FSize) {
            self.first = first
            self.second = second
        }
    }
    
    enum RDT {
        typealias Matrix = [Ron.Matrix.Index : Ron.UUID]
    }
}

//public extension Ron.Matrix.Index {
//    @inline(__always)
//    static let max = Self(first: .max,
//                          second: .max)
//}

extension Ron.Matrix.Index : Hashable {}

public extension Ron.Matrix.Index {
    @inlinable
    init?<C>(cursor: C) where C : RonTextFrameCursor {
        guard cursor.op.count == 2 + 3 && cursor.hasValue(of: .int, at: 2) && cursor.hasValue(of: .int, at: 3) else {
            return nil
        }
        self.init(first: .init(cursor.atom(at: 2).value.integer),
                  second: .init(cursor.atom(at: 3).value.integer))
    }
}

public extension Ron.Matrix.RDT {
    static func merge(output: inout Ron.TextFrame.Builder,
                      inputs: [Ron.TextFrame.Cursor]) -> Ron.Status {
        var m = Ron.MergeCursor(cursors: inputs,
                                less: <)
        m.merge(with: &output)
        return .ok
    }
    
    static func gc(output: inout Ron.TextFrame.Builder,
                   input: Ron.TextFrame) -> Ron.Status {
        var max = Matrix()
        var read = input.cursor
        repeat {
            guard let at = Ron.Matrix.Index(cursor: read) else { continue }
            max[at] = read.id
            read.next()
        } while read.isValid
        var write = input.cursor
        repeat {
            if let at = Ron.Matrix.Index(cursor: write),
               max[at] == write.id {
                output.appendOp(with: write)
            }
            write.next()
        } while write.isValid
        return .ok
    }
    
    //    Status MergeGC(Builder &output, Cursors &inputs) const {
    //        return Status::NOT_IMPLEMENTED;
    //    }
}

private extension RonTextFrameCursor {
    @inline(__always)
    static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.id < rhs.id
    }
}
