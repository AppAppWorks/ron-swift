//
//  File.swift
//  
//
//  Created by Lau Chun Kai on 3/8/2021.
//

import RonCore_xx

public extension Ron {
    struct LwwObject {
        @usableFromInline
        var cur: Ron.TextFrame.Cursor
        @usableFromInline
        var vals: [Ron.UUID : RonAtom]
        @usableFromInline
        var last: Ron.UUID
    }
}

public extension Ron.LwwObject {
    @inlinable
    mutating func update(with c: Ron.TextFrame.Cursor) {
        guard c.op.count >= 4 && c.hasValue(of: .uuid) else {
            return
        }
        vals[.init(a: c.atom(at: 2))] = c.atom(at: 3)
        last = c.id
    }
    
    @inlinable
    mutating func update(with frame: Ron.TextFrame) {
        var c = Ron.TextFrame.Cursor(host: frame)
        while c.next()() {
            update(with: c)
        }
    }
    
    /** Note that LWWObject does not own the memory. It serves like an index to
     * a LWW frame. */
    init(state: Ron.TextFrame) {
        cur = .init(host: state)
        // TODO: to remove
        cur.next()
        vals = [:]
        last = .init()
    }
    
    func atom(key: Ron.UUID,
              type: Ron.Atom.Kind) -> RonAtom {
        guard let i = vals[key],
              i.type == type else {
            return Ron.UUID.nil
        }
        return i
    }
    
    @inlinable
    func uuid(key: Ron.UUID) -> Ron.UUID {
        .init(a: atom(key: key,
                      type: .uuid))
    }
    
    @inlinable
    func number(key: Ron.UUID) -> Double? {
        let a = atom(key: key,
                     type: .float)
        return Ron.UUID.nil == .init(a: a) ? nil : .init(a.value.integer)
    }
    
    @inlinable
    func string(key: Ron.UUID) -> String {
        let a = atom(key: key,
                     type: .string)
        var ret = ""
        cur.readString(to: &ret,
                       atom: a)
        return ret
    }
}
