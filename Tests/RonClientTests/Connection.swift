//
//  File.swift
//  
//
//  Created by Lau Chun Kai on 20/7/2021.
//

import Foundation
@testable import RonClient
@testable import RonCore

var _id = 1

final class FixConnection : Connection {
    enum Error : Swift.Error {
        case unexpectedOp
    }
    
    var id: String
    
    var onMessage: ((MessageEvent) -> Void)?
    
    var onOpen: ((Event) -> Void)?
    
    var readyState: Int = 0
    
    var fixtures = [RawFrame]()
    var session = [RawFrame]()
    
    init(fixtures: String?, queue: DispatchQueue = .main) throws {
        _id += 1
        id = "#\(_id) \(fixtures ?? "")"
        
        if let fixtures = fixtures,
           let path = Bundle.module.path(
            forResource: fixtures,
            ofType: nil
           ) {
            let content = try String(
                contentsOfFile: path,
                encoding: .utf8
            )
            for chunk in content.components(separatedBy: ".\n") {
                guard !chunk.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                    continue
                }
                let frame = Frame(str: chunk)
                guard var op = (frame.first { _ in true }) else {
                    continue
                }
                if op.isComment && op.source?.isEmpty == false {
                    self.fixtures.append(
                        .init(
                            direction: op.value(0).jsonValue as! String,
                            body: String(frame.body.dropFirst(op.source!.count))
                        )
                    )
                } else {
                    throw Error.unexpectedOp
                }
            }
        }
        
        queue.async {
            self.onOpen?(.init(type: ""))
            self.pushPending()
        }
    }
    
    func open() {
        
    }
    
    func send(data: String) {
        session.append(
            .init(
                direction: ">",
                body: data
            )
        )
        pushPending()
    }
    
    func close() {
        
    }
    
    func pushPending() {
        var i = 0
        for raw in fixtures.dropFirst(session.count) {
            i += 1
            guard raw.direction == "<" else { break }
            session.append(raw)
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100 << i)) {
                self.onMessage?(
                    .init(data: raw.body)
                )
            }
        }
    }
}

struct RawFrame : CustomStringConvertible, Equatable {
    var direction: String
    var body: String
    
    var description: String {
        "*~ '\(direction)' \(body)."
    }
    
    var asJson: String {
        description
    }
}
