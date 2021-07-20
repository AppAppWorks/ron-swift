import Foundation

public enum Atom {
    case removal
    case none
    case string(String)
    case int(Int)
    case double(Double)
    case bool(Bool)
    case uuid(Uuid)
    case frameAtom
    case queryAtom
    
    init?<S>(tryInt int: S) where S : StringProtocol {
        guard let int = Int(int) else { return nil }
        self = .int(int)
    }
    
    init?<S>(tryDouble double: S) where S : StringProtocol {
        guard let double = Double(double) else { return nil }
        self = .double(double)
    }
    
    var jsonValue: Any? {
        switch self {
        case let .bool(a as Any),
             let .double(a as Any),
             let .int(a as Any),
             let .string(a as Any):
            return a
        case let .uuid(uuid):
            return uuid.value
        case _: return nil
        }
    }
}

extension Atom : Equatable {}

public extension Atom {
    var uuid: Uuid? {
        if case let .uuid(uuid) = self {
            return uuid
        }
        return nil
    }
    
    var isTruthy: Bool {
        switch self {
        case .none, .removal:
            return false
        case _: return true
        }
    }
}

let trueUuid = Uuid.fromString("true")
let falseUuid = Uuid.fromString("false")
let nullUuid = Uuid.fromString("0")

public extension Dictionary where Key == String, Value == Atom {
    var jsonReadyDict: [String : Any] {
        compactMapValues(\.jsonValue)
    }
}

public extension Array where Element == Atom {
    var jsonReadyArray: [Any] {
        compactMap(\.jsonValue)
    }
}

/// A RON op object. Typically, an Op is hosted in a frame.
/// Frames are strings, so Op is sort of a Frame iterator.
public struct Op {
    public var type: Uuid
    public var object: Uuid
    public var event: Uuid
    public var location: Uuid
    
    public var values: String
    var parsedValues: [Atom]?
    
    var term: String
    var source: String?
    
    static var reOffset = 0
}

public extension Op {
    static let re = grammar.op
    static let valueRe = grammar.atom
    static let zero = Self(type: .zero,
                           object: .zero,
                           event: .zero,
                           location: .zero,
                           values: ">0")

    static let end = Self(type: .error,
                          object: .error,
                          event: .error,
                          location: .error,
                          values: ">~")
    static let parseError = Self(type: .error,
                                 object: .error,
                                 event: .error,
                                 location: .error,
                                 values: ">parseerror")
    static let redefSeps = "`"
    static let uuidSeps = Array("*#@:")
    
    struct Sep {
        public static let intAtom = "="
        public static let floatAtom = "^"
        public static let uuidAtom = ">"
        public static let frame = "!"
        public static let query = "?"
    }
    
    enum UuidIndex : Int, CaseIterable {
        case zero = 0
        case one
        case two
        case three
    }
    
    init(
        type: Uuid,
        object: Uuid,
        event: Uuid,
        location: Uuid,
        values: String? = nil,
        term: String? = nil
    ) {
        self.type = type
        self.object = object
        self.event = event
        self.location = location
        self.values = values ?? ""
        
        self.term = term ?? ";"
    }
    
    mutating func value(_ index: Int) -> Atom {
        if parsedValues == nil {
            parsedValues = values.ronToJs
        }
        return parsedValues!.count <= index ? .removal : parsedValues![index]
    }
    
    var isHeader: Bool {
        term == "!"
    }
    
    var isQuery: Bool {
        term == "?"
    }
    
    var isRegular: Bool {
        !isHeader && !isQuery
    }
    
    var isError: Bool {
        event.value == Uuid.error.value
    }
    
    var isComment: Bool {
        type == .comment
    }
    
    /// Get op UUID by index (0-3)
    func uuid(_ index: UuidIndex) -> Uuid {
        switch index {
        case .zero: return type
        case .one: return object
        case .two: return event
        case .three: return location
        }
    }
    
    var key: String {
        "*\(type.value)#\(object.value)"
    }
    
    func toString(ctx: Self? = nil) -> String {
        var ret = ""
        let ctx = ctx ?? .zero
        let expComma = ctx.term != ";"
        
        for u in UuidIndex.allCases {
            let uuid = self.uuid(u)
            let same = ctx.uuid(u)
            if uuid == same {
                continue
            }
            let str = uuid.toString(ctx: same)
            ret.append(Self.uuidSeps[u.rawValue])
            ret += str
        }
        
        ret += values
        if values.isEmpty || (expComma && term != ",") || (!expComma && term != ";") {
            ret += term
        }
        return ret
    }
    
    init?(body: String, context: Self? = nil, offset: Int? = nil) {
        var ctx = context ?? .zero
        Self.reOffset = offset ?? 0
        guard let match =
                Self.re.firstMatch(in: body,
                                   range: .init(location: Self.reOffset,
                                                length: body.utf16.count - Self.reOffset))
        else {
            Self.reOffset = 0
            return nil
        }
        Self.reOffset = match.range.location + match.range.length
        let substrings = match.substrings(fromString: body)
        guard !substrings[0].isEmpty
                && substrings[0].endIndex.utf16Offset(in: body) == Self.reOffset else {
            return nil
        }
        if substrings[1] == Uuid.comment.value {
            ctx = .zero
        }
        let term = substrings.count >= 6 && !substrings[6].isEmpty
            ? String(substrings[6])
            : ctx.term == "!" ? "," : ctx.term
        
        self.init(type: .fromString(String(substrings[1]),
                                    ctx: ctx.type),
                  object: .fromString(String(substrings[2]),
                                      ctx: ctx.object),
                  event: .fromString(String(substrings[3]),
                                     ctx: ctx.event),
                  location: .fromString(String(substrings[4]),
                                        ctx: ctx.location),
                  values: String(substrings[5]),
                  term: term)
        source = String(substrings[0])
    }
}

public extension String {
    static var valueReOffset = 0
    
    /// Parse RON value atoms.
    var ronToJs: [Atom] {
        Self.valueReOffset = 0
        let utf16Length = utf16.count
        var ret = [Atom]()
        
        while let m =
                Op.valueRe.firstMatch(in: self,
                                      range: .init(location: Self.valueReOffset,
                                                   length: utf16Length - Self.valueReOffset)) {
            let substrings = m.substrings(fromString: self)
            
            Self.valueReOffset = m.range.location + m.range.length
            
            switch substrings.count {
            case 2... where !substrings[1].isEmpty:
                ret.append(.init(tryInt: substrings[1])!)
            case 3... where !substrings[2].isEmpty:
                //                ret.push(JSON.parse('"' + m[2] + '"')); // VALUE_RE returns match w/o single quotes
                ret.append(.string(try! JSONSerialization.jsonObject(with: #""\#(substrings[2])""#.data(using: .utf8)!,
                                                                     options: .fragmentsAllowed) as! String))
            case 4... where !substrings[3].isEmpty:
                ret.append(.init(tryDouble: substrings[3])!)
            case 5...:
                switch substrings[4] {
                case trueUuid.value:
                    ret.append(.bool(true))
                case falseUuid.value:
                    ret.append(.bool(false))
                case nullUuid.value:
                    ret.append(.none)
                case let m4 where !m4.isEmpty:
                    ret.append(.uuid(.fromString(String(m4))))
                case _: break
                }
            case _: break
            }
        }
        
        return ret
    }
    
    /// Serialize JS primitives into RON atoms.
    init(jsValues: [Atom]) {
        self.init()
        self = jsValues.map { v -> String in
            guard v != .removal else {
                return Op.Sep.uuidAtom + Uuid.zero.toString()
            }
            guard v != .none else {
                return Op.Sep.uuidAtom + nullUuid.toString()
            }
            
            switch v {
            case let .string(s):
                let jsonData = try! JSONSerialization.data(withJSONObject: s,
                                                           options: .fragmentsAllowed)
                let json = String(data: jsonData,
                                  encoding: .utf8)!
                let escq = json.replacingOccurrences(of: "'",
                                                     with: "\u{0027}")
                return "'\(escq.dropFirst().dropLast())'"
            case let .int(i):
                return "\(Op.Sep.intAtom)\(i)"
            case let .double(d):
                return "\(Op.Sep.floatAtom)\(d)"
            case let .uuid(u):
                return Op.Sep.uuidAtom + u.toString()
            case let .bool(b):
                return Op.Sep.uuidAtom + (b ? trueUuid : falseUuid).toString()
            case .frameAtom:
                return Op.Sep.frame
            case .queryAtom:
                return Op.Sep.query
            case _: fatalError("unsupported type")
            }
        }.joined()
    }
    
    /// Substitute UUIDs in all of the frame's ops.
    /// Typically used for macro expansion.
    init(rawFrame: String, uuidMapper: (Uuid, Int, Int, Op) -> Uuid?) {
        self.init()
        var ret = Frame()
        var index = -1
        
        for op in Frame(str: rawFrame) {
            index += 1
            ret.append(.init(
                type: uuidMapper(op.type, 0, index, op) ?? op.type,
                object: uuidMapper(op.object, 1, index, op) ?? op.object,
                event: uuidMapper(op.event, 2, index, op) ?? op.event,
                location: uuidMapper(op.location, 3, index, op) ?? op.location,
                values: op.values,
                term: op.term
            ))
        }
        
        self = ret.toString()
    }
}

public struct Frame {
    public var body: String
    public internal(set) var last: Op
}

public extension Frame {
    enum Term : String {
        case comma = ","
        case frame = "!"
        case query = "?"
        case colon = ";"
    }
    
    init(str: String? = nil) {
        body = str ?? ""
        last = .zero
    }
    
    mutating func append(_ op: Op, term: Term? = nil) {
        if last.isComment {
            last = .zero
        }
        
        var op = op
        if let term = term {
            op.term = term.rawValue
        }
        
        body += op.toString(ctx: last)
        last = op
    }
    
    func toString() -> String {
        body
    }
    
    mutating func mapUuids(_ mapper: (Uuid, Int, Int, Op) -> Uuid?) {
        body = .init(rawFrame: body,
                     uuidMapper: mapper)
        for op in self {
            last = op
        }
    }
    
    var isFullState: Bool {
        for op in self {
            return op.isHeader && op.uuid(.three).isZero
        }
        return false
    }
    
    var isPayload: Bool {
        contains(where: \.isRegular)
    }
    
    var id: Uuid {
        first { _ in true }.flatMap { $0.uuid(.one) } ?? .zero
    }
    
    var unzip: [Op] {
        Array(self)
    }
}

extension Frame : Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        if lhs.toString() == rhs.toString() {
            return true
        }
        var cursor = Cursor(body: rhs.toString())
        for op in lhs {
            let oop = cursor.op
            if oop == nil || op != oop {
                return false
            }
            _ = cursor.next()
        }
        return cursor.next() == nil
    }
}

extension Frame : Comparable {
    public static func < (lhs: Self, rhs: Self) -> Bool {
        guard let aop = Op(body: lhs.body),
              let bop = Op(body: rhs.body)
        else { return false }
        return aop.uuid(.two) < bop.uuid(.two)
    }
}

public extension Frame {
    struct Cursor : IteratorProtocol {
        var body: String
        var offset: Int
        var length: Int
        public var op: Op?
        var ctx: Op?
        
        mutating func nextOp() -> Op? {
            offset += length
            if offset == body.count {
                op = nil
                length = 1
            } else {
                let op = Op(body: body,
                            context: ctx,
                            offset: offset)
                ctx = op
                if let op = op {
                    if op.isComment {
                        ctx = .zero
                    }
                    if let source = op.source, !source.isEmpty {
                        length = source.count
                    }
                }
                self.op = op
            }
            return op
        }
    }
}

public extension Frame.Cursor {
    enum Error : Swift.Error {
        case differentFrames
    }
    
    init(body: String? = nil) {
        self.body = body.map { $0.trimmingCharacters(in: .whitespaces) } ?? ""
        offset = 0
        length = 0
        op = nextOp()
    }
    
    func toString() -> String {
        body
    }
    
    var eof: Bool {
        op == nil
    }
    
    mutating func next() -> Op? {
        guard let ret = op else { return nil }
        _ = nextOp()
        return ret
    }
    
    func slice(till: Self) throws -> String {
        guard let fromOp = op else { return "" }
        guard body == till.body else {
            throw Error.differentFrames
        }
        var ret = fromOp.toString()
        let firstPart = body.dropFirst(offset + length)
        ret += till.op.map { _ in firstPart.prefix(body.count - till.offset + 1) } ?? firstPart
        return ret
    }
}

extension Frame : Sequence {
    public func makeIterator() -> Cursor {
        .init(body: body)
    }
}

extension Op : Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.uuid(.zero) == rhs.uuid(.zero)
            && lhs.uuid(.one) == rhs.uuid(.one)
            && lhs.uuid(.two) == rhs.uuid(.two)
            && lhs.uuid(.three) == rhs.uuid(.three)
            && lhs.values == rhs.values
            && lhs.term == rhs.term
    }
}
