//
//  File.swift
//  
//
//  Created by Lau Chun Kai on 19/7/2021.
//

import XCTest
@testable import RonClient
@testable import RonCore

final class InitTests : XCTestCase {
    func testConnection() throws {
        let conn = try FixConnection(fixtures: "001-conn.ron")
        XCTAssertEqual(conn.fixtures.map(\.asJson),
                       [
                        "*~ '>' *db#test@0+user?!'JwT.t0k.en'.",
                        "*~ \'<\' *db#test$user@1ABC+user!.",
                        "*~ \'>\' #object?.",
                        "*~ '<' *lww#object@time+author!:key'value'."
                       ])
        XCTAssertEqual(conn.fixtures[0].direction, ">")
    }
    
    func testClientNew() throws {
        let exp = expectation(description: "")
        
        let dq = DispatchQueue.global(qos: .background)
        let connection = try FixConnection(fixtures: "002-hs.ron")
        let client = Client(
            options: .init(
                storage: InMemory(),
                upstream: .connection(connection),
                db: .init(
                    id: "user",
                    name: "test",
                    clockMode: .logical,
                    auth: "JwT.t0k.en"
                )
            ),
            dispatchQueue: dq
        )
        
        client.ensure().then {
            let connection = client.upstream as! FixConnection
            XCTAssertEqual(connection.session, connection.fixtures)
            
            let inMemory = client.storage as! InMemory
            let meta = inMemory.storage["__meta__"]!
            let metaData = meta.data(using: .utf8)!
            let json = try JSONSerialization.jsonObject(with: metaData) as! [String : Any]
//            XCTAssertEqual(json, ["name": "test",
//                           "clockLen": 5,
//                           "forkMode": "// FIXME",
//                           "peerIdBits": 30,
//                           "horizont": 604800,
//                           "auth": "JwT.t0k.en",
//                           "clockMode": "Logical",
//                           "id": "user",
//                           "offset": 0,])
            XCTAssertEqual(client.clock?.last.toString(), "1ABC+server")
            try XCTAssertEqual(client.clock?.time().toString(), "1ABC1+user")
            exp.fulfill()
        }.catch {
            XCTFail("\($0)")
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: .infinity)
    }
    
    // init before connection
    func testClientReconnect() throws {
        let exp = expectation(description: "")
        
        let storage = InMemory()
        let meta = #"{"name":"test","clockCount":5,"forkMode":"// FIXME","peerIdBits":30,"horizont":604800,"# +
            #""credentials":{"password":"12345"},"clockMode":"logical"}"#
        storage.set(key: "__meta__", value: meta)
            .then {
                let dq = DispatchQueue.global(qos: .background)
                let client = try Client(
                    options: .init(
                        storage: storage,
                        upstream: .connection(
                            FixConnection(fixtures: "002-hs.ron")
                        ),
                        db: .init(id: "user")
                    ),
                    dispatchQueue: dq
                )
                
                client.ensure()
                    .then(exp.fulfill)
                    .catch {
                        XCTFail("\($0)")
                        exp.fulfill()
                    }
            }
        
        wait(for: [exp], timeout: .infinity)
    }
    
    func testClientWithoutClock() throws {
        let exp = expectation(description: "")
        
        let client = Client(
            options: .init(
                storage: InMemory(),
                db: .init(id: "user")
            )
        )
        
        client.ensure()
            .then(exp.fulfill)
            .catch { error in
                print(error)
                exp.fulfill()
            }
        
        wait(
            for: [exp],
            timeout: .infinity
        )
    }
    
    func testClientAssignedId() throws {
        let exp = expectation(description: "")
        
        let conn = try FixConnection(fixtures: "003-calendar-clock.ron")
        let client = Client(
            options: .init(
                storage: InMemory(),
                upstream: .connection(conn),
                db: .init(name: "test")
            )
        )
        
        client.ensure()
            .then {
                XCTAssertEqual(client.clock?.origin, "user")
                exp.fulfill()
            }.catch {
                XCTFail("\($0)")
                exp.fulfill()
            }
        
        wait(
            for: [exp],
            timeout: .infinity
        )
    }
}
