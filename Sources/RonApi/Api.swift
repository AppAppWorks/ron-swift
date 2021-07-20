//
//  Api.swift
//  
//
//  Created by Lau Chun Kai on 19/7/2021.
//

import Foundation
import RonCore
import RonRdt
import RonClient

public protocol Subscription {
    func off() -> Bool
    func isHash(_ hash: String) -> Bool
}

public class API {
    enum Error : Swift.Error {
        case error(String)
    }
    
    public internal(set) var client: Client
    var options: Options
    var subs: [Subscription] = []
    var cache: [String : [String : Atom]] = [:]
    var gcWorkItem: DispatchWorkItem?
    
    public init(options: Options) {
        client = Client(options: options.clntOps)
        self.options = options
        if let gcPeriod = options.gcPeriod {
            gcWorkItem = .init {
                self.gc()
                DispatchQueue.global(qos: .background)
                    .asyncAfter(deadline: .now() + .milliseconds(gcPeriod),
                                execute: self.gcWorkItem!)
            }
            DispatchQueue.global(qos: .background)
                .asyncAfter(deadline: .now() + .milliseconds(gcPeriod),
                            execute: gcWorkItem!)
        }
    }
}

public extension API {
    enum Value {
        public enum Object {
            case atom(RonCore.Atom)
            case value(Value)
        }
        
        case dictionary([String : Object])
        case array([Value])
    }
    
    @dynamicMemberLookup
    struct Options {
        public var clntOps: Client.Options
        public var gcPeriod: Int?
        public var strictMode: Bool = false
        
        public init(clntOps: Client.Options,
                    gcPeriod: Int? = nil,
                    strictMode: Bool = false) {
            self.clntOps = clntOps
            self.gcPeriod = gcPeriod
            self.strictMode = strictMode
        }
        
        subscript<T>(dynamicMember member: WritableKeyPath<Client.Options, T>) -> T {
            get {
                clntOps[keyPath: member]
            }
            set {
                clntOps[keyPath: member] = newValue
            }
        }
    }
    
    enum ID {
        case string(String)
        case uuid(Uuid)
        
        var uuid: Uuid {
            switch self {
            case let .string(id):
                return .fromString(id)
            case let .uuid(uuid):
                return uuid
            }
        }
        
        var string: String {
            switch self {
            case let .string(id):
                return id
            case let .uuid(uuid):
                return uuid.toString()
            }
        }
    }
}

public extension API {
    func ensure() -> Promise<Void> {
        client.ensure()
    }
    
    func uuid() throws -> Uuid {
        guard client.clock != nil else {
            throw Error.error("have no clock yet, invoke `ensure()` first")
        }
        return try client.clock!.time()
    }
    
    /// garbage collection for unused cached data
    func gc() -> (deleted: Int, existing: Int) {
        var ret = (deleted: 0, existing: 0)
        let lstnrs = Swift.Set(client.lstn.keys)
        
        for (id, _) in cache {
            if !lstnrs.contains(id) {
                cache[id] = nil
                ret.deleted += 1
            } else {
                ret.existing += 1
            }
        }
        
        return ret
    }
    
    func set(id: ID,
             value: [String : Atom]) -> Promise<Bool> {
        let uuid = id.uuid
        return client.ensure()
            .then { [unowned self] in
                if options.strictMode {
                    return typeOf(id: id)
                        .then { type in
                            .resolve(type == Lww.type.toString())
                        }
                } else {
                    return .resolve(true)
                }
            }
            .then { [unowned self] (lastResult: Bool) in
                guard lastResult else {
                    return .resolve(false)
                }
                
                var frame = Frame()
                
                try frame.append(
                    Op(
                        type: Lww.type,
                        object: uuid,
                        event: self.uuid(),
                        location: .zero,
                        term: Op.Sep.frame
                    )
                )
                
                for (k, v) in (value.sorted { $0.key < $1.key }) {
                    var op = Op(
                        type: Lww.type,
                        object: uuid,
                        event: frame.last.uuid(.two),
                        location: .fromString(k),
                        term: ","
                    )
                    
                    if v != .removal {
                        op.values = String(jsValues: [v])
                        guard uuid.isLocal || v.uuid?.isLocal != true else {
                            return .resolve(false)
                        }
                    }                    
                    
                    frame.append(op)
                }
                
                if frame.isPayload {
                    return client.append(frame.toString())
                        .then {
                            .resolve(true)
                        }
                }
                
                return .resolve(false)
            }
    }
    
    func append(id: ID,
                value: Atom) -> Promise<Bool> {
        let uuid = id.uuid
        return ensure()
            .then { [unowned self] in
                if options.strictMode {
                    return typeOf(id: id)
                        .then { type in
                            .resolve(type == Set.type.toString())
                        }
                } else {
                    return .resolve(true)
                }
            }
            .then { [unowned self] (lastResult: Bool) in
                guard lastResult else {
                    return .resolve(false)
                }
                
                var frame = Frame()
                let time = try self.uuid()
                var op = Op(
                    type: Set.type,
                    object: uuid,
                    event: time,
                    location: .zero,
                    term: Op.Sep.frame
                )
                frame.append(op)
                
                guard uuid.isLocal || value.uuid?.isLocal != true else {
                    return .resolve(false)
                }
                
                op.values = String(jsValues: [value])
                frame.append(op,
                             term: .comma)
                
                return client.append(frame.toString())
                    .then {
                        .resolve(true)
                    }
            }
    }
    
    func remove(id: ID,
                value: Atom) -> Promise<Bool> {
        let uuid = id.uuid
        return ensure()
            .then { [unowned self] in
                if options.strictMode {
                    return typeOf(id: id)
                        .then { type in
                            .resolve(type == Set.type.toString())
                        }
                } else {
                    return .resolve(true)
                }
            }
            .then { [unowned self] (lastResult: Bool) in
                guard lastResult else {
                    return .resolve(false)
                }
                
                var frame = Frame()
                let ts = try self.uuid()
                var op = Op(
                    type: Set.type,
                    object: uuid,
                    event: ts,
                    location: .zero,
                    term: Op.Sep.frame
                )
                frame.append(op)
                
                return client.storage
                    .get(key: id.string)
                    .then {
                        guard let state = $0 else {
                            return .resolve(false)
                        }
                                                
                        var deleted = false
                        let str = String(jsValues: [value])
                        for v in Frame(str: state) where v.isRegular && v.values == str {
                            deleted = true
                            op.location = v.event
                            op.values = ""
                            frame.append(op,
                                         term: .comma)
                        }
                        
                        if deleted {
                            return client.append(frame.toString())
                                .then {
                                    .resolve(true)
                                }
                        }
                        return .resolve(false)
                    }
            }
    }
    
    func close() -> Promise<Void> {
        client.close()
    }
    
    func open() {
        client.open()
    }
    
    func typeOf(id: ID) -> Promise<String> {
        let idStr = id.string
        if let obj = cache[idStr] {
            switch obj["type"] {
            case let .string(type):
                return .resolve(type)
            case _:
                return .resolve("")
            }
        }
        
        return client.storage
            .get(key: idStr)
            .then { state in
                if let state = state,
                   let op = Op(body: state) {
                    return .resolve(op.uuid(.zero).toString())
                } else {
                    return .resolve("")
                }
            }
    }
}

extension Storage {
    func get(key: String) -> Promise<String?> {
        .init { resolve, _ in
            get(key: key,
                completion: resolve)
        }
    }
}
