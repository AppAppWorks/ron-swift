public protocol RonTextFrameCursor {
    var op: Ron.Atoms { get }
    var frame: Ron.TextFrame { get }
    var id: Ron.UUID { get }
    var ref: Ron.UUID { get }
    var isValid: Bool { get }
    var term: Ron.Term { get }
    func atom(at idx: Ron.FSize) -> RonAtom
    
    mutating func next() -> Ron.Status
    /** Parses a codepoint (escaped UTF8), saves to atom.value.cp,
     *  consumes the origin range, decreases atom.value.cp_size
     *  (full parser). */
    func nextCodepoint(_ c: inout RonAtom) -> Ron.Result
    
    func hasValue(of type: Ron.Atom.Kind,
                  at idx: Ron.FSize) -> Bool
}

public extension Ron {
    
    /// An op in the nominal RON (open) coding.
    /// That's the internal format
    struct Op : RonTextFrameCursor {
        @usableFromInline
        var atoms: Ron.Atoms = []
        @usableFromInline
        var strings: Ron.Codepoints = []
        
        @inlinable
        mutating func writeAtoms(_ atoms: [Atom]) {
            for atom in atoms {
                switch atom {
                case let .integer(value):
                    self.atoms.append(Ron.Atom.integer(i: value))
                case let .uuid(uuid):
                    self.atoms.append(uuid)
                case let .float(value):
                    self.atoms.append(Ron.Atom.float(value: value))
                case let .string(value):
                    let b = Ron.FSize(strings.count)
                    _ = strings.parseUtf8(from: value)
                    let cpSize = Ron.FSize(strings.count) - b
                    if cpSize > 0 {
                        let range: Ron.Range = b + 1..<(.init(strings.count))
                        self.atoms.append(Ron.Atom.string(cp: strings[.init(b)],
                                                          range: range,
                                                          cpSize: cpSize - 1))
                    } else {
                        self.atoms.append(Ron.Atom.string(cp: 0,
                                                          range: b..<b,
                                                          cpSize: cpSize))
                    }
                }
            }
        }
        
        @inlinable
        mutating func writeAtoms(_ atoms: Atom...) {
            writeAtoms(atoms)
        }
        
        @inlinable
        mutating func writeValues<C>(with cur: C) -> Ron.Result where C : RonTextFrameCursor {
            let op = cur.op
            for var a in op.dropFirst(2) {
                guard a.type == .string else {
                    atoms.append(a)
                    continue
                }
                let b = Ron.FSize(strings.count)
                var cpSize: Ron.FSize = 0
                while a.value.cpSize > 0 {
                    strings.append(a.value.cp)
                    _ = cur.nextCodepoint(&a)
                    cpSize += 1
                }
                let range = b..<(.init(strings.count))
                atoms.append(Ron.Atom.string(cp: strings[.init(b)],
                                             range: range,
                                             cpSize: cpSize))
            }
            return .ok
        }
        
        @inlinable
        static func amend<C>(id: Ron.UUID,
                             ref: Ron.UUID,
                             cur: C) -> Self where C : RonTextFrameCursor {
            var ret = Op(id: id,
                         ref: ref)
            _ = ret.writeValues(with: cur)
            return ret
        }
    }
}

public extension Ron.Op {
    enum Atom {
        case uuid(Ron.UUID)
        case integer(Int)
        case float(Double)
        case string(String)
    }
    
    @inlinable
    var op: Ron.Atoms {
        atoms
    }
    
    @inlinable
    var id: Ron.UUID {
        atoms[0] as! Ron.UUID
    }
    
    @inlinable
    var ref: Ron.UUID {
        atoms[1] as! Ron.UUID
    }
    
    @inlinable
    var isValid: Bool {
        fatalError()
    }
    
    var term: Ron.Term {
        fatalError()
    }
    
    @inlinable
    func atom(at idx: Ron.FSize = 2) -> RonAtom {
        atoms[.init(idx)]
    }
    
    var frame: Ron.TextFrame {
        fatalError()
    }
    
    func next() -> Ron.Status {
        fatalError()
    }
    
    @inlinable
    func nextCodepoint(_ c: inout RonAtom) -> Ron.Result {
        guard c.value.cpSize > 0 else {
            c.value.cp = 0
            return .outOfRange
        }
        c.value.cp = strings[.init(c.origin.range.lowerBound)]
        c.value.cpSize -= 1
        c.origin.range.consume(1)
        return .ok
    }
    
    /** A convenience API method to add an op with any number of atoms. */
    @inlinable
    init(id: Ron.UUID,
         ref: Ron.UUID,
         _ atoms: Atom...) {
        self.atoms.removeAll()
        self.atoms.append(id)
        self.atoms.append(ref)
        writeAtoms(atoms)
    }
    
    @inlinable
    init(id: String,
         ref: String,
         _ atoms: Atom...) {
        self.atoms.removeAll()
        self.atoms.append(Ron.UUID(buf: id))
        self.atoms.append(Ron.UUID(buf: ref))
        writeAtoms(atoms)
    }
}
