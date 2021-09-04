//
//  Meta.swift
//  
//
//  Created by Lau Chun Kai on 2/8/2021.
//

import RonCore_xx

public extension Ron {
    enum MetaRDT<Cursor> where Cursor : RonTextFrameCursor {
        @usableFromInline
        static func mCursor(cursors: Cursors) -> MergeCursor<Cursor> {
            .init(cursors: cursors,
                  less: <)
        }
    }
}

public extension Ron.MetaRDT {
    typealias Frame = Ron.TextFrame
    typealias Builder = Frame.Builder
    typealias Cursors = [Cursor]
    
    
    @inlinable
    static func merge(output: inout Builder,
               inputs: Cursors) -> Ron.Status {
        var m = Self.mCursor(cursors: inputs)
        m.merge(with: &output)
        return .ok
    }
    
    @inlinable
    static func gc(output: inout Builder,
            input: Frame) -> Ron.Status {
        var c = input.cursor
        while c.isValid {
            output.appendOp(with: c)
            c.next()
        }
        return .ok
    }
    
    @inlinable
    static func mergeGc(output: inout Builder,
                 inputs: Cursors) -> Ron.Status {
        merge(output: &output,
              inputs: inputs)
    }
}

private extension RonTextFrameCursor {
    static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id ? lhs.ref > rhs.ref : lhs.id < rhs.id
    }
}
