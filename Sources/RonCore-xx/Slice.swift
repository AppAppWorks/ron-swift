//
//  Slice.swift
//  
//
//  Created by Lau Chun Kai on 21/7/2021.
//

import Foundation

public extension Ron {
    typealias Codepoint = UInt32
    typealias FSize = UInt32
//    typealias CharRef = Substring.UTF8View
    
    /** A [from,till) byte range. Limited to 2^30 bytes due to FSIZE_MAX. */
    typealias Range = Swift.Range<FSize>
    
//    /** A [from,till) byte range. Limited to 2^30 bytes due to FSIZE_MAX. */
//    struct Range {
//        @usableFromInline
//        var limits: (FSize, FSize)
//    }
    
    /** A reference to a raw memory slice. Same function as rocksdb::Slice.
     * Can't use an iterator range cause have to reference raw buffers (file
     * reads, mmaps, whatever the db passes to us...).
     * A Slice does NOT own the memory! */
    struct Slice {
        @usableFromInline
        var buf: Buf!
        @usableFromInline
        var range: Range
    }
//    struct Slice {
//        @usableFromInline
//        var buf: CharRef?
////        var buf: Data?
//        @usableFromInline
//        var range: Range
//    }
}

public extension Ron.Range {
    typealias FSize = Ron.FSize
    
    @inlinable
    init<B1, B2>(at: B1,
                 forLength length: B2) where B1 : BinaryInteger, B2: BinaryInteger {
        self.init(uncheckedBounds: (FSize(at), FSize(at) + FSize(length)))
    }
    
    @inlinable
    init() {
        self.init(uncheckedBounds: (0, 0))
    }
    
    @inlinable
    func offset<B>(at idx: B = .zero) -> FSize where B : BinaryInteger {
        assert(lowerBound + .init(idx) < upperBound)
        return lowerBound + .init(idx)
    }
    
    @inlinable
    mutating func consume<B>(_ length: B) where B : BinaryInteger {
        self = (lowerBound + .init(length))..<upperBound
    }
    
    @inlinable
    mutating func shorten<B>(by length: B) where B : BinaryInteger {
        self = lowerBound..<upperBound - .init(length)
    }
    
    @inlinable
    mutating func endAt<B>(_ offset: B) where B : BinaryInteger {
        self = lowerBound..<(.init(offset))
    }
    
    @inlinable
    mutating func resize<B>(_ newSize: B) where B : BinaryInteger {
        self = lowerBound..<lowerBound + .init(newSize)
    }
    
    @inlinable
    static func += <B>(lhs: inout Self, operand: B) where B : BinaryInteger {
        lhs.consume(operand)
    }
    
    @inlinable
    var intRange: Range<Int> {
        .init(lowerBound)..<(.init(upperBound))
    }
}

//extension Ron.Range : Equatable {
//    @inlinable
//    public static func == (lhs: Self, rhs: Self) -> Bool {
//        lhs.limits == rhs.limits
//    }
//}

//public extension Ron.Slice {
//    typealias Range = Ron.Range
//    typealias CharRef = Ron.CharRef
//    typealias FSize = Ron.FSize
//
//    @inlinable
//    init(data: CharRef,
//         range: Range) {
//        buf = data
//        self.range = range
//    }
//
//    @inlinable
//    init<B>(buf: CharRef?,
//            size: B) where B : BinaryInteger {
//        self.buf = buf
//        self.range = 0..<(.init(size))
//    }
//
//    @inlinable
//    init(from: CharRef,
//         till: CharRef) {
//
//        self.init(buf: from,
//                  size: from.distance(to: till))
//        assert(till >= from)
//        assert(from.distance(to: till) <= FSize.max)
//    }
//
//    @inlinable
//    init() {
//        self.init(buf: nil,
//                  size: 0)
//    }
//
//    @inlinable
//    init(data: inout String) {
//
//        data.withCString {
//            self.init(buf: $0,
//                      size: data.utf8.count)
//        }
//    }
//}

public extension Ron.Slice {
    typealias Buf = Substring.UTF8View
    typealias Range = Ron.Range
    typealias FSize = Ron.FSize
    
    @inlinable
    init(data: Buf,
         range: Range) {
        buf = data
        self.range = range
    }
    
    @inlinable
    init<B>(buf: Buf?,
            size: B) where B : BinaryInteger {
        self.buf = buf
        range = 0..<(.init(size))
    }
    
    @inlinable
    init() {
        self.init(buf: nil,
                  size: 0)
    }
    
    @inlinable
    init(data: String) {
        let utf8 = data.dropFirst(0).utf8
        self.init(buf: utf8,
                  size: utf8.count)
    }
    
    @inlinable
    init(data: String,
         range: Range) {
        let utf8 = data.dropFirst(0).utf8
        self.init(data: utf8,
                  range: range)
    }
    
    @inlinable
    var begin: Range.Bound {
//        buf.index(buf.startIndex,
//                  offsetBy: .init(range.lowerBound))
        range.lowerBound
    }
    
    @inlinable
    var end: Range.Bound {
//        buf.index(buf.startIndex,
//                  offsetBy: .init(range.upperBound))
        range.upperBound
    }
    
    @inlinable
    func withUTF8<T>(_ body: (_ root: UnsafePointer<UInt8>,
                              _ begin: UnsafePointer<UInt8>,
                              _ end: UnsafePointer<UInt8>) throws -> T) rethrows -> T {
        try buf.withContiguousStorageIfAvailable { buffer in
            try body(buffer.baseAddress!,
                     buffer.baseAddress! + .init(range.lowerBound),
                     buffer.baseAddress! + .init(range.upperBound))
        }!
    }
    
    @inlinable
    subscript(idx: Range.Bound) -> Buf.Element {
        buf.withContiguousStorageIfAvailable { ptr in
            ptr[.init(idx)]
        }!
    }
    
    @inlinable
    subscript(range: Range) -> [UInt8] {
        buf.withContiguousStorageIfAvailable { ptr in
            Array(ptr[range.intRange])
        }!
    }
    
    @inlinable
    subscript(range: ClosedRange<Range.Bound>) -> [UInt8] {
        buf.withContiguousStorageIfAvailable { ptr in
            Array(ptr[Int(range.lowerBound)...Int(range.upperBound)])
        }!
    }
    
    @inlinable
    subscript(range: PartialRangeFrom<Range.Bound>) -> [UInt8] {
        buf.withContiguousStorageIfAvailable { ptr in
            Array(ptr[Int(range.lowerBound)...])
        }!
    }
    
    @inlinable
    subscript(range: PartialRangeThrough<Range.Bound>) -> [UInt8] {
        buf.withContiguousStorageIfAvailable { ptr in
            Array(ptr[...Int(range.upperBound)])
        }!
    }
    
    @inlinable
    subscript(range: PartialRangeUpTo<Range.Bound>) -> [UInt8] {
        buf.withContiguousStorageIfAvailable { ptr in
            Array(ptr[..<Int(range.upperBound)])
        }!
    }
    
    @inlinable
    func isGreater(range: Ron.Range,
                   other: String.UTF8View) -> Bool {
        buf.withContiguousStorageIfAvailable {
            let slice = $0[range.intRange]
            return slice.withUnsafeBytes { b1 in
                other.withContiguousStorageIfAvailable {
                    $0.withUnsafeBytes { b2 in
                        strcmp(b2.bindMemory(to: CChar.self).baseAddress!,
                               b1.bindMemory(to: CChar.self).baseAddress!) > 0
                    }
                }!
            }
        }!
    }
    
    @inlinable
    subscript(idx: Buf.Index) -> Buf.Element {
        buf[idx]
    }
    
    @inlinable
    static func += <B>(value: inout Self, operand: B) where B : BinaryInteger {
        value.range += operand
    }
    
    @inlinable
    var count: Int {
        range.count
    }
    
    @inlinable
    var isEmpty: Bool {
        range.isEmpty
    }
    
    @inlinable
    mutating func reset() {
        range = 0..<range.endIndex
    }
    
    @inlinable
    func resetting() -> Self {
        .init(buf: buf,
              size: range.endIndex)
    }
    
    @inlinable
    func consumed() -> Self {
        .init(buf: buf,
              size: 0)
    }
    
    @inlinable
    mutating func consume<B>(_ size: B) where B : BinaryInteger {
        range.consume(size)
    }
    
    @inlinable
    mutating func endAt<B>(_ offset: B) where B : BinaryInteger {
        range.endAt(offset)
    }
    
    @inlinable
    func isSame(_ other: Self) -> Bool {
        begin == other.begin && end == other.end
    }
    
    @inlinable
    var str: String {
        let utf8Slice = buf[buf.index(buf.startIndex,
                                      offsetBy: Int(range.lowerBound))
                                ..<
                                buf.index(buf.startIndex,
                                          offsetBy: Int(range.upperBound))]
        return String(utf8Slice)!
    }
    
//    @inlinable
//    func rangeOf(sub: Self) -> Range {
//        assert(sub.begin >= begin)
//        assert(end >= sub.end)
//        
//        return .init(at: buf.distance(from: begin, to: sub.begin),
//                     forLength: range.count)
//    }
    
    @inlinable
    subscript(range: Range) -> Self {
        assert(count >= range.upperBound)
        let subRange = Range(at: range.offset(at: range.startIndex),
                             forLength: range.count)
        return .init(data: buf,
                     range: subRange)
    }
    
    @inlinable
    func cutOff(_ b: Self) -> Self {
        assert(isSame(b))
        return .init(data: buf,
                     range: range.startIndex..<b.range.startIndex)
    }
    
    @inlinable
    mutating func resize<B>(_ newSize: B) where B : BinaryInteger {
        range.resize(newSize)
    }
    
    @inlinable
    func forEach(_ body: (Buf.Element) throws -> Void) rethrows {
        try buf.withContiguousStorageIfAvailable {
            try $0.forEach(body)
        }
    }
    
    @inlinable
    func map<T>(_ transform: (Buf.Element) throws -> T) rethrows -> [T] {
        try buf.withContiguousStorageIfAvailable {
            try $0.map(transform)
        }!
    }
}

extension Ron.Slice : ExpressibleByStringLiteral {
    public typealias StringLiteralType = String
    
    @inlinable
    public init(stringLiteral value: String) {
        self.init(data: value)
    }
}

extension Ron.Slice : Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.count == rhs.count && lhs.buf.withContiguousStorageIfAvailable { lPtr in
            rhs.buf.withContiguousStorageIfAvailable { rPtr in
                memcmp(lPtr.baseAddress!.advanced(by: Int(lhs.begin)),
                       rPtr.baseAddress!.advanced(by: Int(rhs.begin)),
                       lhs.count) == 0
            }!
        }!
    }
}

extension Ron.Slice : Hashable {
    public func hash(into hasher: inout Hasher) {
//        let shift = 8
//        let c = count >> shift
        buf.withContiguousStorageIfAvailable { ptr in
            ptr[.init(range.lowerBound)..<(.init(range.upperBound))].withUnsafeBytes { rawPtr in
                hasher.combine(bytes: rawPtr)
            }
        }
//        static constexpr int SHIFT = sizeof(size_t) == 8 ? 3 : 2;
//        static constexpr auto SZ_HASH_FN = std::hash<size_t>{};
//        static constexpr auto CHAR_HASH_FN = std::hash<char>{};
//        size_t ret = 0;
//        fsize_t c = size() >> SHIFT;
//        auto szbuf = reinterpret_cast<const size_t*>(begin());
//        for (fsize_t i = 0; i < c; i++) {
//            ret ^= SZ_HASH_FN(szbuf[i]);
//        }
//        for (fsize_t i = c << SHIFT; i < size(); i++) {
//            ret ^= CHAR_HASH_FN(at(i));
//        }
//        return ret;
    }
}

public extension String {
    @inlinable
    func slice(from: Index,
               till: Index) -> Ron.Slice {
        assert(till >= from)
        let utf8 = self[from..<till].utf8
        assert(utf8.count <= Ron.FSize.upperbound)
        return .init(buf: utf8,
                     size: utf8.count)
    }
    
    @inlinable
    var slice: Ron.Slice {
        let utf8 = dropFirst(0).utf8
        return .init(buf: utf8,
                     size: utf8.count)
    }
}

extension Ron.FSize {
    @usableFromInline
    static let upperbound: Self = 1 << 30
    
    @usableFromInline
    static let bits = upperbound - 1
}
