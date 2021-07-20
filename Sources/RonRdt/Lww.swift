//
//  File.swift
//  
//
//  Created by Lau Chun Kai on 9/7/2021.
//

import Foundation
import RonCore

private var heap = IHeap(primary: refComparator, secondary: eventComparatorDesc)

/// Last-write-wins
public enum Lww {
    enum Error : Swift.Error {
        case nonFlattenArray
    }
    
    static func ronToJs(rawFrame: String) throws -> (Js, isNormal: Bool) {
        let set = Frame(str: rawFrame)
        var latest = Uuid.zero
        var id = ""
        var storage = [String : Atom]()
        var uuid = Uuid.zero
        var length = 0
        
        for var op in set.unzip.reversed() {
            if id.isEmpty {
                id = op.uuid(.one).toString()
                uuid = op.uuid(.one)
                latest = op.event
            }
            guard op.uuid(.one) == uuid && op.isRegular else { continue }
            
            let value = op.value(.zero)
            
            let key: String
            if op.location.isHash {
                if op.location.value != "~" {
                    throw Error.nonFlattenArray
                }
                key = op.location.origin
            } else {
                key = op.location.toString()
            }
            if length > -1 {
                if let p = Int(key) {
                    length = max(p + 1, length)
                } else {
                    length = -1
                }
            }
            storage[key] = value
        }
        
        return (.init(
            storage: storage,
            id: id,
            uuid: uuid,
            type: type,
            version: latest.toString(),
            length: length
        ),
        storage.count > 1 && length > 0)
    }
}

public extension Lww {
    static let type = Uuid.fromString("lww")
}

extension Lww {
    /// Last-write-wins reducer.
    static func reduce(batch: Batch) -> Frame {
        let _batch = batch.filter { !$0.body.isEmpty }
        var ret = Frame()
        guard !_batch.isEmpty else { return ret }
        let batch = _batch.sorted().reversed()
        
        guard batch.count != 1 else {
            return batch.first!
        }
        
        let frames = Array(batch)
        let newBatch = Batch(frames)
        
        for frame in frames {
            for op in frame {
                ret.append(
                    .init(
                        type: type,
                        object: op.uuid(.one),
                        event: op.uuid(.two),
                        location: .zero,
                        term: Op.Sep.frame
                    )
                )
                
                heap.clear()
                heap.insert(newBatch)
                
                while let current = heap.current {
                    ret.append(current,
                               term: .comma)
                    _ = heap.nextPrim()
                }
                return ret
            }
        }
        
        return ret
    }
}
