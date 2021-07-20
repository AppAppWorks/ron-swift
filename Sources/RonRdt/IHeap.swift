//
//  File.swift
//  
//
//  Created by Lau Chun Kai on 8/7/2021.
//

import Foundation
import RonCore

struct IHeap {
    var primary: (Op, Op) -> ComparisonResult
    var secondary: ((Op, Op) -> ComparisonResult)?
    var iters = [Frame.Cursor()]
}

extension IHeap {
    var count: Int {
        iters.count
    }
    
    mutating func insert(_ frame: Frame) {
        insert(.init(frames: frame))
    }
    
    mutating func insert(_ batch: Batch) {
        let cursors = batch
            .map(\.body)
            .map(Frame.Cursor.init)
        for var cursor in cursors {
            while let op = cursor.op, !op.isRegular {
                _ = cursor.next()
            }
            guard let op = cursor.op, op.isRegular else { continue }
            let at = iters.count
            iters.append(cursor)
            raise(i: at)
        }
    }
    
    var current: Op? {
        iters.count > 1 ? iters[1].op : nil
    }
    
    mutating func frame() -> Frame {
        var cur = Frame()
        while let op = current {
            cur.append(op)
            _ = next()
        }
        return cur
    }
    
    mutating func nextPrim() -> Op? {
        var eqs = [Int]()
        listEqs(at: 1, eqs: &eqs)
        if eqs.count > 1 {
            eqs.sort()
        }
        eqs.reversed().forEach { next(i: $0) }
        return current
    }
    
    mutating func clear() {
        iters = [.init()]
    }
}

private extension IHeap {
    func less(i: Int, j: Int) -> Bool {
        let ii = iters[i].op ?? .zero
        let jj = iters[j].op ?? .zero
        var c = primary(ii, jj)
        if c == .orderedSame, let secondary = secondary {
            c = secondary(ii, jj)
        }
        return c == .orderedAscending
    }
    
    mutating func sink(i: Int) {
        var to = i
        var j = i << 1
        if j < iters.count && less(i: j, j: i) {
            to = j
        }
        j += 1
        
        if j < iters.count && less(i: j, j: to) {
            to = j
        }
        
        if to != i {
            iters.swapAt(i, to)
            sink(i: to)
        }
    }
    
    mutating func raise(i: Int) {
        let j = i >> 1
        if j > 0 && less(i: i, j: j) {
            iters.swapAt(i, j)
            if j > 1 {
                raise(i: j)
            }
        }
    }
    
    mutating func remove(i: Int) {
        if iters.count == 2 && i == 1 {
            clear()
        } else {
            if iters.count - 1 == i {
                iters.removeLast()
            } else {
                iters[i] = iters.removeLast()
            }
            sink(i: i)
        }
    }
    
    mutating func next(i: Int) {
        _ = iters[i].next()
        if let op = iters[i].op, !op.isHeader {
            sink(i: i)
        } else {
            remove(i: i)
        }
    }
    
    func listEqs(at index: Int,
                 eqs: inout [Int]) {
        eqs.append(index)
        let l = index << 1
        if l < iters.count {
            if primary(iters[1].op ?? .zero, iters[l].op ?? .zero) == .orderedSame {
                listEqs(at: l, eqs: &eqs)
            }
        }
        let r = l | 1
        if r < iters.count {
            if primary(iters[1].op ?? .zero, iters[r].op ?? .zero) == .orderedSame {
                listEqs(at: r, eqs: &eqs)
            }
        }
    }
}

extension IHeap : Sequence {
    struct Iterator : IteratorProtocol {
        var sequence: IHeap
        
        mutating func next() -> Op? {
            sequence.next(i: 1)
            return sequence.current
        }
    }
    
    func makeIterator() -> Iterator {
        .init(sequence: self)
    }
    
    var eof: Bool {
        iters.count <= 1
    }
    
    mutating func next() -> Op? {
        next(i: 1)
        return current
    }
}

func comparator(n: Op.UuidIndex,
                desc: Bool = false) -> (Op, Op) -> ComparisonResult {
    {
        let (op1, op2) = desc ? ($1, $0) : ($0, $1)
        return op1.uuid(n).compare(op2.uuid(n))
    }
}

let eventComparator = comparator(n: .two)
let eventComparatorDesc = comparator(n: .two, desc: true)
let refComparator = comparator(n: .three)
let refComparatorDesc = comparator(n: .three, desc: true)
