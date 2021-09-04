public extension Ron {
    struct TextFrame {
        public var data: String

        @inlinable
        public init(data: String) {
            self.data = data
        }
    }
}

public extension Ron.Slice {
    static let maxInStr = "9223372036854775807".utf8
    
    @inlinable
    var intTooBig: Bool {
        guard count >= 19 else {
           return false
        }
        
        var mem = begin
        var sz = count
        if self[begin] == "-" || self[begin] == "+" {
            mem += 1
            sz -= 1
        }
        guard sz <= 19 else {
            return true
        }
        
        return isGreater(range: mem..<(mem + .init(sz)),
                         other: Self.maxInStr)
    }
    
    @inlinable
    var wordTooBig: Bool {
        count > Ron.Word.maxBase64Count
    }
}

// MARK: - Parsing
public extension Ron.TextFrame {
    @inlinable
    init() {
        data = ""
    }
    
    @inlinable
    init(data: Ron.Slice) {
        self.data = data.str
    }
    
    struct Cursor : RonTextFrameCursor {
        /** Frame data; the cursor does not own the memory */
        public var data: Ron.Slice // 16 remaining data, base for ranges
        public var op: Ron.Atoms // 24
        /** The op's term is basically a form of punctuation in a frame.
                    See enum TERM. */
        public var term: Ron.Term = .raw // 1
        @usableFromInline
        var ragelState: UInt8 // 1
        @usableFromInline
        var line: Ron.FSize // 4
        @usableFromInline
        var spanSize: Ron.FSize // 4
        // 50 bytes total
    }
    
    @inlinable
    var cursor: Cursor {
        .init(host: self)
    }
    
    static let esc: UInt8 = "\\"
    
    typealias Cursors = [Cursor]
    
    @inlinable
    mutating func split(to: inout [Self]) -> Ron.Status {
        let d = data
        let s = d.endIndex
        var pos = d.startIndex
        repeat {
            let at = d[pos...]
                .indices
                .first {
                    d[$0...].hasPrefix(Ron.frameTerm)
                }
                .map { d.index($0, offsetBy: 2) }
                ?? s
            to.append(.init(data: String(d[pos..<at])))
            pos = at
            pos = d[pos...]
                .firstIndex { !$0.isWhitespace }
                ?? pos
        } while pos < s
        return .ok
    }
    
    @inlinable
    mutating func removeAll() {
        data.removeAll()
    }
    
    @inlinable
    var isEmpty: Bool {
        data.isEmpty
    }
    
    // MARK: - Value Decoders

    @inlinable
    static func decodeHexCp(data: Ron.Slice) -> Ron.Codepoint {
        var data = data
        var ret: Ron.Codepoint = 0
        while !data.isEmpty {
            ret <<= 4
            guard let i = Ron.abc16[.init(data[0])] else { return 0 }
            ret |= .init(i)
            data += 1
        }
        return ret
    }
}

public extension UInt8 {
    @inlinable
    var decodedEsc: Self {
        switch self {
        case "a":
            return "\u{07}" // \a
        case "b":
            return "\u{08}" // \b
        case "f":
            return "\u{0c}" // \f
        case "n":
            return "\n"
        case "r":
            return "\r"
        case "t":
            return "\t"
        case "v":
            return "\u{0b}" // \v
        case "'":
            return "'"
        case #"""#:
            return #"""#
        default:
            return Ron.TextFrame.esc
        }
    }
}

public extension Ron.TextFrame.Cursor {
    static let ronFullStop: UInt8 = 255
    static let specCount = 2 // open RON
    
    @inlinable
    func parseFloat(_ atom: inout RonAtom) -> Ron.Result {
        atom.value.float = 0
        let range = self[atom]
        let fs: [UInt8] = range[range.range]
        atom.value.float = Double(String(bytes: fs + Array(repeating: 0,
                                                           count: 32 - fs.count),
                                         encoding: .utf8)!)!
        return .ok
    }
    
    @inlinable
    func parseInteger(_ atom: inout RonAtom) -> Ron.Result {
        atom.value.integer = 0
        let range = self[atom]
        var i = range.begin
        var neg = false
        if range[i] == "-" {
            neg = true
            i += 1
        } else if range[i] == "+" {
            i += 1
        }
        for idx in i..<range.end {
            atom.value.integer *= 10
            atom.value.integer += .init(range[idx] - "0")
        }
        if neg {
            atom.value.integer.negate()
        }
        return .ok
    }
    
    @inlinable
    func parse(atom: inout RonAtom) -> Ron.Result {
        switch atom.type {
        case .int:
            return parseInteger(&atom)
        case .float:
            return parseFloat(&atom)
        case .string:
            if atom.value.cp != 0 {
                atom = Ron.Atom(value: .init(atom.value.cp),
                                origin: Ron.Atom.Flags.string)
            }
            return .ok
        case .uuid:
            return .ok
        }
    }
    
    @inlinable
    init(data: Ron.Slice) {
        self.data = data
        op = []
        op.reserveCapacity(Ron.Term.raw.rawValue)
        ragelState = 0
        line = 1
        spanSize = 0
    }
    
    @inlinable
    init(str: String) {
        self.init(data: .init(data: str))
    }

    @inlinable
    init(host: Ron.TextFrame) {
        self.init(str: host.data)
    }
    
    /** Returns whether the last op was parsed successfully.  */
    @inlinable
    var isValid: Bool {
        ragelState != 0
    }
    
    @inlinable
    subscript(a: RonAtom) -> Ron.Slice {
        return .init(data: data.buf,
                     range: a.safeOrigin.range)
    }
    
    /** The current op's id. */
    @inlinable
    var id: Ron.UUID {
        atom(at: Ron.opIdIdx) as! Ron.UUID
    }
    
    /** The current op's reference id. */
    @inlinable
    var ref: Ron.UUID {
        atom(at: Ron.opRefIdx) as! Ron.UUID
    }
    
    /** Returns an atom (0 id, 1 ref, 2... are values). Values are parsed.
     */
    @inlinable
    func atom(at idx: Ron.FSize = 2) -> Ron.Atoms.Element {
        assert(op.count > idx)
        var ret = op[Int(idx)]
        _ = parse(atom: &ret)
        return ret
    }
    
    @inlinable
    var frame: Ron.TextFrame {
        .init(data: data)
    }
}

// MARK: - Serialization
public extension Ron.TextFrame {
    struct Builder {
        @usableFromInline
        var prevId: Ron.UUID
        @usableFromInline
        var prev2: RonAtom
        @usableFromInline
        var spanSize: Ron.FSize
        
        /** Frame data (builder owns the memory) */
        @usableFromInline
        var data: String
    }
}

public extension RonTextFrameCursor {
    var spanSignature: RonAtom {
        guard op.count == 3 else {
            return Ron.UUID.nil
        }
        let atom = op[2]
        switch atom.type {
        case .int, .float:
            return Ron.UUID.nil
        case .uuid:
            return atom
        case .string:
            let a = self.atom(at: 2)
            return a.stringSize == 1 ?
                Ron.Atom(value: 0,
                         origin: Ron.Atom.Flags.string)
                : Ron.UUID.nil
        }
    }
}

extension Ron.TextFrame.Builder {
    @inlinable
    mutating func write(_ c: UInt8) {
        data += .init(UnicodeScalar(c))
    }
    
    @inlinable
    mutating func write(_ cp: Ron.Codepoint) {
        data += cp.utf8Esc
    }
    
    @inlinable
    mutating func write(_ data: Ron.Slice) {
        self.data += data.str
    }
    
    @inlinable
    mutating func write(_ value: Int) {
        data += "\(value)"
    }
    
    @inlinable
    mutating func write(_ value: Double) {
        data += .init(format: "%.17G", value)
    }
    
    @inlinable
    mutating func write(_ value: Ron.UUID) {
        data += value.str
    }
    
//    @inlinable
//    mutating func write(_ value: Character) {
////        for i in value.utf8 {
////            escape(&data,
////                   unescaped: i)
////        }
//        data.append(value)
//    }
    
    @inlinable
    mutating func write(_ value: String) {
        data += escape(unescaped: .init(data: value))
    }
    
    @usableFromInline
    func escape(unescaped: Ron.Slice) -> String {
        UnsafeMutableBufferPointer<UInt8>.transient(capacity: unescaped.count * 2) { escaped in
            var ptr = escaped.baseAddress!
            unescaped.forEach { i in
                escape(&ptr,
                       unescaped: i)
            }
            return .init(bytes: escaped.prefix(ptr),
                         encoding: .utf8)!
        }
    }
    
    @usableFromInline
    func escape(_ escaped: inout UnsafeMutablePointer<UInt8>,
                unescaped i: UInt8) {
        switch i {
        case "\u{08}": // \b
            escaped.append(Ron.TextFrame.esc)
            escaped.append("b")
        case "\u{0c}": // \f
            escaped.append(Ron.TextFrame.esc)
            escaped.append("f")
        case "\n":
            escaped.append(Ron.TextFrame.esc)
            escaped.append("n")
        case "\r":
            escaped.append(Ron.TextFrame.esc)
            escaped.append("r")
        case "\t":
            escaped.append(Ron.TextFrame.esc)
            escaped.append("t")
        case "\"", "'", "\\":
            escaped.append(Ron.TextFrame.esc)
            fallthrough
        default:
            escaped.append(i)
        }
    }
    
    @inlinable
    mutating func writeTerm(_ term: Ron.Term = .reduced) {
        guard spanSize > 0 else { return }
        if spanSize > 1 {
            if prev2.type != .string {
                write("(")
                write(Int(spanSize))
            } else {
                write(Ron.Atom.Kind.string.punct)
            }
            write(")")
        }
        write(term.punct)
        write(Ron.nl)
        spanSize = 0
    }
    
    @inlinable
    mutating func writeSpec(id: Ron.UUID,
                            ref: Ron.UUID) {
        writeTerm()
        spanSize = 1
        let seqId = id == (prevId + 1)
        if !seqId {
            write(Ron.SpecType.event.punct)
            write(id)
        }
        if ref != prevId {
            if !seqId {
                write(" ")
            }
            write(Ron.SpecType.ref.punct)
            write(ref)
        }
        prevId = id
    }
    
    /** The op must be *parsed*. */
    @discardableResult @inlinable
    mutating func writeValues<C>(_ cur: C) -> Ron.Result where C : RonTextFrameCursor {
        let op = cur.op
        for var atom in op.dropFirst(2) {
            write(" ")
            switch atom.type {
            case .int:
                write(atom.value.integer)
            case .uuid:
                if let uuid = atom as? Ron.UUID {
                    if uuid.isAmbiguous {
                        write(Ron.Atom.Kind.uuid.punct)
                    }
                    write(uuid)
                }
            case .string:
                write(Ron.Atom.Kind.string.punct)
                while atom.value.cp != 0 {
                    write(atom.value.cp)
                    _ = cur.nextCodepoint(&atom)
                }
                write(Ron.Atom.Kind.string.punct)
            case .float:
                write(atom.value.float)
            }
        }
        prev2 = cur.spanSignature
        return .ok
    }
    
    @discardableResult @inlinable
    mutating func writeValues(_ cur: Ron.TextFrame.Cursor) -> Ron.Result {
        let op = cur.op
        for atom in op.dropFirst(2) {
            write(" ")
            switch atom.type {
            case .int:
                write(cur[atom])
            case .uuid:
                if let uuid = atom as? Ron.UUID {
                    if uuid.isAmbiguous {
                        write(Ron.Atom.Kind.uuid.punct)
                    }
                    write(uuid)
                }
            case .string:
                write(Ron.Atom.Kind.string.punct)
                if atom.value.cp != 0 { // a char
                    write(atom.value.cp)
                } else {
                    write(cur[atom])
                }
                write(Ron.Atom.Kind.string.punct)
            case .float:
                write(cur[atom])
            }
        }
        prev2 = cur.spanSignature
        return .ok
    }
    
    @inlinable
    func isSameSpan<C>(with cur: C) -> Bool where C : RonTextFrameCursor {
        guard cur.ref == prevId else {
            return false
        }
        guard cur.id == prevId + 1 else {
            return false
        }
        
        return (prev2 as? Ron.UUID) != .nil && cur.spanSignature == prev2
    }
    
    @discardableResult @inlinable
    mutating func extendSpan<C>(with cur: C) -> Ron.Result where C : RonTextFrameCursor {
        if prev2.type == .string {
            var a = cur.op[2]
            if spanSize == 1 {
                UnsafeMutableBufferPointer<UInt8>.transient(capacity: 8) { ret in
                    var retPtr = ret.baseAddress!
                    data.removeLast()
                    while let last = data.last?.utf8.first, last != Ron.Atom.Kind.string.punct {
                        retPtr.append(last)
                        data.removeLast()
                    }
                    data.removeLast()
                    write("(")
                    write(Ron.Atom.Kind.string.punct)
                    data += .init(bytes: ret
                                    .prefix(retPtr)
                                    .reversed(),
                                  encoding: .utf8)!
                }
            }            
            if a.value.cp == 0 {
                _ = cur.nextCodepoint(&a)
            }
            write(a.value.cp)
        }
        spanSize += 1
        prevId += 1
        return .ok
    }
}

public extension Ron.TextFrame.Builder {
    @inlinable
    init() {
        prevId = .nil
        prev2 = Ron.UUID.fatal
        spanSize = 0
        data = ""
    }
    
    // MARK: - API Methods
    
    @discardableResult @inlinable
    mutating func appendOp<C>(with cur: C) -> Ron.Result where C : RonTextFrameCursor {
        if isSameSpan(with: cur) {
            return extendSpan(with: cur)
        } else {
            writeTerm()
            writeSpec(id: cur.id,
                      ref: cur.ref)
            return writeValues(cur)
        }
    }
        
    @discardableResult @inlinable
    /** A shortcut method, avoids re-serialization of atoms. */
    mutating func appendOp(with cur: Ron.TextFrame.Cursor) -> Ron.Result {
        if isSameSpan(with: cur) {
            return extendSpan(with: cur)
        } else {
            writeTerm()
            let op = cur.op
            writeSpec(id: op[Int(Ron.opIdIdx)] as! Ron.UUID,
                      ref: op[Int(Ron.opRefIdx)] as! Ron.UUID)
            return writeValues(cur)
        }
    }
    
    @discardableResult @inlinable
    mutating func endChunk(term: Ron.Term = .raw) -> Ron.Result {
        assert(term != .reduced)
        // empty chunks?
        writeTerm(term)
        return .ok
    }
    
    @discardableResult @inlinable
    mutating func endFrame() -> Ron.Result {
        write(Ron.frameTerm)
        return .ok
    }
    
    @discardableResult @inlinable
    mutating func release(to: inout String) -> Ron.Result {
        if spanSize != 0 {
            _ = endChunk()
        }
        swap(&data, &to)
        data.removeAll()
        return .ok
    }
    
    @inlinable
    mutating func release(to: inout Ron.TextFrame) -> Ron.Result {
        release(to: &to.data)
    }
    
    @inlinable
    mutating func release() -> Ron.TextFrame {
        var ret = Ron.TextFrame()
        _ = release(to: &ret)
        return ret
    }
    
    @inlinable
    var isEmpty: Bool {
        data.isEmpty
    }
}

extension Ron.Slice {
    @inlinable
    var decodedHexCp: Ron.Codepoint {
        buf.withContiguousStorageIfAvailable {
            var ret: Ron.Codepoint = 0
            for c in $0[range.intRange] {
                ret <<= 4                
                guard let i = Ron.abc16[Int(c)] else { return 0 }
                ret |= .init(i)
            }
            return ret
        }!
    }
}

extension UInt8 : ExpressibleByUnicodeScalarLiteral {
    public typealias UnicodeScalarLiteralType = UnicodeScalar
    
    @inlinable
    public init(unicodeScalarLiteral value: UnicodeScalarLiteralType) {
        self = .init(ascii: value)
    }
}
//        using Comparator = bool (*)(const Cursor& a, const Cursor& b);


//

//namespace std {
//
//inline void swap(ron::TextFrame::Builder& builder, ron::String& str) {
//    builder.Release(str);
//}
//
//inline void swap(ron::TextFrame& f, ron::String& str) { f.swap(str); }
//
//}  // namespace std
//
//#endif

//    //    KILLL THIS!!!
//    static String unescape(const Slice& data);
//    static inline String string(Slice data, const Atom& a) {
//        Slice esc = data.slice(a.origin.range());
//        return unescape(esc);
//    }
//    //    END OF KILL
//

//@inlinable
//func == (lhs: Substring.UTF8View, rhs: String.UTF8View) -> Bool {
//    lhs == rhs.dropFirst(0)
//}
//
//@inlinable
//func == (lhs: String.UTF8View, rhs: Substring.UTF8View) -> Bool {
//    lhs.dropFirst(0) == rhs
//}
//
//@inlinable
//func < (lhs: Substring.UTF8View, rhs: String.UTF8View) -> Bool {
//    lhs < rhs.dropFirst(0)
//}
//
//@inlinable
//func < (lhs: String.UTF8View, rhs: Substring.UTF8View) -> Bool {
//    lhs.dropFirst(0) < rhs
//}
//
//extension String.UTF8View : Equatable {
//    @inlinable
//    public static func == (lhs: Self, rhs: Self) -> Bool {
//        lhs.dropFirst(0) == rhs.dropFirst(0)
//    }
//}
//
//extension Substring.UTF8View : Equatable {
//    @inlinable
//    public static func == (lhs: Self, rhs: Self) -> Bool {
//        lhs.withContiguousStorageIfAvailable { lPtr in
//            rhs.withContiguousStorageIfAvailable { rPtr in
//                lhs.count == rhs.count && zip(lhs, rhs).allSatisfy(==)
//            }!
//        }!
//    }
//}
//
//extension String.UTF8View : Comparable {
//    @inlinable
//    public static func < (lhs: Self, rhs: Self) -> Bool {
//        lhs.dropFirst(0) < rhs.dropFirst(0)
//    }
//}
//
//extension Substring.UTF8View : Comparable {
//    @inlinable
//    public static func < (lhs: Self, rhs: Self) -> Bool {
//        lhs.withContiguousStorageIfAvailable { lPtr in
//            rhs.withContiguousStorageIfAvailable { rPtr in
//                zip(lPtr, rPtr)
//                    .first(where: !=)
//                    .map(<)
//                    ?? (lPtr.count < rPtr.count)
//            }!
//        }!
//    }
//}
