//
//  Connection.swift
//  
//
//  Created by Lau Chun Kai on 16/7/2021.
//

import Foundation
import RonCore

public struct MessageEvent {
    var data: String
}

public struct Event {
    var type: String
}

public protocol Connection {
    var onMessage: ((MessageEvent) -> Void)? { get set }
    var onOpen: ((Event) -> Void)? { get set }
    func send(data: String)
    var readyState: Int { get }
    func close()
    func open()
}

// DevNull connection is used for permanent offline-mode
public class DevNull : Connection {
    public var onMessage: ((MessageEvent) -> Void)?
    public var onOpen: ((Event) -> Void)?
    public let readyState = 0
    
    public func send(data: String) {
        guard let onMessage = onMessage else { return }
        let frame = Frame(str: data)
        guard frame.isPayload else { return }
        for op in frame {
            if op.uuid(.two) != .zero {
                onMessage(
                    .init(data: "@\(op.uuid(.two).toString())!")
                )
                return
            }
        }
    }
    
    public func close() {
        
    }
    
    public func open() {
        
    }
}

