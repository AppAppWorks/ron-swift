//
//  File.swift
//  
//
//  Created by Lau Chun Kai on 9/7/2021.
//

import XCTest
@testable import RonRdt
import RonCore

final class LwwTests : XCTestCase {
    func testReduce() {
        let cases = [
            [
              // 0+o
              "*lww#test!",
              "*lww#test@time:a'A'",
              "*lww#test@time!:a'A'",
            ],
            [
              // s+o
              "*lww#test@1!:a'A'",
              "*lww#test@2:b'B'",
              "*lww#test@2!@1:a'A'@2:b'B'",
            ],
            [
              // o+o
              "*lww#test@1:a'A1'",
              "*lww#test@2:a'A2'",
              "*lww#test@2!:a'A2'",
            ],
            [
              // p+p
              "*lww#test@1:d! :a'A1':b'B1':c'C1'",
              "*lww#test@2:d! :a'A2':b'B2'",
              "*lww#test@2!:a'A2':b'B2'@1:c'C1'",
            ],
            [
              "*lww#test@0ld!@new:key'new_value'",
              "*lww#test@new:key'new_value'",
              "*lww#test@new!:key'new_value'",
            ],
            [
              "#1X8C30K+user!",
              "*lww#1X8C30K+user@1X8C30M+user!:some'value'",
              "*lww#1X8C30K+user@1X8C30M+user!:some'value'",
            ],
            [
              "*lww#1_A8H+1_A8Gu71@1_A8Ic8F01+1_A8Gu71!:completed>true",
              "*lww#1_A8H+1_A8Gu71@1_A8HE8C02+1_A8Gu71!:completed>false:title'third'",
              "*lww#1_A8H+1_A8Gu71@1_A8Ic8F01+1_A8Gu71!:completed>true@(HE8C02+:title'third'",
            ],
            [
              "*lww#1_AAuOCD01+1_AAuJN~@1_AAvY5201+1_AAvK_p!:completed>false@(uOCz01+(uJN~:title'sixth'",
              "*lww#1_AAuOCD01+1_AAuJN~@1_AAvQ2c01+1_AAvJZk!:completed>true",
              "*lww#1_AAuOCD01+1_AAuJN~@1_AAvY5201+1_AAvK_p!:completed>false@(uOCz01+(uJN~:title'sixth'",
            ],
          ]

          for c in cases {
            let result = c.last!
            XCTAssertEqual(Lww.reduce(batch: Batch(c.dropLast())).toString(), result)
          }
    }
    
    func testMapToJs() throws {
        let array_ron = "*lww#array@2!@1:~%=0@2:%1'1':%2=1:%3=2:%4>notexists"
        let (obj, _) = try Lww.ronToJs(rawFrame: array_ron)
        XCTAssert(obj == [
            "0": .int(0),
            "1": .string("1"),
            "2": .int(1),
            "3": .int(2),
            "4": .uuid(.fromString("notexists")),
        ])
        XCTAssertEqual(obj.id, "array")
        XCTAssertEqual(obj.type, .fromString("lww"))
        XCTAssertEqual(obj.version, "2")
        XCTAssertEqual(obj.length, 5)
        XCTAssertEqual(obj.sorted { $0.key < $1.key }.map(\.value), [
            .int(0),
            .string("1"),
            .int(1),
            .int(2),
            .uuid(.fromString("notexists")),
        ])
        
        let objectRon = "*lww#obj@2:d!:a'A2':b'B2'@1:c'C1'"
        try XCTAssert(Lww.ronToJs(rawFrame: objectRon).0 == [ "a": .string("A2"), "b": .string("B2"), "c": .string("C1") ])
        
        let arrayRef = "*lww#ref@t-o!:~%=1:%1=2:%2>arr"
        try XCTAssert(Lww.ronToJs(rawFrame: arrayRef).0 == [
            "0": .int(1),
            "1": .int(2),
            "2": .uuid(.fromString("arr")),
        ])
        
          let lww = "*lww#test@time-orig!:key=1:obj>time1-orig"
        try XCTAssert(Lww.ronToJs(rawFrame: lww).0 == ["key": .int(1), "obj": .uuid(.fromString("time1-orig"))])
        
          let arrayNo = "*lww#ref@t-o!:key>arr:~%=1:~%1=2"
//          expect((ron2js(array_no) || { length: 42 }).length).toBeUndefined();
        try XCTAssertFalse(Lww.ronToJs(rawFrame: arrayNo).isNormal)
        
        let withRefs = """
          #left@2! :key'value'
          #right@3! :number=42
          *lww#root@1! :one>left :two>right
           .
          """
        try XCTAssert(Lww.ronToJs(rawFrame: withRefs).0 == [
            "one": .uuid(.fromString("left")),
            "two": .uuid(.fromString("right")),
        ])
        
        try XCTAssert(Lww.ronToJs(rawFrame: "*lww#1ABC4+user@1ABC7+user!:active>false").0 == [
            "active": .bool(false),
        ])
        
        let t =
            "*lww#1ABC1+user@1ABC3+user!:a=42:b'wat':c^0.1:d>false:e>true:f>1ABC2+user"
        try XCTAssert(Lww.ronToJs(rawFrame: t).0 == [
            "a": .int(42),
            "b": .string("wat"),
            "c": .double(0.1),
            "d": .bool(false),
            "e": .bool(true),
            "f": .uuid(.fromString("1ABC2+user")),
        ])
    }
    
    func testOverride() throws {
        try XCTAssert(Lww.ronToJs(rawFrame: "*lww#10001+demo@10004+demo!:completed>true@(2+:title'123':completed>false").0 == [
            "title": .string("123"),
            "completed": .bool(true),
        ])
    }
}
