//
//  LogicalTests.swift
//  
//
//  Created by Lau Chun Kai on 15/7/2021.
//

import XCTest
@testable import RonClock

final class LogicalTests : XCTestCase {
    func testBasic() {
        var clock = LogicalClock(origin: "test")
        XCTAssertEqual(clock.time().toString(), "(1+test")
        XCTAssertEqual(clock.time().toString(), "(2+test")
        XCTAssertEqual(clock.time().toString(), "(3+test")
        clock.see(uuid: .fromString("(6+test"))
        XCTAssertEqual(clock.time().toString(), "(7+test")
        
        var clock10 = LogicalClock(
            origin: "orig",
            count: 10,
            last: .string("(5+other")
        )
        XCTAssertEqual(clock10.time().toString(), "(500001+orig")
    }
}
