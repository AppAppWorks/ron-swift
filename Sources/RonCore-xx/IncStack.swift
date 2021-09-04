//
//  File.swift
//  
//
//  Created by Lau Chun Kai on 30/7/2021.
//

import Foundation

public protocol BinaryIntegerAddable : Equatable {
    associatedtype B : BinaryInteger
    static func + (lhs: Self, rhs: B) -> Self
}

extension Ron.UUID : BinaryIntegerAddable {
    public typealias B = UInt64
}

extension Ron.FSize : BinaryIntegerAddable {
    public typealias B = Self
}

public struct IncStack<Value> where Value : BinaryIntegerAddable {
    @usableFromInline
    var _count: Count = 0
    @usableFromInline
    var spans: Spans = []
    
    public init() {}
}

public extension IncStack {
    typealias Count = UInt32
    
    struct Span {
        public var value: Value
        public var count: Count
    }
    
    typealias Spans = [Span]
    
    struct Iterator : IteratorProtocol {
        @usableFromInline
        var spans: Spans
        @usableFromInline
        var i: Int = 0
        @usableFromInline
        var off: Count
    }
    
    @inline(__always) @inlinable
    var count: Count {
        _count
    }
    
    @inline(__always) @inlinable
    var spanCount: Count {
        .init(spans.count)
    }
    
    @inline(__always) @inlinable
    var isEmpty: Bool {
        _count == 0
    }
    
    @inline(__always) @inlinable
    var first: Value? {
        spans.first?.value
    }
    
    @inline(__always) @inlinable
    var last: Value? {
        spans.last.map { $0.value + Value.B($0.count - 1) }
    }
    
    @inline(__always) @inlinable
    var firstSpan: Span? {
        spans.first
    }
    
    @inline(__always) @inlinable
    var lastSpan: Span? {
        spans.last
    }
    
    @inlinable
    mutating func append(_ i: Value) {
        _count += 1
        if spans.isEmpty {
            spans.append(.init(value: i))
        } else if (spans.last.map { $0.value + Value.B($0.count) }) == i {
            spans[spans.count - 1].count += 1
        } else {
            spans.append(.init(value: i))
        }
    }
    
    @inlinable
    mutating func popLast() {
        assert(!isEmpty)
        _count -= 1
        if spans.last?.count == 1 {
            _ = spans.popLast()
        } else {
            spans[spans.count - 1].count -= 1
        }
    }
}

extension IncStack : Sequence {
    public func makeIterator() -> Iterator {
        .init(spans: spans,
              off: 0)
    }
}

public extension IncStack.Iterator {
    @inlinable
    mutating func next() -> Value? {
        if i < spans.count {
            defer {
                off += 1
                if off == spans[i].count {
                    off = 0
                    i += 1
                }
            }
            
            return spans[i].value + Value.B(off)
        } else {
            return nil
        }
    }
    
    @inline(__always) @inlinable
    var value: Value {
        spans[i].value + Value.B(off)
    }
    
    @discardableResult @inlinable
    mutating func skipSpan(_ maxCount: IncStack.Count) -> IncStack.Count {
        let s = IncStack.Count(spans.count)
        if off + maxCount < s {
            off += maxCount
            return maxCount
        } else {
            let rest = s - off
            i += 1
            off = 0
            return rest
        }
    }
}

extension IncStack.Iterator : Equatable {
    @inlinable
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.off == rhs.off && lhs.spans == rhs.spans
    }
}

public extension IncStack.Span {
    @inlinable
    init(value: Value) {
        self.value = value
        count = 1
    }
}

extension IncStack.Span : Equatable {}
