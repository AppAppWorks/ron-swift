//
//  StorageTests.swift
//  
//
//  Created by Lau Chun Kai on 16/7/2021.
//

import XCTest
@testable import RonClient

final class InMemoryTests : XCTestCase {
    static var store = InMemory()
    
    func test1_InitialState() {
        XCTAssertEqual(Self.store.storage, [:])
    }
    
    func test2_Set() {
        let exp = expectation(description: "")
        Self.store.set(
            key: "foo",
            value: "bar"
        ) {
            exp.fulfill()
        }
        wait(for: [exp], timeout: .infinity)
    }
    
    func test3_Get() {
        let exp = expectation(description: "")
        Self.store.get(key: "foo") {
            XCTAssertEqual($0, "bar")
            exp.fulfill()
        }
        wait(for: [exp], timeout: .infinity)
    }
    
    func test4_Keys() {
        let exp = expectation(description: "")
        Self.store.keys {
            XCTAssertEqual($0, ["foo"])
            exp.fulfill()
        }
        wait(for: [exp], timeout: .infinity)
    }
    
    func test5_Remove() {
        let exp = expectation(description: "")
        Self.store.remove(key: "foo") {
            Self.store.get(key: "foo") {
                XCTAssertNil($0)
                exp.fulfill()
            }
        }
        wait(for: [exp], timeout: .infinity)
    }
    
    func test6_Merge() {
        let exp = expectation(description: "")
        var count = [0]
        
        func completion(expected: String?) -> (String?) -> Void {
            {
                XCTAssertEqual(expected, $0)
                count[0] += 1
                if count[0] == 6 {
                    exp.fulfill()
                }
            }
        }
        
        func merge(_ n: Int) -> (String?) -> String? {
            {
                "\($0 ?? "")\(n)"
            }
        }
        
        Self.store.merge(
            key: "~",
            reduce: merge(0),
            completion: completion(expected: "0")
        )
        Self.store.merge(
            key: "~",
            reduce: merge(1),
            completion: completion(expected: "01")
        )
        Self.store.merge(
            key: "~",
            reduce: merge(2),
            completion: completion(expected: "012")
        )
        Self.store.merge(
            key: "~",
            reduce: merge(3),
            completion: completion(expected: "0123")
        )
        Self.store.merge(
            key: "~",
            reduce: merge(4),
            completion: completion(expected: "01234")
        )
        Self.store.merge(
            key: "~",
            reduce: merge(5),
            completion: completion(expected: "012345")
        )
        
        wait(
            for: [exp],
            timeout: .infinity
        )
    }
}
