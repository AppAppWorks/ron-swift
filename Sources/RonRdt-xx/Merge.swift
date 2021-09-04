//
//  Merge.swift
//  
//
//  Created by Lau Chun Kai on 1/8/2021.
//

import RonCore_xx

public extension Ron {
    /// asc-sorting iterator heap
    struct MergeCursor<Cursor> where Cursor : RonTextFrameCursor {
        @usableFromInline
        var cursors: [Cursor]
        @usableFromInline
        var less: (Cursor, Cursor) -> Bool
        
        public init(cursors: [Cursor] = [],
                    less: @escaping (Cursor, Cursor) -> Bool) {
            self.cursors = cursors
            self.less = less
        }
    }
}

public extension Ron.MergeCursor {
    typealias Frames = [Ron.TextFrame]
    typealias Cursors = [Cursor]
    
    @inlinable
    mutating func append(_ input: Cursor) {
        guard input.isValid else {
            return
        }
        cursors.append(input)
        pop(at: .init(cursors.count) - 1)
    }
    
    @inlinable
    var isEmpty: Bool {
        cursors.isEmpty
    }
    
    @inlinable
    var op: Ron.Atoms? {
        cursors.first?.op
    }
    
    @inlinable
    var frame: Ron.TextFrame? {
        cursors.first?.frame
    }
    
    @inlinable
    var current: Cursor? {
        cursors.first
    }
    
    /// advances to the next op
    /// @return non-empty
    @discardableResult @inlinable
    mutating func next() -> Bool {
        let id = Ron.UUID(a: op![.init(Ron.opIdIdx)])
        while step() && Ron.UUID(a: op![.init(Ron.opIdIdx)]) == id {}
        // // idempotency
        return count > 0
    }
    
    //    // returns the data buffer for the current cursor/op
    //    const std::string& data() const { return op().data(); }
    //    //
    
    mutating func merge(with output: inout Ron.TextFrame.Builder) -> Ron.Status {
        guard !isEmpty else {
            return .ok
        }
        repeat {
            // TODO: ???? to delete
            output.appendOp(with: cursors[0])
        } while next()
        output.endChunk()
        return .ok
    }
}

private extension Ron.FSize {
    @inline(__always)
    var up: Self {
        ((self + 1) >> 1) - 1
    }
    
    @inline(__always)
    var left: Self {
        ((self + 1) << 1) - 1
    }
    
    @inline(__always)
    var right: Self {
        (self + 1) << 1
    }
}

extension Ron.MergeCursor {
    @inline(__always)
    @usableFromInline
    var count: Ron.FSize {
        .init(cursors.count)
    }
    
    @usableFromInline
    func lessThan(a: Ron.FSize,
                  b: Ron.FSize) -> Bool {
        less(cursors[.init(a)], cursors[.init(b)])
    }
    
    @inline(__always)
    @usableFromInline
    mutating func swap(a: Ron.FSize,
                       b: Ron.FSize) {
        cursors.swapAt(.init(a), .init(b))
    }
    
    @usableFromInline
    mutating func pop(at idx: Ron.FSize) {
        guard idx != 0 else {
            return
        }
        let u = idx.up
        guard !lessThan(a: u, b: idx) else {
            return
        }
        swap(a: idx, b: u)
        pop(at: u)
    }
    
    @usableFromInline
    mutating func push(at idx: Ron.FSize) {
        let l = idx.left
        let r = idx.right
        if r < count && lessThan(a: r, b: idx) { // r is an option
            if lessThan(a: l, b: r) {
                swap(a: l, b: idx)
                push(at: l)
            } else {
                swap(a: r, b: idx)
                push(at: r)
            }
        } else if l < count && lessThan(a: l, b: idx) {
            swap(a: l, b: idx)
            push(at: l)
        }
    }
    
    @usableFromInline
    mutating func eject() {
        guard count > 0 else {
            return
        }
        cursors[0] = cursors.last!
        cursors.removeLast()
        push(at: 0)
    }
    
    @usableFromInline
    mutating func step() -> Bool {
        if cursors[0].next()() {
            push(at: 0)
        } else {
            eject()
        }
        return count > 0
    }
}

//private extension RonTextFrameCursor {
//    static func < (lhs: Self, rhs: Self) -> Bool {
//        guard lhs.op.count != 2 else {
//            guard rhs.op.count <= 2 else {
//                return true
//            }
//            return lhs.id > rhs.id
//        }
//        guard rhs.op.count != 2 else {
//            return false
//        }
//        return (lhs.atom(at: 2) as! Ron.UUID) < (rhs.atom(at: 2) as! Ron.UUID)
//    }
//}
