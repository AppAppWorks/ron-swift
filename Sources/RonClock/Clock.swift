//
//  File.swift
//  
//
//  Created by Lau Chun Kai on 15/7/2021.
//

import Foundation
import RonCore

public protocol Clock {
    mutating func time() throws -> Uuid
    var last: Uuid { get }
    mutating func see(uuid: Uuid) throws -> Bool
    var origin: String { get }
    mutating func adjust(_ event: Uuid) throws -> TimeInterval
    mutating func adjust(_ event: TimeInterval) throws -> TimeInterval
    func isSane(event: Uuid) -> Bool
}

public enum ClockLast {
    case string(String)
    case uuid(Uuid)
    
    var uuid: Uuid {
        switch self {
        case let .string(string):
            return .fromString(string)
        case let .uuid(uuid):
            return uuid
        }
    }
}
