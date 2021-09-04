//
//  Const.swift
//  
//
//  Created by Lau Chun Kai on 22/7/2021.
//

import Foundation

public enum Ron {}

public extension Ron {
    @usableFromInline
    internal static let specPunct = "*#@:".utf8.createBufferPointer()!
    
    enum SpecType : Int {
        case type
        case object
        case event
        case ref
        
        @inlinable
        public var punct: UInt8 {
            Ron.specPunct[rawValue]
        }
    }
    
    @usableFromInline
    internal static let hexPunct = "0123456789abcdef".utf8.createBufferPointer()!
    
    @usableFromInline
    internal static let basePunct = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ_abcdefghijklmnopqrstuvwxyz~".utf8.createBufferPointer()!
    
    enum Term : Int {
        case raw
        case reduced
        case header
        case query
        
        @inlinable
        public var punct: UInt8 {
            switch self {
            case .raw: return ";"
            case .reduced: return ","
            case .header: return "!"
            case .query: return "?"
            }
        }
        
        @inlinable
        public init?(punct: UInt8) {
            switch punct {
            case ";": self = .raw
            case ",": self = .reduced
            case "!": self = .header
            case "?": self = .query
            case _: return nil
            }
        }
    }
    
    static let nl: UInt8 = "\n"
    static let dot: UInt8 = "."
    
    static let frameTerm = String(bytes: [dot, nl],
                                  encoding: .utf8)!
}

extension String.UTF8View {
    @inlinable
    @inline(__always)
    subscript(idx: Int) -> Element {
        withContiguousStorageIfAvailable {
            $0[idx]
        }!
    }
}

extension Substring.UTF8View {
    @inlinable
    @inline(__always)
    subscript(idx: Int) -> Element {
        withContiguousStorageIfAvailable {
            $0[idx]
        }!
    }
}

extension UnsafeMutableBufferPointer {
    @inline(__always)
    @usableFromInline
    static func transient<T>(capacity: Int,
                             body: (Self) throws -> T) rethrows -> T {
        let ptr = allocate(capacity: capacity)
        defer {
            ptr.deallocate()
        }
        return try body(ptr)
    }
    
    @inline(__always)
    @usableFromInline
    func prefix(_ address: UnsafeMutablePointer<Element>) -> SubSequence {
        prefix(address - baseAddress!)
    }
}

extension UnsafeMutablePointer {
    @inline(__always)
    @usableFromInline
    mutating func append(_ value: Pointee) {
        pointee = value
        self += 1
    }
}

extension Sequence {
    @inline(__always)
    @usableFromInline
    func createBufferPointer() -> UnsafeBufferPointer<Element>? {
        withContiguousStorageIfAvailable {
            let mBuf = UnsafeMutableBufferPointer<Element>.allocate(capacity: $0.count)
            _ = mBuf.initialize(from: $0)
            return .init(mBuf)
        }
    }
}
