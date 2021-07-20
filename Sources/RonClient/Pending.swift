//
//  Pending.swift
//  
//
//  Created by Lau Chun Kai on 16/7/2021.
//

import Foundation
import RonCore

private let KEY = "__pending__"

/// A wrapper for convenience and to work with pending
/// ops in an efficient way.
class PendingOps {
    enum Error : Swift.Error {
        case malformedOp(String)
    }
    
    var storage: Storage
    var ops: [String]
    var onIdle: () -> Void = {}
    var period: Int = 0
    var workItem: DispatchWorkItem?
    var seen: Uuid = .zero
    var queue: DispatchQueue
    
    required init(storage: Storage,
                  ops: [String],
                  queue: DispatchQueue = .main) {
        self.storage = storage
        self.ops = ops
        self.queue = queue
    }
    
    func setIdlePeriod(_ period: Int) {
        self.period = period
        check()
    }
    
    func check() {
        workItem?.cancel()
        workItem = nil
        if !ops.isEmpty {
            onIdle()
        }
        if period > 0 {
            workItem = .init(block: check)
            queue.asyncAfter(
                deadline: .now() + .milliseconds(period),
                execute: workItem!
            )
        }
    }
    
    func append(_ frame: String,
                completion: @escaping () -> Void) {
        ops.append(frame)
        completion()
    }
    
    func release(ack: Uuid,
                 completion: @escaping (Result<Void, Swift.Error>) -> Void) {
        guard seen <= ack else {
            return completion(.success(()))
        }
        seen = ack
        var i = -1
        for _old in ops {
            i += 1
            guard let old = Op(body: _old) else {
                return completion(.failure(Error.malformedOp(_old)))
            }
            
            if old.event > ack {
                ops.removeFirst(i + 1)
            }
        }
        if i == ops.count - 1 {
            ops.removeAll()
        }
        
        flush(completion: completion)
    }
    
    func flush(completion: @escaping (Result<Void, Swift.Error>) -> Void) {
        do {
            let data = try JSONEncoder().encode(ops)
            storage.set(
                key: KEY,
                value: String(data: data, encoding: .utf8)!
            ) {
                completion(.success(()))
            }
        } catch {
            completion(.failure(error))
        }
    }
    
    static func read(storage: Storage,
                     completion: @escaping (Self) -> Void) {
        storage.get(key: KEY) { pending in
            let jsonString = pending ?? "[]"
            let jsonData = jsonString.data(using: .utf8)!
            completion(
                try! .init(
                    storage: storage,
                    ops: JSONDecoder()
                        .decode(
                            [String].self,
                            from: jsonData
                        )
                )
            )
        }
    }
}

extension PendingOps : Sequence {
    func makeIterator() -> IndexingIterator<[String]> {
        ops.makeIterator()
    }
    
    var count: Int {
        ops.count
    }
}
