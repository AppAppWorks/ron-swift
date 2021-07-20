//
//  File.swift
//  
//
//  Created by Lau Chun Kai on 7/7/2021.
//

import Foundation

public struct Uuid {
    public var value: String
    public var origin: String
    public var sep: String
    
    static var reOffset = 0
    
    public init(value: String, origin: String, sep: String? = nil) {
        self.value = value
        self.origin = origin
        self.sep = sep ?? "-"
    }
}

public extension Uuid {
    static let zero = Self(value: "0", origin: "0")
    static let never = Self(value: "~", origin: "0")
    static let comment = never
    static let error = Self(value: "~~~~~~~~~~", origin: "0")
    static let re = grammar.uuid
    static let prefixes = Array("([{}])")
    static let timeConst: Set = [ "0", "~", "~~~~~~~~~~", ]
    static let local = "~local"
    
    static let base64 = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ_abcdefghijklmnopqrstuvwxyz~".utf8CString
    static let codes: [Int8] = {
        var codes = [Int8](repeating: -1,
                           count: 128)
        base64
            .dropLast()
            .enumerated()
            .forEach { idx, char in
                codes[Int(char)] = Int8(idx)
            }
        return codes
    }()

    
    static func unzip64(zip: String, ctx: String) -> String {
        guard !zip.isEmpty else { return ctx }
        var ret = zip
        if let prefix = prefixes.firstIndex(of: ret.first!) {
            let pre = ctx.prefix(prefix + 4)
            let pre2 = pre.padding(toLength: max(pre.count, prefix + 4),
                                   withPad: "0",
                                   startingAt: 0)
            ret = "\(pre2)\(ret.dropFirst())"
        }
        if let idx = (ret.lastIndex { $0 != "0" }) {
            return String(ret[...idx])
        } else {
            return String(ret.first!)
        }
    }
    
    // overflows js ints!
    static func base2int(base: String) -> Int {
        var ret = 0
        var i = 0
        let base = base.utf8CString.dropLast()
        while i < base.count {
            ret <<= 6
            ret |= Int(codes[Int(base[i])])
            i += 1
        }
        while i < 10 {
            ret <<= 6
            i += 1
        }
        return ret
    }
    
    var isZero: Bool {
        value == "0"
    }
    
    var isTime: Bool {
        sep == "-" || sep == "+"
    }
    
    var isEvent: Bool {
        sep == "-"
    }
    
    var isDerived: Bool {
        sep == "+"
    }
    
    var isHash: Bool {
        sep == "%"
    }
    
    var isName: Bool {
        sep == "$"
    }
    
    var isLocal: Bool {
        origin == Self.local
    }
    
    var local: Self {
        Self(value: value, origin: Self.local, sep: sep)
    }
    
    var isError: Bool {
        value == "~~~~~~~~~~" || origin == "~~~~~~~~~~"
    }
    
    static func fromString(_ string: String, ctx: Self? = nil, offset: Int? = nil) -> Self {
        let ctx = ctx ?? zero
        guard !string.isEmpty else {
            return ctx
        }
        reOffset = offset ?? 0
        guard let match = re.firstMatch(in: string,
                                        range: .init(location: reOffset,
                                                     length: string.utf16.count - reOffset))
        else {
            reOffset = 0
            return error
        }
        reOffset = match.range.location + match.range.length
        let ms = match.substrings(fromString: string)
        let m1 = String(ms[1])
        let time = unzip64(zip: m1,
                           ctx: ctx.value)
        switch (m1, String(ms[2]), String(ms[3])) {
        case (time, "", "") where !timeConst.contains(time):
            return Self(value: time,
                        origin: "0",
                        sep: "$")
        case ("", "", ""):
            return ctx
        case let (_, m2, m3):
            let orig = unzip64(zip: m3,
                               ctx: ctx.origin)
            return Self(value: time,
                        origin: orig,
                        sep: m2.isEmpty ? ctx.sep : m2)
        }
    }
    
    func zip64(ctx: Self, keyPath: KeyPath<Self, String>) -> String {
        let int = self[keyPath: keyPath]
        let ctx = ctx[keyPath: keyPath]
        
        guard int != ctx else { return "" }
        var p = zip(int, ctx).prefix(while: ==).count
        if p == ctx.count {
            p += int.dropFirst(p).prefix { $0 == "0" }.count
        }
        guard p >= 4 else { return int }
        let ret = "\(Self.prefixes[p - 4])\(int.dropFirst(p))"
        return ret
    }
    
    func toJson() -> String {
        toString()
    }
    
    func toString(ctx: Self? = nil) -> String {
        if origin == "0" {
            switch (Self.timeConst.contains(value), sep) {
            case (true, "-"), (false, "$"):
                return value
            case _: break
            }
        }
        let ctx = ctx ?? Self.zero
        if origin == ctx.origin {
            guard value != ctx.value else {
                return sep == ctx.sep ? "" : sep
            }
            let zip = zip64(ctx: ctx,
                            keyPath: \.value)
            let expSep = zip == value ? "$" : "-"
            return expSep == sep ? zip : zip + sep
        } else {
            let time = zip64(ctx: ctx,
                             keyPath: \.value)
            let orig = zip64(ctx: ctx,
                             keyPath: \.origin)
            if sep != "-" || orig == origin {
                return time + sep + orig
            } else {
                return time.isEmpty ? sep + orig : time + sep + orig
            }
        }
    }
}

extension Uuid : Equatable {}
extension Uuid : Comparable {
    public static func < (lhs: Self, rhs: Self) -> Bool {
        if lhs.value == rhs.value {
            return lhs.origin < rhs.origin
        } else {
            return lhs.value < rhs.value
        }
    }
    
    public static func > (lhs: Self, rhs: Self) -> Bool {
        if rhs.value == lhs.value {
            return rhs.origin < lhs.origin
        } else {
            return rhs.value < lhs.value
        }
    }
    
    public func compare(_ other: Self) -> ComparisonResult {
        self == other
            ? .orderedSame
            : self < other ? .orderedAscending : .orderedDescending
    }
}

public struct Vector {
    var body: String
    var defaultUuid: Uuid
    var last: Uuid
    
    public init(uuids: String = "", defaultUuid: Uuid? = .zero) {
        body = uuids
        self.defaultUuid = defaultUuid ?? .zero
        last = self.defaultUuid
    }
}

public extension Vector {
    func toString() -> String {
        body
    }
    
    mutating func append(_ newUuid: Uuid) {
        let str = newUuid.toString(ctx: last)
        if !body.isEmpty {
            body += ","
        }
        body += str
        last = newUuid
    }
    
    mutating func append(_ newUuidString: String) {
        append(.fromString(newUuidString))
    }
}

extension Vector : Sequence {
    public struct Iter : IteratorProtocol {
        var body: String
        var offset = 0
        var uuid: Uuid?
        
        init(body: String = "", defaultUuid: Uuid = .zero) {
            self.body = body
            uuid = defaultUuid
            nextUuid()
        }
        
        func toString() -> String {
            .init(body.dropFirst(offset))
        }
        
        mutating func nextUuid() {
            if offset == body.count {
                uuid = nil
            } else {
                uuid = .fromString(body,
                                   ctx: uuid,
                                   offset: offset)
                if Uuid.reOffset == 0 && offset != 0 {
                    offset = body.count
                } else {
                    offset = Uuid.reOffset
                }
                let index = body.index(body.startIndex,
                                       offsetBy: offset)
                if index < body.endIndex && body[index] == "," {
                    offset += 1
                }
            }
        }
        
        public mutating func next() -> Uuid? {
            guard let ret = uuid else { return nil }
            nextUuid()
            return ret
        }
    }
    
    public func makeIterator() -> Iter {
        .init(body: body,
              defaultUuid: defaultUuid)
    }
}

extension NSTextCheckingResult {
    func substring(at index: Int, fromString string: String) -> Substring {
        guard let strRange = Range(range(at: index), in: string) else { return "" }
        return string[strRange]
    }
    
    func substrings(fromString string: String) -> [Substring] {
        (0..<numberOfRanges).map { substring(at: $0, fromString: string) }
    }
}
