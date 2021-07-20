//
//  File.swift
//  
//
//  Created by Lau Chun Kai on 21/7/2021.
//

import Foundation
import XCTest
import RonCore
import RonClient
import RonApi

final class NewTests : XCTestCase {
    func testNewApi() throws {
        let api = try API(
            options: .init(
                clntOps: .init(
                    storage: InMemory(),
                    upstream: .connection(FixConnection(fixtures: "002-hs.ron")),
                    db: .init(
                        id: "user",
                        name: "test",
                        clockMode: .logical,
                        auth: "JwT.t0k.en"
                    )
                )
            )
        )
        
        let exp = expectation(description: "")
        
        api.ensure()
            .then {
                let upstream = api.client.upstream as! FixConnection
                XCTAssertEqual(upstream.session, upstream.fixtures)
                
                let meta = try JSONSerialization.jsonObject(with: (api.client.storage as! InMemory)
                                                                .storage["__meta__"]!
                                                                .data(using: .utf8)!) as! [String : Any]
                XCTAssert([
                    "name": "test",
                    "clockCount": 5,
                    "forkMode": "// FIXME",
                    "peerIdBits": 30,
                    "horizont": 604800,
                    "auth": "JwT.t0k.en",
                    "clockMode": "logical",
                    "id": "user",
                    "offset": 0,
                ] == meta)
                
                try XCTAssertEqual(api.uuid().toString(), "1ABC1+user")
                
                exp.fulfill()
            }
        
        wait(for: [exp], timeout: .infinity)
    }
}
