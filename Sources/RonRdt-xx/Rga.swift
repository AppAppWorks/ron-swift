//
//  Rga.swift
//  
//
//  Created by Lau Chun Kai on 1/8/2021.
//

import RonCore_xx

public extension Ron {
    /** Implements Causal Tree CRDT, which is mostly the same thing as Replicated
     * Growable Array CRDT. We store everything as a RON frame.
     * We call it use "RGA" cause every RDT here is a CT (in the broad sense). */
    enum RGArrayRDT<Cursor> where Cursor : RonTextFrameCursor {
        @usableFromInline
        static var mCursor: MergeCursor<Cursor> {
            .init(less: <)
        }
    }
}

public extension Ron.RGArrayRDT {
    typealias Frames = [Ron.TextFrame]
    typealias Cursors = [Cursor]
    
    @inlinable
    static func mergeBig(output: inout Ron.TextFrame.Builder,
                  inputs: Cursors) -> Ron.Status {
        fatalError("unimplemented")
    }
    
    @inlinable
    static func merge(output: inout Ron.TextFrame.Builder,
               inputs: Cursors) -> Ron.Status {
        guard inputs.count <= 3 else {
            return mergeBig(output: &output,
                            inputs: inputs)
        }
        
        var m = Self.mCursor
        let max = inputs.min { $0.id < $1.id }!
        var added: UInt64 = 0
        var b: UInt64 = 1
        for i in inputs {
            if i.id == max.id {
                m.append(i)
                added |= b
            }
            b <<= 1
        }
        
        while !m.isEmpty {
            let cur = m.current!
            output.appendOp(with: cur)
            let id = cur.id
            m.next()
            b = 1
            for i in inputs {
                if (b & added) == 0 && i.ref == id {
                    m.append(i)
                    added |= b
                }
                b <<= 1
            }
        }
        output.endChunk(term: .raw)
        
        added += 1
        return added == 1 << inputs.count
            ? .ok
            : .causeBreak.commenting("unattacheable pieces")
    }
    
    //    Status GC(Builder &output, const Frame &input) const {
    //        return Status::NOT_IMPLEMENTED;
    //    }
    //
    //    Status MergeGC(Builder &output, Cursors &inputs) const {
    //        return Status::NOT_IMPLEMENTED;
    //    }
}

public extension Ron {
    enum RGAEntry : UInt8 {
        case metaEntry
        case entry
        case remove
        case undo
        case trash
    }
}

public extension Ron.RGAEntry {
    @inline(__always)
    @inlinable
    static func + (lhs: Self, rhs: RawValue) -> Self? {
        .init(rawValue: rhs + 1)
    }
    
    @inline(__always)
    @inlinable
    static func - (lhs: Self, rhs: RawValue) -> Self? {
        .init(rawValue: rhs - 1)
    }
    
    @inline(__always)
    @inlinable
    static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

public extension Ron.UUID {
    static let rm = Self(value: 986569793370849280,
                         origin: 0)
    static let un = Self(value: 1040894463876005888,
                         origin: 0)
    static let `in` = Self(buf: "in")
    static let eq = Self(buf: "eq")
}

private extension RonTextFrameCursor {
    static func < (lhs: Self, rhs: Self) -> Bool {
        rhs.id < lhs.id
    }
}

public extension RonTextFrameCursor {
    @inline(__always)
    @inlinable
    var entryType: Ron.RGAEntry {
        if op.count == 3 && atom(at: 2).type == .uuid {
            let v = Ron.UUID(a: atom(at: 2))
            if v == .rm {
                return .remove
            }
            if v == .un {
                return .undo
            }
        }
        return .entry
    }
}

public extension Ron.TextFrame {
    /** Scans an RGA frame, produces a map of tombstones
     *  (true for invisible/removed ops, false for visibles). */
    @inlinable
    func scanRGA() -> (tombstones: [Bool], status: Ron.Status) {
        var tombstones = [Bool]()
        var state = Ron.RGAEntry.metaEntry
        var cur = cursor
        guard cur.next()() else {
            return (tombstones, .ok)
        }
        let root = cur.id
        guard cur.ref == .rgaForm && root.version != .time else {
            return (tombstones, .badArgs.commenting("not an RGA/CT frame"))
        }
        var path = IncStack<Ron.UUID>()
        var positions = IncStack<Ron.FSize>()
        path.append(root)
        var kills = [Bool]()
        kills.append(false)
        tombstones.append(true)
        positions.append(0)
        var depth: Ron.FSize = 1
        var pos: Ron.FSize = 0
        var ceiling: [Ron.FSize] = [0, 0, 0, 0, 0]
        var id = Ron.UUID()
        var ref = Ron.UUID()
        var et = Ron.RGAEntry.metaEntry
        
        repeat {
            cur.next()
            if cur.isValid {
                id = cur.id
                ref = cur.ref
                et = cur.entryType
            } else {
                id = .time(value: .never,
                           origin: 0)
                ref = root
                et = .metaEntry
            }
            pos += 1
            
            // sanity checks
            guard ref <= id else {
                return (tombstones, .badArgs.commenting("ref/id order reversal"))
            }
            guard id.version == .time && ref.version == .time else {
                return (tombstones, .badArgs.commenting("invalid event id"))
            }
            
            // unroll the stack, get to the (causal) parent
            while path.last != ref {
                var at: Ron.FSize = 0
                switch state {
                case .metaEntry:
                    return (tombstones, .causeBreak.commenting("not a CT"))
                case .entry:
                    if !(kills.last!) { break }
                    at = positions.last!
                    tombstones[.init(at)] = true
                case .remove:
                    if kills.last! { break }
                    at = ceiling[.init(Ron.RGAEntry.remove.rawValue)] - (depth - ceiling[.init(Ron.RGAEntry.remove.rawValue)])
                    if at > 0 { // aka ceiling[META_ENTRY]
                        kills[.init(at)] = true
                    }
                case .undo:
                    at = ceiling[.init(Ron.RGAEntry.undo.rawValue)] - (depth - ceiling[.init(Ron.RGAEntry.undo.rawValue)])
                    if at > ceiling[.init(Ron.RGAEntry.remove.rawValue)] {
                        kills[.init(at)] = true
                    }
                case .trash:
                    // a tombstone is already set
                    break
                }
                
                depth -= 1
                while depth == ceiling[.init(state.rawValue)] {
                    state = (state - 1)!
                }
                path.popLast()
                kills.removeLast()
                positions.popLast()
            }
            
            // state switch
            // versioning here. future subtrees := TRASH
            if et != state {
                if et != (state + 1) {
                    while state < .trash {
                        state = (state + 1)!
                        ceiling[.init(state.rawValue)] = depth
                    }
                } else {
                    state = et
                    ceiling[.init(state.rawValue)] = depth
                }
            }
            
            tombstones.append(state != .entry)
            depth += 1
            path.append(id)
            kills.append(false)
            positions.append(pos)
            
            assert(path.count == kills.count)
            assert(tombstones.count == pos + 1)
        } while cur.isValid
        
        tombstones.removeLast()
        
        return (tombstones, .ok)
    }
}

//
//}  // namespace ron
//
//#endif  // CPP_RGA_HPP
