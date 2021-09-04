//
//  Lww.swift
//  
//
//  Created by Lau Chun Kai on 3/8/2021.
//

import RonCore_xx

public extension Ron {
    enum LastWriteWinsRDT {}
}

private extension RonTextFrameCursor {
    @inline(__always)
    static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.id < rhs.id
    }
}

public extension Ron.LastWriteWinsRDT {
    static func merge(output: inout Ron.TextFrame.Builder,
                      inputs: [Ron.TextFrame.Cursor]) -> Ron.Status {
        
        var m = Ron.MergeCursor(cursors: inputs.map { c -> Ron.TextFrame.Cursor in
            var c = c
            c.next()
            return c
        },
                                less: <)
        m.merge(with: &output)
        return .ok
    }
    
    // TODO: - this impl will not match escaped keys, e.g. '\006bey' for 'key'.
    // Either way, the latest/winning value will go first.
    // May use Frame::unescape() and/or Op unesc flag.
    static func gc(output: inout Ron.TextFrame.Builder,
                   input: Ron.TextFrame) -> Ron.Status {
        var last = [Ron.Slice : Ron.UUID]()
        var scan = input.cursor
        repeat {
            guard scan.op.count >= 3 else { continue }
            let key = Ron.Slice(data: input.data,
                                range: scan.atom(at: 2).origin.range)
            last[key] = scan.id
        } while scan.next()()
        
        var filter = input.cursor
        if filter.op.count == 2 {
            output.appendOp(with: filter)
        }
        repeat { // TODO maybe check op pattern here
            guard filter.op.count >= 3 else { continue }
            let key = Ron.Slice(data: input.data,
                                range: scan.atom(at: 2).origin.range)
            if last[key] == filter.id {
                output.appendOp(with: filter)
            }
        } while filter.next()()
        
        return .ok
    }
    
    static func mergeGc(output: inout Ron.TextFrame.Builder,
                        inputs: [Ron.TextFrame.Cursor]) -> Ron.Status {
        var unclean = Ron.TextFrame.Builder()
        let ok = merge(output: &unclean,
                       inputs: inputs)
        guard ok() else { return ok }
        let uc = unclean.release()
        return gc(output: &output,
                  input: uc)
    }
}
