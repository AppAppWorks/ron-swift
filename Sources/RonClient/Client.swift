//
//  File.swift
//  
//
//  Created by Lau Chun Kai on 16/7/2021.
//

import Foundation
import RonClock
import RonCore
import RonRdt

let SEEN = "0"
let META = "__meta__"

/// A bare-bone swarm client. Consumes updates from the server,
/// feeds resulting RON states back to the listeners.
public class Client  {
    enum Error : Swift.Error {
        case noConnectionNorClockOptions
        case timeout
        case handshake(String)
        case differentClockMode(Meta.ClockMode?, Meta.ClockMode?)
        case notSupportedClockMode(Meta.ClockMode?)
        case haveNoClock
        case serverError(String)
        case idNotSpecified(String)
    }
    
    public var clock: Clock?
    public var lstn: [String : [CallBack]] = [:]
    public internal(set) var upstream: Connection!
    public internal(set) var storage: Storage!
    var queue: [((()) -> Void, (Swift.Error) -> Void)]? = []
    var db: Meta
    var options: (
        hsTimeout: Int,
        fetchTimeout: Int,
        resendAfter: Int
    )
    var pending: PendingOps!
    var seen: Uuid = .zero
    var dispatchQueue: DispatchQueue
    
    public init(options: Options,
                dispatchQueue: DispatchQueue = .main) {
        self.dispatchQueue = dispatchQueue
        db = options.db.map(Self.defaultMeta.unioning) ?? Self.defaultMeta
        storage = options.storage
        self.options = (
            hsTimeout: options.hsTimeout ?? 300_000 /* 5min */,
            fetchTimeout: options.fetchTimeout ?? 30_000 /* 30sec */,
            resendAfter: options.resendAfter ?? 0
        )
        // TODO: I doubt it
        //        DispatchQueue.main.async {
        self.initialize(options)
        //        }
        
        seen = .zero
    }
}

public extension Client {
    class CallBack {
        var f: (_ frame: String, _ state: String?) -> Void
        var once: Bool = false
        var ensure: Bool = false
        
        public init(f: @escaping (_ frame: String, _ state: String?) -> Void) {
            self.f = f
        }
        
        func callAsFunction(frame: String, state: String?) {
            f(frame, state)
        }
    }
    
    func initialize(_ options: Options) {
        var meta: String?
        
        storage.multiGet(keys: [META, SEEN])
            .then { [unowned self] results in
                meta = results[META]!
                let seen = results[SEEN]!
                
                let last = seen.map { Uuid.fromString($0) } ?? .zero
                db = try db.unioning(.jsonify(meta ?? "{}"))
                
                if let clockMode = db.clockMode, let id = db.id {
                    switch clockMode {
                    case .logical:
                        clock = LogicalClock(
                            origin: id,
                            count: db.clockCount,
                            last: .uuid(last)
                        )
                    case .calendar:
                        clock = CalendarClock(
                            origin: id,
                            last: .uuid(last),
                            offset: db.offset ?? 0,
                            count: db.clockCount
                        )
                    }
                }
                self.seen = last
                
                switch (options.upstream, options.db?.clockMode) {
                case let (.string(upstream), _):
                    //                    self.upstream =
                    fatalError("unimplemented remote connection!")
                case let (.connection(upstream), _):
                    self.upstream = upstream
                case (nil, _?):
                    upstream = DevNull()
                case (nil, nil):
                    throw Error.noConnectionNorClockOptions
                }
                
                return PendingOps.read(storage: storage)
            }
            .then { [self] (pending: PendingOps) in
                pending.queue = dispatchQueue
                self.pending = pending
                // check if we start with an already existing replica
                if let _ = meta, let _ = clock {
                    upstream.onOpen = { _ in
                        handshake()
                            .catch { e in
                                close()
                                    .then {
                                        panic(e)
                                    }
                            }
                    }
                    release(nil)
                } else {
                    upstream.onOpen = { _ in
                        handshake()
                            .then {
                                release(nil)
                            }
                            .catch { e in
                                close()
                                    .then {
                                        release(e)
                                    }
                            }
                    }
                }
            }
            .catch { error in
                self.release(error)
            }
    }
    
    func handshake() -> Promise<Void> {
        if let upstream = upstream as? DevNull {
            return .init { [unowned self] resolve, reject in
                do {
                    _ = try storage.set(
                        key: META,
                        value: db.stringify()
                    )
                        .then {
                            upstream.onMessage = { me in
                                onMessage(me.data)
                                    .catch(panic)
                            }
                        }
                    resolve(())
                } catch {
                    reject(error)
                }
            }
        }
        
        let hs = Promise<String> { [unowned self] resolve, reject in
            DispatchQueue
                .main
                .asyncAfter(deadline: .now() + .milliseconds(options.hsTimeout)) {
                    reject(Error.timeout)
                }
            upstream.onMessage = { me in
                resolve(me.data)
            }
        }
        
        var hello = Frame()
        let head = Op(
            type: .init(
                value: "db",
                origin: "0",
                sep: "$"
            ),
            object: .init(
                value: db.name!,
                origin: "0",
                sep: "$"
            ),
            event: .init(
                value: seen.value,
                origin: db.id ?? "0",
                sep: "+"
            ),
            location: .zero,
            term: Op.Sep.query
        )
        hello.append(head)
        hello.append(head, term: .frame)
        
        if let auth = db.auth {
            hello.append(
                Op(
                    type: head.uuid(.zero),
                    object: head.uuid(.one),
                    event: head.uuid(.two),
                    location: head.uuid(.three),
                    values: String(jsValues: [.string(auth)]),
                    term: ","
                )
            )
        }
        upstream.send(data: hello.toString())
        
        return hs
            .then { [unowned self] resp in
                var dbOpts = db
                //            dbOpts.clockMode = .calendar
                
                var seen = Uuid.zero
                var dbDict = [String : Atom]()
                for var op in Frame(str: resp) {
                    if op.uuid(.three).isError {
                        close()
                        throw Error.handshake(op.uuid(.three).toString())
                    }
                    if seen == .zero {
                        seen = op.uuid(.two)
                    }
                    let val = op.value(0)
                    if val.isTruthy {
                        var key = op.uuid(.three).toString()
                        key.replaceSubrange(
                            key.startIndex...key.startIndex,
                            with: key.first!.lowercased()
                        )
                        dbDict[key == "0" ? "_0" : key] = val
                    }
                }
                
                let newOps = try dbDict.jsonReadyDict.asInstance(Meta.self)
                dbOpts = dbOpts.unioning(newOps)
                
                guard let op = Op(body: resp) else {
                    throw Error.handshake("Expected replica id not found in a handshake response")
                }
                
                dbOpts.id = op.uuid(.one).origin
                
                switch (clock, dbOpts.id, dbOpts.clockMode) {
                case let (_?, _, clockMode):
                    if db.clockMode != clockMode {
                        throw Error.differentClockMode(db.clockMode, clockMode)
                    }
                case let (_, id?, clockMode?):
                    switch clockMode {
                    case .logical:
                        clock = LogicalClock(
                            origin: id,
                            count: dbOpts.clockCount
                        )
                    case .calendar:
                        clock = CalendarClock(
                            origin: id,
                            count: dbOpts.clockCount
                        )
                    }
                case _:
                    throw Error.notSupportedClockMode(dbOpts.clockMode)
                }
                
                if let _0 = dbOpts._0 {
                    dbOpts.offset = try clock!.adjust(_0)
                } else {
                    dbOpts.offset = try clock?.adjust(seen)
                }
                dbOpts._0 = nil
                
                db = db.unioning(dbOpts)
                return try storage.set(
                    key: META,
                    value: db.stringify()
                )
            }
            .then { [unowned self] in
                upstream.onMessage = { me in
                    onMessage(me.data)
                        .catch(panic)
                                upstream.onOpen = { _ in
                            handshake()
                                .catch(panic)
                        }
                }
                upstream.onOpen = { _ in
                    handshake()
                        .catch(panic)
                }
                
                if options.resendAfter > 0 {
                    pending.onIdle = onIdle
                    pending.setIdlePeriod(options.resendAfter)
                } else {
                    // Resend all the frames
                    pending.forEach(upstream.send)
                }
                
                // Re-subscribe
                let query = lstn.keys
                if !query.isEmpty {
                    return on(query: "#" + query.joined(separator: "#"))
                        .then { _ in .resolve() }
                } else {
                    return .resolve()
                }
            }
    }
    
    /// Ensure returns Promise which will be resolved after connection
    /// installed or rejected if an error occurred.
    func ensure() -> Promise<Void> {
        if queue != nil {
            return .init { [unowned self] release, reject in
                queue?.append((release, reject))
            }
        } else {
            return .resolve()
        }
    }
    
    func release(_ err: Swift.Error?) {
        guard let queue = queue else { return }
        self.queue = nil //
        for (release, reject) in queue {
            if let err = err {
                reject(err)
            } else {
                release(())
            }
        }
        //        self.queue = nil
    }
    
    func close() -> Promise<Void> {
        upstream?.close()
        pending.onIdle = {}
        pending.setIdlePeriod(0)
        return .init { resolve, reject in
            self.pending.flush { result in
                switch result {
                case .success:
                    resolve(())
                case let .failure(error):
                    reject(error)
                }
            }
        }
    }
    
    func open() {
        upstream?.open()
    }
    
    func onMessage(_ message: String) -> Promise<Void> {
            .init { [unowned self] resolve, reject in
                guard let clock = clock else {
                    return reject(Error.haveNoClock)
                }
                
                guard let op = (Frame(str: message).first { _ in true }) else {
                    return resolve(())
                }
                guard op.uuid(.zero).toString() != "db" else {
                    close()
                    return reject(Error.serverError(op.toString()))
                }
                
                func something() {
                    var iter = Batch
                        .splitById(source: message)
                        .makeIterator()
                    guard let f = iter.next() else {
                        return resolve(())
                    }
                    
                    var promise = merge(
                        frame: f.toString(),
                        local: false
                    )
                    while let f = iter.next() {
                        promise = promise
                            .then {
                                self.merge(
                                    frame: f.toString(),
                                    local: false
                                )
                            }
                    }
                    
                    promise.then(resolve)
                }
                
                if op.event != .never {
                    see(event: op.event)
                        .then { _ in
                            guard op.event.origin == clock.origin else {
                                return something()
                            }
                            pending.release(ack: op.event) {
                                switch $0 {
                                case .success:
                                    something()
                                case let .failure(error):
                                    reject(error)
                                }
                            }
                        }
                } else {
                    something()
                }
            }
    }
    
    /// On installs subscriptions.
    func on(query: String,
            callback: CallBack? = nil,
            once: Bool = false,
            ensure: Bool = false) -> Promise<Bool> {
        var keys: [String]!
        callback?.once = once
        callback?.ensure = ensure
        
        return self.ensure()
            .then {
                keys = try Frame(str: query)
                    .unzip
                    .map { op in
                        guard op.uuid(.one) != .zero else {
                            throw Error.idNotSpecified(op.toString())
                        }
                        return op.uuid(.one).toString()
                    }
                
                return self.storage.multiGet(keys: .init(keys).union(["0"]))
            }
            .then { [unowned self] (data: [String : String?]) in
                var fwd = Frame()
                var upstrm = Frame()
                var onceSent = 0
                
                for key in keys {
                    let id = Uuid.fromString(key)
                    var base = Uuid.zero
                    let stored = data[key]!
                    
                    // try to avoid network request
                    if let callback = callback, callback.once,
                       stored != nil || !callback.ensure {
                        callback(
                            frame: "#" + key,
                            state: stored
                        )
                        onceSent += 1
                    } else {
                        if let stored = stored,
                           let op = (Frame(str: stored)
                                        .first { _ in true }) {
                            base = op.event < seen ? op.event : seen
                        }
                    }
                    
                    var found = false
                    let exists = callback != nil && lstn[key]?.isEmpty == false
                    
                    if let callback = callback {
                        found = lstn[key]?.contains { $0 === callback } ?? false
                        
                        if !found {
                            lstn[key, default: []].append(callback)
                        }
                    }
                    
                    if !found {
                        let op = Op(
                            type: .zero,
                            object: id,
                            event: base,
                            location: .zero,
                            values: "",
                            term: Op.Sep.query + Op.Sep.frame
                        )
                        
                        if !exists && !id.isLocal {
                            upstrm.append(op)
                        }
                        fwd.append(op)
                    }
                }
                
                if let upstream = upstream,
                   let _ = clock {
                    let upstrmStr = upstrm.toString()
                    if !upstrmStr.isEmpty {
                        upstream.send(data: upstrmStr)
                    }
                }
                
                let fwdStr = fwd.toString()
                let ret = !fwdStr.isEmpty || onceSent > 0
                
                if let callback = callback, !fwdStr.isEmpty {
                    return notify(
                        frame: fwdStr,
                        callback: callback
                    )
                        .then {
                                .resolve(ret)
                        }
                }
                
                return .resolve(ret)
            }
    }
    
    ///    Notify calls back with an existing states
    func notify(frame: String,
                callback: CallBack) -> Promise<Void> {
        let keys = Swift.Set(
            Frame(str: frame)
                .map { $0.uuid(.one).toString() }
        )
        return storage
            .multiGet(keys: keys)
            .then { store in
                for key in keys {
                    let value = store[key]!
                    let isLocal = key.hasSuffix(Uuid.local)
                    if !callback.ensure || value != nil || isLocal {
                        if callback.once {
                            self.off(
                                q: "#" + key,
                                callback: callback
                            )
                        }
                        
                        callback(
                            frame: "#" + key,
                            state: isLocal ? (value ?? "") : value
                        )
                    }
                }
                
                return .resolve()
            }
    }
    
    /// Merge updates local state and notifies listeners.
    /// Accepts single frame.
    ///    notifies listeners with empty payload
    ///    if there is no saved state
    func merge(frame: String,
               local: Bool = true) -> Promise<Void> {
        let fr = Frame(str: frame)
        
        guard let op = (fr.first { _ in true }) else {
            return .resolve()
        }
        
        let key = op.uuid(.one).toString()
        guard key != "0" else { return .resolve() }
        
        return .init { [unowned self] resolve, reject in
            var notify = false
            
            storage.merge(key: key) { prev in
                if fr.isPayload {
                    if let prev = prev {
                        let update = Batch(
                            strings: prev, frame
                        )
                            .reduce()
                            .toString()
                        notify = prev != update
                        return update
                    }
                    notify = true
                    return frame
                }
                
                // An empty state from the server whereas a local state is full
                if let prev = prev {
                    return prev
                }
                
                // Empty state from a server, hence, an object does not exist in the system.
                notify = true
                return ""
            } completion: { updated in
                if notify {
                    // Copy an array to be able to unsubscribe before calling back
                    for l in lstn[key] ?? [] {
                        if !l.ensure || updated != nil {
                            if l.once {
                                off(
                                    q: "#" + key,
                                    callback: l
                                )
                            }
                            l(
                                frame: "#" + key,
                                state: updated
                            )
                        }
                    }
                }
                resolve(())
            }
        }
    }
    
    /// Off removes subscriptions.
    func off(q: String?,
             callback: CallBack?) -> String? {
        // unless query passed fetch all the keys to unsubscribe from them
        let query = q?.isEmpty == false ? q!
        : lstn.keys
            .map { "#" + $0 }
            .joined()
        var c = 0
        var fwd = Frame()
        fwd.append(
            Op(
                type: .zero,
                object: .zero,
                event: .never,
                location: .zero,
                term: Op.Sep.query
            )
        )
        
        for op in Frame(str: query) {
            let key = op.uuid(.one).toString()
            guard let cbks = lstn[key], !cbks.isEmpty else { continue }
            if let callback = callback {
                lstn[key] = cbks.filter { $0 !== callback }
                if lstn[key]!.isEmpty {
                    if !op.uuid(.one).isLocal {
                        fwd.append(
                            Op(
                                type: op.type,
                                object: op.object,
                                event: .never,
                                location: .zero,
                                term: ","
                            )
                        )
                    }
                    lstn[key] = nil
                }
            } else {
                if !op.uuid(.one).isLocal {
                    fwd.append(
                        Op(
                            type: op.type,
                            object: op.object,
                            event: .never,
                            location: .zero,
                            term: ","
                        )
                    )
                    c += 1
                }
                lstn[key] = nil
            }
            if c > 0 {
                upstream.send(data: fwd.toString())
                return fwd.toString()
            }
            return nil
        }
        
        return nil
    }
    
    /// Push sends updates to remote and local storages.
    /// Waits for connection installed. Thus, the client works in
    /// read-only mode until installed connection.
    func append(_ rawFrame: String) -> Promise<Void> {
        ensure().then { [unowned self] in
            var stamps = [String : Uuid]()
            
            let frame = String(rawFrame: rawFrame) { uuid, position, _, _ in
                guard position != 0 else {
                    return uuid == .zero ? Lww.type : uuid
                }
                guard position <= 2 && uuid == .zero else {
                    return uuid
                }
                guard let exists = stamps[uuid.toString()] else {
                    let ret = try? clock?.time()
                    stamps[uuid.toString()] = ret
                    return ret
                }
                return exists
            }
            
            let filtered = Frame(str: frame)
                .reduce(into: Frame()) {
                    if !$1.uuid(.one).isLocal {
                        $0.append($1)
                    }
                }.toString()
            
            let ret = {
                merge(
                    frame: frame,
                    local: true
                )
            }
            
            if !filtered.isEmpty {
                return pending
                    .append(filtered)
                    .then {
                        upstream.send(data: filtered)
                        return ret()
                    }
            } else {
                return ret()
            }
        }
    }
    
    func panic(_ error: Swift.Error) {
        print("panic: \(error)")
    }
    
    func onIdle() {
        // Resend all the frames
        pending.forEach(upstream.send)
    }
    
    func see(event: Uuid) -> Promise<Uuid> {
            .init { [unowned self] resolve, reject in
                do {
                    if try clock?.see(uuid: event) == true {
                        seen = event
                        storage.set(
                            key: SEEN,
                            value: event.toString()
                        ) {
                            resolve(event)
                        }
                    } else {
                        resolve(event)
                    }
                } catch {
                    reject(error)
                }
            }
    }
}

extension Storage {
    func multiGet(keys: Swift.Set<String>) -> Promise<[String : String?]> {
            .init { resolve, reject in
                multiGet(
                    keys: keys,
                    completion: resolve
                )
            }
    }
    
    func set(key: String, value: String) -> Promise<Void> {
            .init { resolve, _ in
                set(
                    key: key,
                    value: value
                ) {
                    resolve(())
                }
            }
    }
}

extension PendingOps {
    static func read(storage: Storage) -> Promise<PendingOps> {
            .init { resolve, _ in
                read(
                    storage: storage,
                    completion: resolve
                )
            }
    }
    
    func append(_ frame: String) -> Promise<Void> {
            .init { resolve, _ in
                self.append(frame) {
                    resolve(())
                }
            }
    }
}

public extension Client {
    struct Meta : Codable {
        public enum ClockMode : String, Codable {
            case logical = "logical"
            case calendar = "calendar"
        }
        
        var id: String?
        var name: String?
        var clockMode: ClockMode?
        var clockCount: Int?
        var forkMode: String?
        var peerIdBits: Int?
        var horizont: Int?
        var auth: String?
        var seen: String?
        var offset: TimeInterval?
        var _0: TimeInterval?
        
        public init(id: String? = nil,
                    name: String? = nil,
                    clockMode: ClockMode? = nil,
                    clockCount: Int? = nil,
                    forkMode: String? = nil,
                    peerIdBits: Int? = nil,
                    horizont: Int? = nil,
                    auth: String? = nil,
                    seen: String? = nil,
                    offset: TimeInterval? = nil,
                    _0: TimeInterval? = nil) {
            self.id = id
            self.name = name
            self.clockMode = clockMode
            self.clockCount = clockCount
            self.forkMode = forkMode
            self.peerIdBits = peerIdBits
            self.horizont = horizont
            self.auth = auth
            self.seen = seen
            self.offset = offset
            self._0 = _0
        }
        
        public func unioning(_ other: Self) -> Self {
            Self(
                id: other.id ?? id,
                name: other.name ?? name,
                clockMode: other.clockMode ?? clockMode,
                clockCount: other.clockCount ?? clockCount,
                forkMode: other.forkMode ?? forkMode,
                peerIdBits: other.peerIdBits ?? peerIdBits,
                horizont: other.horizont ?? horizont,
                auth: other.auth ?? auth,
                seen: other.seen ?? seen,
                offset: other.offset ?? offset,
                _0: other._0 ?? _0
            )
        }
    }
    
    struct Options {
        public enum Upstream {
            case string(String)
            case connection(Connection)
        }
        
        public var storage: Storage
        public var upstream: Upstream?
        public var hsTimeout: Int?
        public var fetchTimeout: Int?
        public var resendAfter: Int?
        public var db: Meta?
        
        public init(storage: Storage,
                    upstream: Upstream? = nil,
                    hsTimeout: Int? = nil,
                    fetchTimeout: Int? = nil,
                    resendAfter: Int? = nil,
                    db: Meta? = nil) {
            self.storage = storage
            self.upstream = upstream
            self.hsTimeout = hsTimeout
            self.fetchTimeout = fetchTimeout
            self.resendAfter = resendAfter
            self.db = db
        }
    }
    
    static var defaultMeta: Meta {
            .init(
                name: "default",
                clockCount: 5,
                forkMode: "// FIXME",
                peerIdBits: 30,
                horizont: 604800,
                offset: 0
            )
    }
}

extension Encodable {
    func stringify() throws -> String {
        let data = try JSONEncoder().encode(self)
        return .init(
            data: data,
            encoding: .utf8
        )!
    }
}

extension Decodable {
    static func jsonify(_ string: String) throws -> Self {
        let data = string.data(using: .utf8)!
        return try JSONDecoder().decode(
            Self.self,
            from: data
        )
    }
}

extension Dictionary where Key == String {
    func asInstance<T>(_ type: T.Type? = nil) throws -> T where T : Decodable {
        let data = try JSONSerialization.data(withJSONObject: self)
        return try JSONDecoder().decode(
            T.self,
            from: data
        )
    }
}
