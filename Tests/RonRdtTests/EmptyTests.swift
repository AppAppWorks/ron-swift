//
//  File.swift
//  
//
//  Created by Lau Chun Kai on 15/7/2021.
//

import XCTest
@testable import RonRdt

final class EmptyTests : XCTestCase {
    func testZeroToJs() {
        let set = Js(rawFrame: "*set#test1!")
        XCTAssertEqual(set?.type, .fromString("set"))
        XCTAssertEqual(set?.id, "test1")
        XCTAssertEqual(set?.version, "0")
        XCTAssert(set! == [:])
        
        let set2 = Js(rawFrame: "#test1!")
        XCTAssertEqual(set2?.type, .fromString(""))
        XCTAssertEqual(set2?.id, "test1")
        XCTAssertEqual(set2?.version, "0")
        XCTAssert(set2! == [:])
    }
}
