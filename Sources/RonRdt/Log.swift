//
//  File.swift
//  
//
//  Created by Lau Chun Kai on 14/7/2021.
//

import RonCore

private var heap = IHeap(primary: eventComparatorDesc)

public enum Log {
    public static let type = Uuid.fromString("log")
}

extension Log {
    static func reduce(batch: Batch) -> Frame {
        var ret = Frame()
        guard !batch.isEmpty else { return ret }
        
        guard batch.count != 1 else {
            return batch.first!
        }
        
        let frames = Array(batch)
        for frame in frames {
            for op in frame {
                var head = Op(
                    type: type,
                    object: op.uuid(.one),
                    event: op.uuid(.two),
                    location: .zero,
                    term: Op.Sep.frame
                )
                if let theLastOne = Op(body: frames.last!.toString()) {
                    head.event = theLastOne.event
                }
                
                ret.append(head)
                
                heap.clear()
                heap.insert(batch)
                
                while let current = heap.current, current.event.sep == "+" {
                    ret.append(current, term: .comma)
                    _ = heap.nextPrim()
                }
                return ret
            }
        }
        
        return ret
    }
}
