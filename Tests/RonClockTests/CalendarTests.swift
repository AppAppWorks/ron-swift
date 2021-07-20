//
//  CalendarTests.swift
//
//
//  Created by Lau Chun Kai on 15/7/2021.
//

import XCTest
@testable import RonClock

final class CalendarTests : XCTestCase {
    func testBasic() throws {
        var clock = CalendarClock(origin: "orig")
        try clock.time()
        try XCTAssertLessThan(clock.time().toString(), clock.time().toString())
    }
    
    func testAdjust() throws {
        var clock = CalendarClock(
            origin: "orig",
            offset: 0,
            count: 7
        )
        let now = try clock.time()
        
        clock.offset = 86400
        let nextDay = try clock.time()
        
        XCTAssertEqual(clock.last.value, nextDay.value)
        try clock.adjust(now)
        
        XCTAssert(-0.1 < clock.offset && clock.offset < 0)
    }
}
