//
//  File.swift
//  
//
//  Created by Lau Chun Kai on 30/7/2021.
//

import XCTest
@testable import RonCore_xx

final class MetaTests : XCTestCase {
    func testIncStack() {
        var incStack = IncStack<Ron.FSize>()
        (0..<1000).forEach {
            incStack.append($0)
        }
        XCTAssertEqual(incStack.count, 1000)
        XCTAssertEqual(incStack.spanCount, 1)
        incStack.append(0)
        XCTAssertEqual(incStack.count, 1001)
        XCTAssertEqual(incStack.spanCount, 2)
        
        for (l, i) in incStack.enumerated() {
            XCTAssert(i == l % 1000)
        }
        XCTAssertEqual(incStack.count, 1001)
        
        incStack.popLast()
        incStack.popLast()
        XCTAssertEqual(incStack.count, 999)
        XCTAssertEqual(incStack.spanCount, 1)
    }
}
