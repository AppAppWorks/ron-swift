//
//  Uuid.swift
//  
//
//  Created by Lau Chun Kai on 21/7/2021.
//

import Foundation

/**
 A 128-bit representation of a RON atom.
 
 Bit layouts:
 1. UUID - all 128 bits are UUID in the RON layout; origin m.s.bits are 00.
    Empty state: NIL UUID.
 2. INT - value is an int64_t, origin is the buffer range for the serialized
 value. Origin msb are 01. In the empty state, the value is 0 (there is no other
 indication, so the user must know from the context whether the cursor is
 empty).
 3. STRING - a codepoint cursor,
    * value's m.s.half is the offset for the *remaining* string,
    * value's l.s.half is the codepoint,
    * origin is the *remaining* buffer range,
    * origin msb are 10.
    A STRING atom has two empty states: before the beginning (BTB) and after the
 end (ATE). To have the entire original byte range, one needs a BTB cursor. The
 codepoint value is 0 in either of the empty states. Otherwise, 0 is a forbidden
 value. In the ATE state, cp offset is 0, cp is 0, so value is 0, and the range
 is empty (begin==end). For an empty string, BTB==ATE.
 4. FLOAT - value is a 64-bit ISO float, origin is a range, origin m.s.bits
 are 11.
 */
public protocol RonAtom {
    typealias Word = Ron.Word
    typealias Codepoint = Ron.Codepoint
    typealias Range = Ron.Range
    typealias FSize = Ron.FSize
    
    var value: Word { get set }
    
    var origin: Word { get set }
    
    init(value: Word,
         origin: Word)
    
    init()
    
    init(value: UInt64,
         origin: UInt64)
    
    static func string(cp: Codepoint,
                       range: Range,
                       cpSize: FSize) -> Self
    
    static func integer(i: Int,
                        range: Range) -> Self
    
    static func float(value: Double,
                      range: Range) -> Self
    
    init(type: Ron.Atom.Kind,
         range: Range)
    
    var type: Ron.Atom.Kind { get }
    
    var safeOrigin: Word { get }
}

public extension RonAtom {
    @inlinable
    init() {
        self.init(value: .zero,
                  origin: .zero)
    }
    
    @inlinable
    init(value: UInt64,
         origin: UInt64) {
        self.init(value: .init(value),
                  origin: .init(origin))
    }
    
    @inlinable
    static func string(cp: Codepoint,
                       range: Range = 0..<0,
                       cpSize: FSize) -> Self {
        .init(value: .init(higher: cpSize,
                           lower: cp),
              origin: .init(range: range) | Ron.Atom.Flags.string)
    }
    
    @inlinable
    static func integer(i: Int,
                       range: Range = 0..<0) -> Self {
        .init(value: .init(i),
              origin: .init(range: range) | Ron.Atom.Flags.int)
    }
    
    @inlinable
    static func float(value: Double,
                      range: Range = 0..<0) -> Self {
        .init(value: .init(value),
              origin: .init(range: range) | Ron.Atom.Flags.float)
    }
    
    @inlinable
    init(type: Ron.Atom.Kind,
         range: Range) {
        self.init(value: .zero,
                  origin: .init(range: range) | (UInt64(type.rawValue) << 62))
    }
    
    @inlinable
    var type: Ron.Atom.Kind {
        .init(rawValue: .init(origin.u64 >> 62))!
    }
    
    @inlinable
    var safeOrigin: Word {
        let mask = (UInt64(FSize.bits) << 32) | UInt64(FSize.bits)
        return .init(origin.u64 & mask)
    }
    
    @inlinable
    var isStringBtB: Bool {
        assert(type == .string)
        return value.struct.cp == 0
    }
    
    @inlinable
    var stringSize: FSize {
        isStringBtB ? value.struct.cpSize : value.struct.cpSize + 1
    }
}

@inlinable
public func == (lhs: RonAtom, rhs: RonAtom) -> Bool {
    lhs.value == rhs.value && lhs.origin == rhs.origin
}

@inlinable
func += (lhs: inout RonAtom, rhs: UInt64) {
    lhs.value += rhs
}

public extension Ron {
    enum Case : UInt8 {
        case numeric
        case snake
        case caps
        case camel
        
        public init(_ v: UInt64) {
            let capsMask: UInt64 = ((1 << 36) - (1 << 10)) | (1 << 63)
            let snakeMask: UInt64 = ((1 << 63) - (1 << 36))
            let idx = v & 63
            let rw = ((((capsMask >> idx) & 1) << 1) | ((snakeMask >> idx) & 1))
            self.init(rawValue: UInt8(rw))!
        }
        
        public static func | (lhs: Self, rhs: UInt64) -> Self? {
            .init(rawValue: lhs.rawValue | Self(rhs).rawValue)
        }
    }
    
    struct Word {
        @usableFromInline
        static let abc = [
            255 as UInt8, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255,
            255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255,
            255, 255, 255, 2,   255, 1,   0,   1,   255, 2,   0,   5,   0,   2,   1,
            3,   0,   255, 0,   1,   2,   3,   4,   5,   6,   7,   8,   9,   3,   0,
            255, 1,   0,   3,   2,   10,  11,  12,  13,  14,  15,  16,  17,  18,  19,
            20,  21,  22,  23,  24,  25,  26,  27,  28,  29,  30,  31,  32,  33,  34,
            35,  1,   255, 4,   3,   36,  0,   37,  38,  39,  40,  41,  42,  43,  44,
            45,  46,  47,  48,  49,  50,  51,  52,  53,  54,  55,  56,  57,  58,  59,
            60,  61,  62,  2,   255, 3,   63,  255
        ].createBufferPointer()!
        
        @usableFromInline
        var base: UInt64
        
        @usableFromInline
        func recast<T>() -> T {
            withUnsafeBytes(of: base) { ptr in
                ptr.bindMemory(to: T.self).baseAddress!.pointee
            }
        }
        
        @usableFromInline
        static func castToBase<T>(_ input: T) -> UInt64 {
            withUnsafeBytes(of: input) { ptr in
                ptr.bindMemory(to: UInt64.self).baseAddress!.pointee
            }
        }
    }
    
    struct Atom : RonAtom {
        public var value: Word
        
        public var origin: Word
        
        @inlinable
        public init(value: Word, origin: Word) {
            self.value = value
            self.origin = origin
        }
    }
    
    struct UUID : RonAtom, Hashable {
        public var value: Word
        
        public var origin: Word
        
        @inlinable
        public init(value: Word, origin: Word) {
            self.value = value
            self.origin = origin
        }
    }
    
    typealias Spec = (UUID, UUID)
    typealias Atoms = [RonAtom]
    typealias UUIDs = [UUID]
    typealias Codepoints = [Codepoint]
    
    typealias Result = Word
    
    static let opIdIdx: UInt32 = 0
    static let opRefIdx: UInt32 = 1
}

public extension Ron.Result {
    static let ok: Self = "0"
    static let endOfInput: Self = "ENDOFINPUT"
    static let notImplemented: Self = "NOTIMPLITED"
    static let badSyntax: Self = "BADSYNTAX"
    static let outOfRange: Self = "OUTOFRANGE"
}

public extension Ron.Word {
    @inlinable
    @inline(__always)
    var u64: UInt64 {
        base
    }
    
    @inlinable
    @inline(__always)
    var u32: (UInt32, UInt32) {
        (.init(base & ((1 << 32) - 1)), .init(base >> 32))
    }
    
    @inlinable
    @inline(__always)
    var u8: (UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8) {
        (
            .init(base & 0xff),
            .init((base >> 8) & 0xff),
            .init((base >> 16) & 0xff),
            .init((base >> 24) & 0xff),
            .init((base >> 32) & 0xff),
            .init((base >> 40) & 0xff),
            .init((base >> 48) & 0xff),
            .init((base >> 56) & 0xff)
        )
    }
    
    @inlinable
    @inline(__always)
    var integer: Int {
        get {
            recast()
        }
        set {
            base = Self.castToBase(newValue)
        }
    }
    
    @inlinable
    @inline(__always)
    var float: Double {
        get {
            recast()
        }
        set {
            base = Self.castToBase(newValue)
        }
    }
    
    @inlinable
    @inline(__always)
    var codepoint: (Ron.Codepoint, Ron.Codepoint) {
        (.init(base & ((1 << 32) - 1)), .init(base >> 32))
    }
    
    @inlinable
    @inline(__always)
    var range: Ron.Range {
        get {
            (.init(base & ((1 << 32) - 1))..<(.init(base >> 32)))
        }
        set {
            base = .init(newValue.lowerBound) | (.init(newValue.upperBound) << 32)
        }
    }
    
    @inlinable
    @inline(__always)
    var str: String {
        base64
    }
    
    @inlinable
    @inline(__always)
    var size: (Ron.FSize, Ron.FSize) {
        (.init(base & ((1 << 32) - 1)), .init(base >> 32))
    }
    
    @inlinable
    @inline(__always)
    var `struct`: (cp: Ron.Codepoint, cpSize: Ron.FSize) {
        (.init(base & ((1 << 32) - 1)), .init(base >> 32))
    }
    
    @inlinable
    @inline(__always)
    var cp: Ron.Codepoint {
        get {
            .init(base & ((1 << 32) - 1))
        }
        set {
            base = .init(newValue) | (.init(cpSize) << 32)
        }
    }
    
    @inlinable
    @inline(__always)
    var cpSize: Ron.Codepoint {
        get {
            .init(base >> 32)
        }
        set {
            base = .init(cp) | (.init(newValue) << 32)
        }
    }
    
    @inlinable
    init(_ val: UInt64 = 0) {
        base = val
    }
    
    @inlinable
    init(_ val: Double) {
        base = Self.castToBase(val)
    }
    
    @inlinable
    init(_ val: Int) {
        base = Self.castToBase(val)
    }
}

extension Ron.Word : ExpressibleByIntegerLiteral {
    public typealias IntegerLiteralType = UInt64
    
    @inlinable
    public init(integerLiteral value: UInt64) {
        base = value
    }
}

extension Ron.Word : ExpressibleByStringLiteral {
    public typealias StringLiteralType = String
    
    @inlinable
    public init(stringLiteral value: String) {
        self.init(word: value)
    }
}

public extension Ron.Word {
    //// payload bit size
    static let pbs: UInt32 = 60
    static let base64Bits: UInt32 = 6
    static let base64WordCount = pbs / base64Bits
    // max base64 char size
    static let maxBase64Count = pbs / base64Bits
    static let maxValue: UInt64 = (1 << pbs) - 1
    static let offset6: [UInt8] = [
        .init(pbs) - (6 * 1),
        .init(pbs) - (6 * 2),
        .init(pbs) - (6 * 3),
        .init(pbs) - (6 * 4),
        .init(pbs) - (6 * 5),
        .init(pbs) - (6 * 6),
        .init(pbs) - (6 * 7),
        .init(pbs) - (6 * 8),
        .init(pbs) - (6 * 9),
        .init(pbs) - (6 * 10)
    ]
    static let payloadBits: UInt64 = (1 << pbs) - 1
    static let flatBits = .max - payloadBits
    static let lower6: [UInt64] = [
        (1 << (pbs - 0 * 6)) - 1,
        (1 << (pbs - 1 * 6)) - 1,
        (1 << (pbs - 2 * 6)) - 1,
        (1 << (pbs - 3 * 6)) - 1,
        (1 << (pbs - 4 * 6)) - 1,
        (1 << (pbs - 5 * 6)) - 1,
        (1 << (pbs - 6 * 6)) - 1,
        (1 << (pbs - 7 * 6)) - 1,
        (1 << (pbs - 8 * 6)) - 1,
        (1 << (pbs - 9 * 6)) - 1,
        0
    ]
    
    @inlinable
    init(higher: UInt32, lower: UInt32) {
        base = (UInt64(higher) << 32) | UInt64(lower)
    }
    
    /** A trusty parsing constructor; expects a valid Base64x64 value. */
    @inlinable
    init(flags: UInt8,
         data: Ron.Slice) {
        base = .init(flags & 0xf)
        assert(data.count <= Self.maxBase64Count)
        for i in data.range {
            base <<= Self.base64Bits
            base |= .init(Self.abc[.init(data[i])])
        }
        guard data.count < Self.maxBase64Count else {
            return
        }
        for _ in .init(data.count)..<Self.maxBase64Count {
            base <<= Self.base64Bits
        }
    }
    
    @inlinable
    init(word: String) {
        self.init(flags: 0,
                  data: .init(data: word))
    }
    
    @inlinable
    init(range: Ron.Range) {
        base = (.init(range.upperBound) << 32) | .init(range.lowerBound)
    }
    
    @inlinable
    var flags: UInt8 {
        .init(base >> 60)
    }
    
    @inlinable
    mutating func zero() {
        base = 0
    }
    
    @inlinable
    var payload: UInt64 {
        base & Self.maxValue
    }
    
    @inlinable
    var isZero: Bool {
        base == 0
    }

    @inlinable
    static func + (lhs: Self, rhs: UInt64) -> Self {
        .init(lhs.base + .init(rhs))
    }
    
    @inlinable
    static func + (lhs: Self, rhs: Self) -> Self {
        .init(lhs.base + rhs.base)
    }
    
    @inlinable
    static func += (lhs: inout Self, rhs: UInt64) {
        lhs.base += rhs
    }
    
    @inlinable
    static func += (lhs: inout Self, rhs: Self) {
        lhs.base += rhs.base
    }
    
    @inlinable
    static func | (lhs: Self, rhs: UInt64) -> Self {
        .init(lhs.base | rhs)
    }
    
    @inlinable
    static func |= (lhs: inout Self, rhs: UInt64) {
        lhs.base |= rhs
    }
    
    @inlinable
    static func & (lhs: Self, rhs: UInt64) -> Self {
        .init(lhs.base & rhs)
    }
    
    @inlinable
    static func &= (lhs: inout Self, rhs: UInt64) {
        lhs.base &= rhs
    }
    
    @inlinable
    static func random() -> Self {
        var i = UInt64(arc4random())
        i <<= 30
        i ^= .init(arc4random())
        return .init(i & maxValue)
    }
    
    @inlinable
    var isAllDigits: Bool {
        var len = 0
        repeat {
            let next = Ron.basePunct[Int(0x3f) & Int(u64 >> Self.offset6[len])]
            guard "0"..."9" ~= next else {
                return false
            }
            len += 1
        } while (u64 & Self.lower6[len]) != 0
        return true
    }
    
    @inlinable
    var base64Case: Ron.Case {
        var ret = Ron.Case.numeric
        var u = u64
        var i = 0
        while i < 10 && u != 3 {
            ret = (ret | u)!
            i += 1
            u >>= 6
        }
        return ret
    }
    
    static let never = Self(UInt64(63) << 54)
    static let zero: Self = 0
    
    @inline(__always)
    @usableFromInline
    internal func getBase64InBytes<T>(_ body: (UnsafeBufferPointer<UInt8>) -> T) -> T {
        UnsafeMutableBufferPointer<UInt8>.transient(capacity: Int(Self.base64WordCount)) { bytes in
            var ptr = bytes.baseAddress!
            
            for len in 0... {
                ptr.append(Ron.basePunct[Int(0x3f & (u64 >> Self.offset6[len]))])
                
                if u64 & Self.lower6[len + 1] == 0 {
                    break
                }
            }
            return body(.init(rebasing: bytes.prefix(ptr)))
        }
    }
    
    @inline(__always)
    @inlinable
    var base64: String {
        getBase64InBytes {
            .init(bytes: $0,
                  encoding: .utf8)!
        }
    }
}

extension Ron.Word : Equatable {}
extension Ron.Word : Comparable {
    public static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.base < rhs.base
    }
}
extension Ron.Word : Hashable {}

public extension Ron.Atom {
    @usableFromInline
    internal static let punct = ">='^".utf8.createBufferPointer()!
    
    enum Kind : Int {
        case uuid
        case int
        case string
        case float
        
        public static let buf = uuid
        
        @inlinable
        public var punct: UInt8 {
            Ron.Atom.punct[rawValue]
        }
    }
    
    enum Flags {
        public static let uuid = UInt64(Kind.uuid.rawValue) << 62
        public static let int = UInt64(Kind.int.rawValue) << 62
        public static let string = UInt64(Kind.string.rawValue) << 62
        public static let float = UInt64(Kind.float.rawValue) << 62
    }
}

extension Ron.Atom : Equatable {}

public extension Ron.UUID {
    typealias Slice = Ron.Slice
    typealias Word = Ron.Word
    
    static let punct = "$%+-".utf8.createBufferPointer()!
    
    enum Kind : Int {
        case name
        case hash
        case time
        case derived
        
        @inlinable
        public var punct: UTF8Char {
            Ron.UUID.punct[rawValue]
        }
    }
    
    @inlinable
    init(variety: CChar,
         value: Slice,
         version: CChar,
         origin: Slice) {
        self.init(value: Word(flags: Word.abc[Int(variety)],
                              data: value),
                  origin: Word(flags: Word.abc[Int(version)],
                               data: origin))
    }
    
    @inlinable
    init(buf: String) {
        self.init(data: .init(data: buf))
    }
    
    @inlinable
    init(a: RonAtom) {
        self.init(value: a.value,
                  origin: a.origin)
    }
    
    @inlinable
    var version: Kind {
        .init(rawValue: .init(origin.flags & 3))!
    }
    
    @inlinable
    var variety: UInt8 {
        value.flags
    }
    
    @inlinable
    var isZero: Bool {
        value == .zero
    }
    
    @inlinable
    var isAmbiguous: Bool {
        origin.isZero && value.isAllDigits
    }
    
    @inlinable
    var isError: Bool {
        origin.u64 == Word.maxValue
    }
    
    @inlinable
    static func time(value: Word,
                     origin: Word) -> Self {
        .init(value: value,
              origin: .init((origin.u64 & Word.payloadBits)
                                | (UInt64(Kind.time.rawValue) << Word.pbs)))
    }
    
    @inlinable
    static func derived(value: Word,
                        origin: Word) -> Self {
        .init(value: value,
              origin: .init((origin.u64 & Word.payloadBits)
                                | (UInt64(Kind.derived.rawValue) << Word.pbs)))
    }
    
    @inlinable
    var derived: Self {
        Self.derived(value: value,
                     origin: origin)
    }
    
    @inlinable
    var event: Self {
        Self.time(value: value,
                  origin: origin)
    }
    
    @inlinable
    static func + (lhs: Self, rhs: UInt64) -> Self {
        .init(value: lhs.value + rhs,
              origin: lhs.origin)
    }
    
//    @inlinable
//    static func - (lhs: Self, rhs: UInt64) -> Self {
//        .init(value: lhs.value - rhs,
//              origin: lhs.origin)
//    }
//
//    @inlinable
//    static func -= (lhs: inout Self, rhs: UInt64) {
//        lhs.value -= rhs
//    }
    
    @inlinable
    static func == (lhs: Self, rhs: String) -> Bool {
        lhs == Self(buf: rhs)
    }
    
    @inlinable
    static func += (lhs: inout Self, rhs: UInt64) {
        lhs.value += rhs
    }
    
    static let `nil` = Self(value: 0,
                            origin: 0)
    static let fatal = Self(value: Word.maxValue,
                            origin: Word.maxValue)
    static let never = time(value: .init(Word.maxValue),
                            origin: .init(Word.maxValue))
    static let comment: Self = "~"
    
    @inlinable
    static func parse(variety: CChar,
                      value: Slice,
                      version: CChar,
                      origin: Slice) -> Self {
        .init(value: .init(flags: Word.abc[Int(variety)],
                           data: value),
              origin: .init(flags: Word.abc[Int(version)],
                            data: origin))
    }
    
    @inlinable
    static func hybridTime(seconds: time_t,
                           nanos: Int) -> Word {
        let t = withUnsafePointer(to: seconds, gmtime)!.pointee
        var ret = UInt64(1900 + t.tm_year - 2010)
        ret *= 12
        ret += UInt64(t.tm_mon)
        ret <<= 6
        ret |= UInt64(t.tm_mday) - 1
        ret <<= 6
        ret |= UInt64(t.tm_hour)
        ret <<= 6
        ret |= UInt64(t.tm_min)
        ret <<= 6
        ret |= UInt64(t.tm_sec)
        ret <<= 24
        ret |= UInt64(nanos / 100)
        return .init(ret)
    }
    
    @inlinable
    static func now() -> Word {
        var tv = timeval()
        _ = gettimeofday(&tv, nil)
        return hybridTime(seconds: tv.tv_sec,
                          nanos: .init(tv.tv_usec * 1000))
    }
    
    @inlinable
    var base64: String {
        UnsafeMutableBufferPointer<UInt8>.transient(capacity: Int(Word.base64WordCount) * 2 + 2 + 1) { ret in
            let vrt = variety
            var ptr = ret.baseAddress!
            if vrt != 0 {
                ptr.append(Ron.basePunct[Int(vrt)])
                ptr.append("/")
            }
            value.getBase64InBytes { srcPtr in
                ptr.assign(from: srcPtr.baseAddress!,
                           count: srcPtr.count)
                ptr += srcPtr.count
            }
            let schm = version
            if schm != .name || !origin.isZero {
                ptr.append(schm.punct)
                origin.getBase64InBytes { srcPtr in
                    ptr.assign(from: srcPtr.baseAddress!,
                               count: srcPtr.count)
                    ptr += srcPtr.count
                }
            }
            return .init(bytes: ret.prefix(ptr),
                         encoding: .utf8)!
        }
    }
    
    @inlinable
    var str: String {
        base64
    }
}

extension Ron.UUID : ExpressibleByStringLiteral {
    public typealias StringLiteralType = String
    
    @inlinable
    public init(stringLiteral: StringLiteralType) {
        self.init(data: .init(data: stringLiteral))
    }
}

extension Ron.UUID : Comparable {
    public static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.value < rhs.value || (lhs.value == rhs.value && lhs.origin < rhs.origin)
    }
}

extension Ron {
    @usableFromInline
    static let abc64 = [
        nil as UInt8?, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,
        nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,
        nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, 0,  1,  2,  3,  4,  5,  6,  7,  8,
        9,  nil, nil, nil, nil, nil, nil, nil, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20,
        21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, nil, nil, nil, nil,
        36, nil, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53,
        54, 55, 56, 57, 58, 59, 60, 61, 62, nil, nil, nil, 63, nil, nil, nil, nil, nil, nil,
        nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,
        nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,
        nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,
        nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,
        nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,
        nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,
        nil, nil, nil, nil, nil, nil, nil, nil, nil].createBufferPointer()!

    @usableFromInline
    static let abc16 = [
        nil as UInt8?, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,
        nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,
        nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, 0,  1,  2,  3,  4,  5,  6,  7,  8,
        9,  nil, nil, nil, nil, nil, nil, nil, 10, 11, 12, 13, 14, 15, nil, nil, nil, nil, nil,
        nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,
        nil, nil, 10, 11, 12, 13, 14, 15, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,
        nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,
        nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,
        nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,
        nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,
        nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,
        nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,
        nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,
        nil, nil, nil, nil, nil, nil, nil, nil, nil].createBufferPointer()!
}
