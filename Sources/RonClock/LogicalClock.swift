//
//  File.swift
//  
//
//  Created by Lau Chun Kai on 15/7/2021.
//

import Foundation
import RonCore

/// Pure logical clock.
public struct LogicalClock : Clock {
    public internal(set) var origin: String
    public internal(set) var last: Uuid
    public internal(set) var count: Int
}

public extension LogicalClock {
    init(origin: String,
         count: Int? = nil,
         last: ClockLast? = nil) {
        self.origin = origin
        self.last = last?.uuid ?? .zero
        self.count = count ?? 5
    }
    
    /// Generates a fresh globally unique monotonous UUID.
    mutating func time() -> Uuid {
        var t = last.value
        while t.count < count {
            t += "0"
        }
        let i = t.filter { $0 != "~" }.count - 1
        guard i >= 0 else { return .error }
        let value = t.prefix(i) + String(
            Unicode.Scalar(
                UInt8(
                    Uuid.base64[
                        Int(Uuid.codes[
                                Int(t.utf8CString[i])
                        ]) + 1
                    ]
                )
            )
        )
        last = .init(value: String(value), origin: origin, sep: "+")
        return last
    }
    
    /// See an UUID. Can only generate larger UUIDs afterwards.
    @discardableResult
    mutating func see(uuid: Uuid) -> Bool {
        if isSane(event: uuid) && last < uuid {
            last = uuid
            return true
        }
        return false
    }
    
    func adjust(_ event: TimeInterval) -> TimeInterval {
        0
    }
    
    mutating func adjust(_ event: Uuid) -> TimeInterval {
        see(uuid: event)
        return 0
    }
    
    func isSane(event: Uuid) -> Bool {
        !event.value.isEmpty && event.value < "~"
    }
}
