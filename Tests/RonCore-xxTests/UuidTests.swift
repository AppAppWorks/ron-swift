//
//  File.swift
//  
//
//  Created by Lau Chun Kai on 22/7/2021.
//

import Foundation
import XCTest
@testable import RonCore_xx

final class UuidTests : XCTestCase {
    let a = Ron.Codepoint("a" as UInt8)
    
    func testWordBitLayout() {
        var w = Ron.Word()
        
        XCTAssertEqual(MemoryLayout.size(ofValue: w), 8)
        
        w.cp = a
        XCTAssertEqual(w.cp, a)
        XCTAssertEqual(w.u32.0, a)
    }
    
    func testAtomBitLayout() {
        let str = Ron.Atom.string(cp: a,
                                  range: 0..<1,
                                  cpSize: 0)
        XCTAssertEqual(str.value.cp, a)
        
        let i = Ron.Atom.integer(i: -1,
                                 range: 0..<1)
        XCTAssertEqual(i.value.integer, -1)
        XCTAssertEqual(i.safeOrigin.range, 0..<1)
    }
    
    func testWordCase() {
        XCTAssertEqual(Ron.UUID.nil.value.base64Case, .numeric)
        XCTAssertEqual(Ron.UUID(buf: "2134").value.base64Case, .numeric)
        XCTAssertEqual(Ron.UUID(buf: "ABC~DEFZ").value.base64Case, .caps)
        XCTAssertEqual(Ron.UUID(buf: "Abc_Def").value.base64Case, .camel)
        XCTAssertEqual(Ron.UUID(buf: "abc_xyz").value.base64Case, .snake)
    }
    
    func testUuidAll() {
        XCTAssertEqual(MemoryLayout<Ron.Word>.size, 8)
        XCTAssertEqual(MemoryLayout<Ron.UUID>.size, 16)

        let u1: Ron.UUID = "0000000001"
        XCTAssertEqual(u1.value.u64, 1)
        XCTAssertEqual(u1.str, "0000000001")
        XCTAssertEqual(u1.version, .name)

        let test = Ron.UUID(buf: "test")
        let testStr = test.str
        XCTAssertEqual(testStr, "test")

        let subsCFUuid = Ron.UUID(value: 1007006897032658944,
                                  origin: 0)
        XCTAssertEqual(subsCFUuid.str, "subs")

        let zeros: Ron.UUID = "abc000$0"
        XCTAssertEqual(zeros.str, "abc")
        XCTAssertEqual("0/100+200" as Ron.UUID, "1+2")

        let one = Ron.UUID.time(value: 1,
                                origin: "origin")
        XCTAssertEqual(one.version, .time)
        XCTAssertEqual(one.derived.version, .derived)
        XCTAssertEqual(one.str, "0000000001+origin")
        let two = one + 1
        XCTAssertEqual(two.str, "0000000002+origin")
        XCTAssertEqual(two.derived.str, "0000000002-origin")

        XCTAssertLessThan(one, one.derived)
        XCTAssertEqual(one, one)
        XCTAssertGreaterThan(two, one)
        XCTAssertLessThan(one, two)
        XCTAssertNotEqual(one, two)

        let led: Ron.UUID = "A/LED"
        XCTAssertEqual(led.version, .name)
        XCTAssertEqual(led.variety, 10)
        XCTAssertEqual(led.str, "A/LED")
    }
}
