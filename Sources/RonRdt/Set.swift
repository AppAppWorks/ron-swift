//
//  File.swift
//  
//
//  Created by Lau Chun Kai on 8/7/2021.
//

import Foundation
import RonCore

private var heap = IHeap(primary: Set.comparator,
                         secondary: refComparatorDesc)

public enum Set {}

public extension Set {
    static let type = Uuid.fromString("set")
}

extension Set {
    static func ronToJs(rawFrame: String) -> Js {
        let set = Frame(str: rawFrame)
        var latest = Uuid.zero
        var id = ""
        var values = Swift.Set<String>()
        var storage = [String : Atom]()
        var uuid = Uuid.zero
        var length = 0
        
        for var op in set {
            if op.event > latest {
                latest = op.event
            }
            if id.isEmpty {
                id = op.uuid(.one).toString()
                uuid = op.uuid(.one)
            }
            guard op.uuid(.one) == uuid && op.isRegular else { continue }
            if !op.values.isEmpty && !values.contains(op.values) {
                values.insert(op.values)
                storage["\(length)"] = op.value(0)
                length += 1
            }
        }
        
        return .init(
            storage: storage,
            id: id,
            uuid: uuid,
            type: type,
            version: latest.toString(),
            length: length
        )
    }
    
    static func comparator(a: Op, b: Op) -> ComparisonResult {
        let ae = a.uuid(.three).isZero ? a.uuid(.two) : a.uuid(.three)
        let be = b.uuid(.three).isZero ? b.uuid(.two) : b.uuid(.three)
        return be.compare(ae)
    }
    
    /// Set, fully commutative, with tombstones.
    /// You can either add or remove an atom/tuple.
    /// Equal elements possible.
    static func reduce(batch: Batch, specialType: Uuid? = nil) -> Frame {
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
                        type: specialType ?? type,
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

//export default { reduce, type, setComparator, ron2js };
