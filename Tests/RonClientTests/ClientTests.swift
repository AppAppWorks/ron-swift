//
//  File.swift
//  
//
//  Created by Lau Chun Kai on 16/7/2021.
//

import XCTest
@testable import RonClient

final class ClientTests : XCTestCase {
    func testPromise() {
        let exp = expectation(description: "")
        let promise = Promise { resolve, reject in
            Bool.random() ? resolve("!") : reject(AnError.first)
        }
        promise.then {
            print($0)
            if Bool.random() {
                throw AnError.then(0)
            } else {
                return .resolve("!!!")
            }
        }
        .then { (str: String) in
            print(str)
            if Bool.random() {
                throw AnError.then(1)
            } else {
                exp.fulfill()
            }
        }
        .catch {
            print($0)
            if Bool.random() {
                throw AnError.catch(0)
            } else {
                return .resolve("???")
            }
        }
        .then { (str: String) in
            print(str)
            exp.fulfill()
        }
        .catch {
            print($0)
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: .infinity)
    }
    
    func testStruct() throws {
        let dict = [
            "name": "optional",
        ]
        let jsonData = try JSONSerialization.data(withJSONObject: dict)
        let meta = try JSONDecoder()
            .decode(
                Client.Meta.self,
                from: jsonData
            )
        print(meta)
    }
}

enum AnError : Error {
    case first
    case `catch`(Int)
    case then(Int)
    case `self`
}
