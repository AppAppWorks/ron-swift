//
//  File.swift
//  
//
//  Created by Lau Chun Kai on 14/7/2021.
//

import XCTest
@testable import RonRdt
import RonCore

final class LogTests : XCTestCase {
    func testReduce() {
        let cases = [["*log#id!@2+B:b=2@1+A:a=1", "*log#id@3+C:c=3@1+A:a=1", "*log#id@3+C!:c=3@2+B:b=2@1+A:a=1"]]
        
        for c in cases {
            let result = c.last!
            XCTAssertEqual(Log.reduce(batch: Batch(c.dropLast())).toString(), result)
        }
    }
}
