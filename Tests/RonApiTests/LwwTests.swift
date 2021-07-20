//
//  File.swift
//  
//
//  Created by Lau Chun Kai on 20/7/2021.
//

import Foundation
import XCTest
import RonCore
@testable import RonClient
@testable import RonApi

final class LwwTests : XCTestCase {
    func testApiSet() throws {
        let exp = expectation(description: "")
        
        let storage = InMemory()
        let connection = try FixConnection(fixtures: "006-lwwset.ron")
        let api = API(
            options: .init(
                clntOps: .init(
                    storage: storage,
                    upstream: .connection(connection),
                    db: .init(
                        id: "user",
                        name: "test",
                        clockMode: .logical,
                        auth: "JwT.t0k.en"
                    )
                )
            )
        )
        
        var obj = [(id: String, state: String?)]()
        let callback = Client.CallBack {
            obj.append(($0, $1))
        }
        
        api.ensure()
            .then {
                
                return api.client.on(query: "#object", callback: callback)
            }
            .then { (_: Bool) in
                api.set(
                    id: .string("object"),
                    value: ["username": .string("olebedev"),]
                )
            }
            .then { _ in
                XCTAssertEqual(storage.storage["object"], "*lww#object@1ABC1+user!:username'olebedev'")
                return api.set(
                    id: .string("object"),
                    value: ["email": .string("ole6edev@gmail.com"),]
                )
            }
            .then { (_: Bool) in
                XCTAssertEqual(storage.storage["object"], "*lww#object@1ABC2+user!:email'ole6edev@gmail.com'@(1+:username'olebedev'")
                return api.set(
                    id: .string("object"),
                    value: ["email": .removal,]
                )
            }
            .then { (_: Bool) in
                XCTAssertEqual(storage.storage["object"], "*lww#object@1ABC3+user!:email,@(1+:username'olebedev'")
                XCTAssertEqual(Array(api.client.lstn.keys), ["object"])
                XCTAssertEqual(api.client.lstn["object"]?.count, 1)
                
                let profileUuid = try api.uuid()
                return api.client.on(
                    query: "#" + profileUuid.toString(),
                    callback: callback
                )
                    .then { _ in
                    .resolve(profileUuid)
                    }
            }
            .then { (profileUuid: Uuid) in
                api.set(
                    id: .string("object"),
                    value: ["profile": .uuid(profileUuid)]
                )
                    .then { _ in
                    .resolve(profileUuid)
                    }
            }.then { (profileUuid: Uuid) in
                XCTAssertEqual(storage.storage["object"], "*lww#object@1ABC5+user!@(3+:email,@(5+:profile>1ABC4+user@(1+:username'olebedev'")
                
                XCTAssert(obj == [
                    (
                        id: "#object",
                        state: nil
                    ),
                    (
                        id: "#object",
                        state: "*lww#object@1ABC1+user!:username'olebedev'"
                    ),
                    (
                        id: "#object",
                        state: "*lww#object@1ABC2+user!:email'ole6edev@gmail.com'@(1+:username'olebedev'"
                    ),
                    (
                        id: "#object",
                        state: "*lww#object@1ABC3+user!:email,@(1+:username'olebedev'"
                    ),
                    (
                        id: "#1ABC4+user",
                        state: nil
                    ),
                    (
                        id: "#object",
                        state:  "*lww#object@1ABC5+user!@(3+:email,@(5+:profile>1ABC4+user@(1+:username'olebedev'"
                    ),
                ])
                
                return api.set(
                    id: .uuid(profileUuid),
                    value: ["active": .bool(true)]
                )
                    .then { _ in
                    .resolve(profileUuid)
                    }
            }
            .then { (profileUuid: Uuid) in
                XCTAssertEqual(storage.storage[profileUuid.toString()], "*lww#1ABC4+user@1ABC6+user!:active>true")
                
                XCTAssert(obj == [
                    ( id: "#object", state: nil ),
                        ( id: "#object", state: "*lww#object@1ABC1+user!:username'olebedev'" ),
                        (
                          id: "#object",
                          state:
                            "*lww#object@1ABC2+user!:email'ole6edev@gmail.com'@(1+:username'olebedev'"
                        ),
                        (
                          id: "#object",
                          state: "*lww#object@1ABC3+user!:email,@(1+:username'olebedev'"
                        ),
                        ( id: "#1ABC4+user", state: nil ),
                        (
                          id: "#object",
                          state:
                            "*lww#object@1ABC5+user!@(3+:email,@(5+:profile>1ABC4+user@(1+:username'olebedev'"
                        ),
                        ( id: "#1ABC4+user", state: "*lww#1ABC4+user@1ABC6+user!:active>true" ),
                ])
                
                XCTAssert(api.client.lstn["object"] ?? [] === api.client.lstn["1ABC4+user"] ?? [])
                
                return api.set(
                    id: .uuid(profileUuid),
                    value: ["active": .bool(false)]
                )
                    .then { _ in
                    .resolve(profileUuid)
                    }
            }
            .then { (profileUuid: Uuid) in
                XCTAssertEqual(storage.storage[profileUuid.toString()], "*lww#1ABC4+user@1ABC7+user!:active>false")
                
                XCTAssert(obj == [
                    ( id: "#object", state: nil ),
                    ( id: "#object", state: "*lww#object@1ABC1+user!:username'olebedev'" ),
                    (
                        id: "#object",
                        state:
                            "*lww#object@1ABC2+user!:email'ole6edev@gmail.com'@(1+:username'olebedev'"
                    ),
                    (
                        id: "#object",
                        state: "*lww#object@1ABC3+user!:email,@(1+:username'olebedev'"
                    ),
                    ( id: "#1ABC4+user", state: nil ),
                    (
                        id: "#object",
                        state:
                            "*lww#object@1ABC5+user!@(3+:email,@(5+:profile>1ABC4+user@(1+:username'olebedev'"
                    ),
                    ( id: "#1ABC4+user", state: "*lww#1ABC4+user@1ABC6+user!:active>true" ),
                    ( id: "#1ABC4+user", state: "*lww#1ABC4+user@1ABC7+user!:active>false" ),
                ])
                
                return Promise { resolve, _ in
                    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500)) {
                        resolve(())
                    }
                }
            }
            .then { (_: Void) in
                let session = connection.session
                let fixtures = connection.fixtures
                XCTAssertEqual(session, fixtures)
                XCTAssertEqual(storage.storage["1ABC4+user"], "*lww#1ABC4+user@1ABC7+user!:active>false")
                
                let meta = try JSONSerialization.jsonObject(with: storage.storage["__meta__"]!.data(using: .utf8)!) as! [String : Any]                
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
                
                XCTAssertEqual(storage.storage["__pending__"], "[]")
                XCTAssertEqual(storage.storage["object"], "*lww#object@1ABD+olebedev!@1ABC3+user:email,@1ABD+olebedev:profile,@1ABC1+user:username'olebedev'")
                try XCTAssertEqual(api.uuid().toString(), "1ABD1+user")
                
                XCTAssert(obj == [
                    ( id: "#object", state: nil ),
                    ( id: "#object", state: "*lww#object@1ABC1+user!:username'olebedev'" ),
                    (
                      id: "#object",
                      state:
                        "*lww#object@1ABC2+user!:email'ole6edev@gmail.com'@(1+:username'olebedev'"
                    ),
                    (
                      id: "#object",
                      state: "*lww#object@1ABC3+user!:email,@(1+:username'olebedev'"
                    ),
                    ( id: "#1ABC4+user", state: nil ),
                    (
                      id: "#object",
                      state:
                        "*lww#object@1ABC5+user!@(3+:email,@(5+:profile>1ABC4+user@(1+:username'olebedev'"
                    ),
                    ( id: "#1ABC4+user", state: "*lww#1ABC4+user@1ABC6+user!:active>true" ),
                    ( id: "#1ABC4+user", state: "*lww#1ABC4+user@1ABC7+user!:active>false" ),
                    (
                      id: "#object",
                      state:
                        "*lww#object@1ABD+olebedev!@1ABC3+user:email,@1ABD+olebedev:profile,@1ABC1+user:username'olebedev'"
                    ),
                  ])
                
                return api.set(
                    id: .string("object"),
                    value: ["local": .uuid(.fromString("test").local)]
                )
            }
            .then { (set: Bool) in
                XCTAssertEqual(storage.storage["object"], "*lww#object@1ABD+olebedev!@1ABC3+user:email,@1ABD+olebedev:profile,@1ABC1+user:username'olebedev'")
                XCTAssertFalse(`set`)
                
                exp.fulfill()
            }
            .catch { _ in
                XCTFail()
                exp.fulfill()
            }
        
        
        wait(for: [exp], timeout: .infinity)
    }
}

extension Dictionary where Key == String, Value == Any {
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.allSatisfy { (k: String, v: Any) in
            switch (rhs[k], v) {
            case let (i1 as Int, i2 as Int):
                return i1 == i2
            case let (s1 as String, s2 as String):
                return s1 == s2
            case _:
                return false
            }
        }
    }
}

extension Array where Element : AnyObject {
    static func === (lhs: Self, rhs: Self) -> Bool {
        zip(lhs, rhs).allSatisfy(===)
    }
}

extension Array where Element == (String, String?) {
    static func == (lhs: Self, rhs: Self) -> Bool {
        zip(lhs, rhs).allSatisfy(==)
    }
}
