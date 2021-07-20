//
//  File.swift
//  
//
//  Created by Lau Chun Kai on 9/7/2021.
//

import Foundation
import RonCore

public struct Js {
    var storage = [String : Atom]()
    var id: String
    var uuid = Uuid.zero
    var type: Uuid
    var version: String
    var length: Int
}

public extension Js {
    static func == (lhs: Self, rhs: [String : Atom]) -> Bool {
        lhs.storage == rhs
    }
    
    static func == (lhs: [String : Atom], rhs: Self) -> Bool {
        rhs == lhs
    }
    
    subscript(key: String) -> Atom? {
        get {
            storage[key]
        }
        set {
            storage[key] = newValue
        }
    }
    
    var values: [Atom] {
        .init(storage.values)
    }
    
    func toJson() -> Data {
        let jsonObj = storage.values.map { atom -> Any? in
            switch atom {
            case let .bool(a as Any),
                 let .double(a as Any),
                 let .int(a as Any),
                 let .string(a as Any):
                 return a
            case let .uuid(uuid):
                return "#\(uuid.toString())"
            case _: return nil
            }
        }
        return try! JSONSerialization.data(withJSONObject: jsonObj)
    }
    
    init?(rawFrame: String) {
        switch (Frame(str: rawFrame).first { _ in true })?.type {
        case Lww.type:
            guard let this = try? Lww.ronToJs(rawFrame: rawFrame) else {
                return nil
            }
            self = this.0
        case Set.type:
            self = Set.ronToJs(rawFrame: rawFrame)
        case .some(.zero):
            var v = Set.ronToJs(rawFrame: rawFrame)
            v.type = .zero
            self = v
        case _:
            return nil
        }
    }
}

extension Js : Sequence {
    public func makeIterator() -> AnyIterator<(key: String, value: Atom)> {
        .init(storage.makeIterator())
    }
}

public extension Batch {
    func reduce() -> Frame {
        switch (first?.first { _ in true })?.type ?? .zero {
        case Lww.type:
            return Lww.reduce(batch: self)
        case Set.type:
            return Set.reduce(batch: self)
        case Log.type:
            return Log.reduce(batch: self)
        case .zero:
            return Set.reduce(batch: self,
                              specialType: .fromString(""))
        case _:
            return empty()
        }
    }
    
    func empty() -> Frame {
        var ret = Frame()
        first?.first { _ in true }
            .map { op in
                let loc = op.uuid(op.isHeader ? .three : .two)
                ret.append(
                    Op(
                        type: op.uuid(.zero),
                        object: op.uuid(.one),
                        event: self[count - 1].first { _ in true }!.event,
                        location: loc,
                        term: Op.Sep.frame
                    )
                )
            }
        return ret
    }
}
