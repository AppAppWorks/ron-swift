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

final class SetTests : XCTestCase {
    func testSetAdd() throws {
        let storage = InMemory()
        let api = try API(
            options: .init(
                clntOps: .init(
                    storage: storage,
                    upstream: .connection(FixConnection(fixtures: "008-setadd.ron")),
                    db: .init(
                        id: "user",
                        name: "test",
                        clockMode: .logical,
                        auth: "JwT.t0k.en"
                    )
                )
            )
        )
        
        var obj = [(String, String?)]()
        let cbk = Client.CallBack { frame, state in
            obj.append((frame, state))
        }
        
        let exp = expectation(description: "")
        
        api.ensure()
            .then {
                api.client.on(
                    query: "#object",
                    callback: cbk
                )
            }
            .then { (_: Bool) in
                    .init { resolve, _ in
                        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(300)) {
                            resolve(())
                        }
                    }
            }
            .then { (_: Void) in
                api.append(
                    id: .string("object"),
                    value: .int(5)
                )
            }
            .then { ok in
                XCTAssert(ok)
                
                XCTAssert(obj == [
                    ( id: "#object", state: nil ),
                    ( id: "#object", state: "" ),
                    ( id: "#object", state: "*set#object@1ABC1+user!=5" ),
                ])
                
                return api.append(
                    id: .string("object"),
                    value: .int(5)
                )
            }
            .then { (_: Bool) in
                XCTAssert(obj == [
                    ( id: "#object", state: nil ),
                    ( id: "#object", state: "" ),
                    ( id: "#object", state: "*set#object@1ABC1+user!=5" ),
                    ( id: "#object", state: "*set#object@1ABC2+user!=5@(1+=5" ),
                ])
                
                return api.append(
                    id: .string("object"),
                    value: .int(42)
                )
            }
            .then { (ok: Bool) in
                XCTAssert(ok)
                
                XCTAssert(obj == [
                    ( id: "#object", state: nil ),
                    ( id: "#object", state: "" ),
                    ( id: "#object", state: "*set#object@1ABC1+user!=5" ),
                    ( id: "#object", state: "*set#object@1ABC2+user!=5@(1+=5" ),
                    ( id: "#object", state: "*set#object@1ABC3+user!=42@(2+=5@(1+=5" ),
                ])
                
                return .init { resolve, _ in
                    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500)) {
                        resolve(())
                    }
                }
            }
            .then { (_: Void) in
                XCTAssertEqual(storage.storage["__pending__"], "[]")
                try XCTAssertEqual(api.uuid().toString(), "1ABC7+user")
                
                let sub = try api.uuid()
                return api.client.on(
                    query: "#" + sub.toString(),
                    callback: cbk
                ).then { _ in
                        .resolve(sub)
                }
            }
            .then { (sub: Uuid) in
                api.append(
                    id: .string("object"),
                    value: .uuid(sub)
                ).then { _ in
                        .resolve(sub)
                }
            }
            .then { (sub: Uuid) in
                XCTAssert(obj == [
                    ( id: "#object", state: nil ),
                    ( id: "#object", state: "" ),
                    ( id: "#object", state: "*set#object@1ABC1+user!=5" ),
                    ( id: "#object", state: "*set#object@1ABC2+user!=5@(1+=5" ),
                    ( id: "#object", state: "*set#object@1ABC3+user!=42@(2+=5@(1+=5" ),
                    (id: "#1ABC8+user", state: nil),
                    (id: "#object", state: "*set#object@1ABC9+user!>1ABC8+user@(3+=42@(2+=5@(1+=5"),
                ])
                return .init { resolve, _ in
                    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(300)) {
                        resolve((sub))
                    }
                }
            }
            .then { (sub: Uuid) in
                api.append(
                    id: .uuid(sub),
                    value: .int(37)
                )
            }
            .then { (_: Bool) in
                XCTAssert(obj == [
                    ( id: "#object", state: nil ),
                    ( id: "#object", state: "" ),
                    ( id: "#object", state: "*set#object@1ABC1+user!=5" ),
                    ( id: "#object", state: "*set#object@1ABC2+user!=5@(1+=5" ),
                    ( id: "#object", state: "*set#object@1ABC3+user!=42@(2+=5@(1+=5" ),
                    (id: "#1ABC8+user", state: nil),
                    (id: "#object", state: "*set#object@1ABC9+user!>1ABC8+user@(3+=42@(2+=5@(1+=5"),
                    (id: "#1ABC8+user", state: ""),
                    (id: "#1ABC8+user", state: "*set#1ABC8+user@1ABCA+user!=37"),
                ])
                
                return .init { resolve, _ in
                    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(300)) {
                        resolve(())
                    }
                }
            }
            .then { (_: Void) in
                let stream = api.client.upstream as! FixConnection
                XCTAssertEqual(stream.session, stream.fixtures)
                XCTAssertEqual(storage.storage["object"], "*set#object@1ABC9+user!>1ABC8+user@(3+=42@(2+=5@(1+=5")
                
                return api.append(
                    id: .string("object"),
                    value: .uuid(.fromString("test").local)
                )
            }
            .then { (add: Bool) in
                XCTAssertEqual(storage.storage["object"], "*set#object@1ABC9+user!>1ABC8+user@(3+=42@(2+=5@(1+=5")
                XCTAssertFalse(add)
                
                exp.fulfill()
            }
        
        wait(for: [exp], timeout: .infinity)
    }
    
    func testSetRemove() throws {
        let storage = InMemory()
        let api = try API(
            options: .init(
                clntOps: .init(
                    storage: storage,
                    upstream: .connection(FixConnection(fixtures: "010-setrm.ron")),
                    db: .init(
                        id: "user",
                        name: "test",
                        clockMode: .logical,
                        auth: "JwT.t0k.en"
                    )
                )
            )
        )
        
        var obj = [(String, String?)]()
        let cbk = Client.CallBack { frame, state in
            obj.append((frame, state))
        }
        
        let exp = expectation(description: "")
        
        api.ensure()
            .then {
                api.client.on(
                    query: "#object",
                    callback: cbk
                )
            }
            .then { (_: Bool) in
                    .init { resolve, _ in
                        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500)) {
                            resolve(())
                        }
                    }
            }
            .then { (_: Void) in
                api.append(
                    id: .string("object"),
                    value: .int(5)
                )
            }
            .then { ok in
                XCTAssert(ok)
                
                XCTAssert(obj == [
                    ( id: "#object", state: nil ),
                    ( id: "#object", state: "" ),
                    ( id: "#object", state: "*set#object@1ABC1+user!=5" ),
                ])
                
                return api.remove(
                    id: .string("object"),
                    value: .int(4)
                )
            }
            .then { (rm: Bool) in
                XCTAssertFalse(rm)
                XCTAssert(obj == [
                    ( id: "#object", state: nil ),
                    ( id: "#object", state: "" ),
                    ( id: "#object", state: "*set#object@1ABC1+user!=5" ),
                ])
                
                XCTAssertEqual(storage.storage["object"], "*set#object@1ABC1+user!=5")
                
                return api.remove(
                    id: .string("object"),
                    value: .int(5)
                )
            }
            .then { (rm: Bool) in
                XCTAssert(rm)
                XCTAssert(obj == [
                    ( id: "#object", state: nil ),
                    ( id: "#object", state: "" ),
                    ( id: "#object", state: "*set#object@1ABC1+user!=5" ),
                    ( id: "#object", state: "*set#object@1ABC3+user!:1ABC1+user," ),
                ])
                
                XCTAssertNil(api.client.lstn["thisone"])
                
                return .init { resolve, _ in
                    api.client.on(
                        query: "#thisone",
                        callback: .init { resolve(($0, $1)) },
                        once: true,
                        ensure: true
                    )
                }
            }
            .then { (_: (String, String?)) in
                api.remove(
                    id: .string("thisone"),
                    value: .int(42)
                )
            }
            .then { rm in
                XCTAssert(rm)
                
                return .init { resolve, _ in
                    api.client.on(
                        query: "#thisone",
                        callback: .init {
                        resolve(($0, $1))
                        
                    }
                    )
                }
            }
            .then { (thisone: (String, String?)) in
                XCTAssert(thisone == (
                    id: "#thisone",
                    state: "*set#thisone@1ABC6+user!:1ABC5+user,"
                ))
                exp.fulfill()
            }
            .catch {
                XCTFail("\($0)")
            }
        
        wait(for: [exp], timeout: .infinity)
    }
}
