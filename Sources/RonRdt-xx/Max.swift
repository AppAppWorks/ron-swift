//
//  Max.swift
//  
//
//  Created by Lau Chun Kai on 2/8/2021.
//

import RonCore_xx

public extension Ron {
    enum MaxRDT {}
}

public extension Ron.MaxRDT {
    static func merge<Cursor>(output: inout Ron.TextFrame.Builder,
                              inputs: inout [Cursor]) -> Ron.Status where Cursor : RonTextFrameCursor {
        guard !inputs.isEmpty else {
            return .ok
        }
        if inputs[0].isValid && inputs[0].ref == .maxForm {
            output.appendOp(with: inputs[0])
            inputs[0].next()
        }
        // TODO  sanity: all ops ref the root
        var max = inputs.last!
        inputs[inputs.count - 1].next()
        for i in inputs.indices.reversed() {
            while inputs[i].isValid {
                if max < inputs[i] {
                    max = inputs[i]
                }
                inputs[i].next()
            }
        }
        output.appendOp(with: max)
        output.endChunk()
        return .ok
    }
}

private extension RonTextFrameCursor {
    static func < (lhs: Self, rhs: Self) -> Bool {
        guard lhs.op.count != 2 else {
            if rhs.op.count > 2 {
                return true
            } else {
                return rhs.id > lhs.id
            }
        }
        guard rhs.op.count != 2 else {
            return false
        }
        return (lhs.atom(at: 2) as! Ron.UUID) < (rhs.atom(at: 2) as! Ron.UUID)
    }
}
