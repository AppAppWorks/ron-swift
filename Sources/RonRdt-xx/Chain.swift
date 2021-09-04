//
//  Chain.swift
//  
//
//  Created by Lau Chun Kai on 2/8/2021.
//

import RonCore_xx

public extension Ron {
    enum OpChain {
        @usableFromInline
        static func mCursor(cursors: Cursors) -> MergeCursor<Ron.Op> {
            .init(cursors: cursors,
                  less: <)
        }
    }
}

public extension Ron.OpChain {
    typealias Frame = Ron.TextFrame
    typealias Builder = Frame.Builder
    typealias Cursors = [Ron.Op]
    
    static func merge(output: inout Builder,
               inputs: Cursors) -> Ron.Status {
        var m = Self.mCursor(cursors: inputs)
        m.merge(with: &output)
        return .ok
    }
    
    static func gc(output: inout Builder,
            input: Frame) -> Ron.Status {
        var cur = input.cursor
        output.appendAll(from: &cur)
        return .ok
    }
    
    static func mergeGc(output: inout Builder,
                 inputs: Cursors) -> Ron.Status {
        merge(output: &output,
              inputs: inputs)
    }
}

private extension Ron.Op {
    static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.id < rhs.id
    }
}
