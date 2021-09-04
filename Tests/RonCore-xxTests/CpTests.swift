//
//  File.swift
//  
//
//  Created by Lau Chun Kai on 1/8/2021.
//

import XCTest
@testable import RonCore_xx

final class CpTests : XCTestCase {
    typealias Frame = Ron.TextFrame
    typealias Cursor = Frame.Cursor
    typealias Builder = Frame.Builder
    
    func testUtf8() {
        let latin = "ABC".utf8.createBufferPointer()!
        var latinCp = Ron.Codepoints()
        XCTAssertEqual(latinCp.parseUtf8(from: latin), .ok)
        XCTAssert(latin[0] == latinCp[0])
        XCTAssert(latin[1] == latinCp[1])
        XCTAssert(latin[2] == latinCp[2])
        
        let raw = "Юникод\t萬國碼"
        var rawCp = Ron.Codepoints()
        XCTAssertEqual(rawCp.parseUtf8(from: raw), .ok)
        XCTAssertEqual(rawCp.count, 10)
        XCTAssertEqual(rawCp[5], 0x0434)
    }
}
