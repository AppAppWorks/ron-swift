//
//  File.swift
//  
//
//  Created by Lau Chun Kai on 9/7/2021.
//

import XCTest
@testable import RonRdt
import RonCore

final class SetTests : XCTestCase {
    func testReduce() {
        let fixtures = [
            ["*set#test1@1!@=1", "*set#test1@2:1;", "*set#test1@2!:1,"],
            ["*set#test1@3:1;", "*set#test1@4:2;", "*set#test1@4!:2,@3:1,"],
            [
              "*set#test1@2!@=2@1=1",
              "*set#test1@5!@=5@3:2,@4:1,",
              "*set#test1@5!=5@3:2,@4:1,",
            ],
            [
              "*set#test1@2!@=2@1=1",
              "*set#test1@3!@:2,@4:1,",
              "*set#test1@5!@=5",
              "*set#test1@5!=5@3:2,@4:1,",
            ],
            [
              "*set#test1@3!@:2,@4:1,",
              "*set#test1@5!@=5",
              "*set#test1@2!@=2@1=1",
              "*set#test1@5!=5@3:2,@4:1,",
            ],
            ["*set#test1@1=1", "*set#test1@2=2", "*set#test1@2!=2@1=1"],
            [
              "*set#test1@1=1",
              "*set#test1@2=2",
              "*set#test1@3:2,",
              "*set#test1@3!:2,@1:0=1",
            ],
            [
              "*set#object@1ABC1+user!=5",
              "*set#object@1ABC2+user!:1ABC1+user,",
              "*set#object@1ABC2+user!:1ABC1+user,",
            ],
            [
              "*set#mice!",
              "",
              "*set#mice@1YKBoB+1YKBjg?!:1YKBn59j01+1YKBjg,@(mL+:(lC8H01+,@(lA+:(jg4u01+,@(j4+(hM:(hM5g01+(hM,@(hBDz01+(fD:0+>mouse$1YKBfD@[9+:1YKBfD4x01+(fD,@(du8G01+(Up:0+>mouse$1YKBUp@(WS+:1YKBUp6H01+(Up,@(Tw4Q01+(Tw4:0+>mouse$1YKBTw4@[_8r01+[_>mouse$1YKBT_@[Y+(S8U:1YKBS8Ea01+(S8U,@(S0E_01+[0T:0+>mouse$1YKBS0T@(RwB901+(Rw>mouse$1YKBRw@(QPFP01+(QPQ>mouse$1YKBQPQ@[O4B01+[O>mouse$1YKBQO@(OrAJ01+(OrI>mouse$1YKBOrI@[pE401+[p>mouse$1YKBOp@(MS1T01+(MR>mouse$1YKBMR@(EREx01+(ERW>mouse$1YKBERW@[L0v01+[L0K>mouse$1YKBEL0K@[D1f01+[CZ>mouse$1YKBECZ@[BCz01+[B>mouse$1YKBEB@(D93B01+(D9>mouse$1YKBD9@[L4901+(Af:1YKBAg3~01+(Af,@(AJ+(8T:(8T2S01+(8T,@(7R+(4e:(4e9a01+(4e,@(0O+1YKAQ5:1YKAtmEq01+1YKAQ5,@1YKAsB+:(qq2X01+,@(hC+:(e64801+,@(YZ+:(WSE~01+,@(Ut+:(T_Cx01+,@(S4+:(Q5AZ01+,@(OT+(NK:(NK5l01+(NK,@(N2+(LJB:(LJ6J01+(LJB,@(LG2T01+[G:0+>mouse$1YKALG@(KK5501+(KK>mouse$1YKAKK@(Js2m01+(Jr>mouse$1YKAJr@(GbBg01+(GbL>mouse$1YKAGbL@[E0601+1YK7WoK>mouse$1YK7WoK@[1+:1YKAE20S01+1YK7WoK,@1YK8qM+:1YK7fr8w01+,@1YK7as+:(WoCT01+,@(Wa2T01+(Rl:0+>mouse$1YK7Rl@(Tj+:1YK7Rl5C01+(Rl,@(Rj+(QY_:(QZ2701+(QY_,@(QD8g01+[DG:0+>mouse$1YK7QDG@[26R01+[2>mouse$1YK7Q2@(P+(OwY>mouse$1YK7OwY@(Or2J01+[r2>mouse$1YK7Or2@(Nj3x01+(Nj3>mouse$1YK7Nj3@(LZ3D01+(LZ>mouse$1YK7LZ@(Nc8N01+:1YK7KD3M01+(KD,@)2+:(Jh0t01+(JgZ,@)3+:[J4n01+[J,",
              "*set#mice@1YKBoB+1YKBjg!:1YKBn59j01+1YKBjg,@(mL+:(lC8H01+,@(lA+:(jg4u01+,@(j4+(hM:(hM5g01+(hM,@(hBDz01+(fD:0+>mouse$1YKBfD@[9+:1YKBfD4x01+(fD,@(du8G01+(Up:0+>mouse$1YKBUp@(WS+:1YKBUp6H01+(Up,@(Tw4Q01+(Tw4:0+>mouse$1YKBTw4@[_8r01+[_>mouse$1YKBT_@[Y+(S8U:1YKBS8Ea01+(S8U,@(S0E_01+[0T:0+>mouse$1YKBS0T@(RwB901+(Rw>mouse$1YKBRw@(QPFP01+(QPQ>mouse$1YKBQPQ@[O4B01+[O>mouse$1YKBQO@(OrAJ01+(OrI>mouse$1YKBOrI@[pE401+[p>mouse$1YKBOp@(MS1T01+(MR>mouse$1YKBMR@(EREx01+(ERW>mouse$1YKBERW@[L0v01+[L0K>mouse$1YKBEL0K@[D1f01+[CZ>mouse$1YKBECZ@[BCz01+[B>mouse$1YKBEB@(D93B01+(D9>mouse$1YKBD9@[L4901+(Af:1YKBAg3~01+(Af,@(AJ+(8T:(8T2S01+(8T,@(7R+(4e:(4e9a01+(4e,@(0O+1YKAQ5:1YKAtmEq01+1YKAQ5,@1YKAsB+:(qq2X01+,@(hC+:(e64801+,@(YZ+:(WSE~01+,@(Ut+:(T_Cx01+,@(S4+:(Q5AZ01+,@(OT+(NK:(NK5l01+(NK,@(N2+(LJB:(LJ6J01+(LJB,@(LG2T01+[G:0+>mouse$1YKALG@(KK5501+(KK>mouse$1YKAKK@(Js2m01+(Jr>mouse$1YKAJr@(GbBg01+(GbL>mouse$1YKAGbL@[E0601+1YK7WoK>mouse$1YK7WoK@[1+:1YKAE20S01+1YK7WoK,@1YK8qM+:1YK7fr8w01+,@1YK7as+:(WoCT01+,@(Wa2T01+(Rl:0+>mouse$1YK7Rl@(Tj+:1YK7Rl5C01+(Rl,@(Rj+(QY_:(QZ2701+(QY_,@(QD8g01+[DG:0+>mouse$1YK7QDG@[26R01+[2>mouse$1YK7Q2@(P+(OwY>mouse$1YK7OwY@(Or2J01+[r2>mouse$1YK7Or2@(Nj3x01+(Nj3>mouse$1YK7Nj3@(LZ3D01+(LZ>mouse$1YK7LZ@(Nc8N01+:1YK7KD3M01+(KD,@)2+:(Jh0t01+(JgZ,@)3+:[J4n01+[J,",
            ],
            [
              """
              *set#mice@1YKDY54a01+1YKDY5!
                  >mouse$1YKDY5
""",

              // note ? header
              """
                  *set#mice@1YKDXO3201+1YKDXO?
                  !
                  @>mouse$1YKDXO
                  @(WBF901(WBY>mouse$1YKDWBY
                  @[67H01[6>mouse$1YKDW6
                  @(Uh4j01(Uh>mouse$1YKDUh
                  @(S67V01(S6>mouse$1YKDS6
                  @(Of(N3:1YKDN3DS01+1YKDN3,
                  @(MvBV01(IuJ:0>mouse$1YKDIuJ
                  @(LF:1YKDIuEY01+1YKDIuJ,
                  :{A601,
                  @(Io5l01[oA:0>mouse$1YKDIoA
                  @[l7_01[l>mouse$1YKDIl
                  @(57(4B:1YKD4B3f01+1YKD4B,
                  @(0bB401+1YKCsd:0>mouse$1YKCsd
                  @1YKCu6+:1YKCsd7Q01+1YKCsd,
                  """,

              
              "*set#mice@1YKDY54a01+1YKDY5!>mouse$1YKDY5@(XO3201+(XO>mouse$1YKDXO@(WBF901+(WBY>mouse$1YKDWBY@[67H01+[6>mouse$1YKDW6@(Uh4j01+(Uh>mouse$1YKDUh@(S67V01+(S6>mouse$1YKDS6@(Of+(N3:1YKDN3DS01+1YKDN3,@(MvBV01+(IuJ:0+>mouse$1YKDIuJ@(LF+:1YKDIuEY01+(IuJ,:{A601+,@(Io5l01+[oA:0+>mouse$1YKDIoA@[l7_01+[l>mouse$1YKDIl@(57+(4B:1YKD4B3f01+(4B,@(0bB401+1YKCsd:0+>mouse$1YKCsd@1YKCu6+:1YKCsd7Q01+1YKCsd,",
            ],
          ]
        
        for fixt in fixtures {
            let output = Frame(str: fixt.last)
            let reduced = Set.reduce(batch: .init(fixt.dropLast()))
            XCTAssertEqual(reduced.toString(), output.toString())
        }
    }
    
    func testMapToJs() {
        XCTAssertEqual(Set.ronToJs(rawFrame: "*set#test1@2:d!:0=2@1=1").type, .fromString("set"))
        XCTAssertEqual(Set.ronToJs(rawFrame: "*set#test1@2:d!:0=2@1=1").version, "2");
        XCTAssertEqual(Set.ronToJs(rawFrame: "*set#test1@2:d!:0=2@1=1").length, 2);
        XCTAssertEqual(Set.ronToJs(rawFrame: "*set#test1@2:d!:0=2@1=1").id, "test1");
        XCTAssert(Set.ronToJs(rawFrame: "*set#test1@2:d!:0=2@1=1") == ["0": .int(2), "1": .int(1)]);
        
        XCTAssert(Set.ronToJs(rawFrame: "*set#test1@3:d!:0>object@2=2@1=1") == [
            "0": .uuid(Uuid.fromString("object")),
            "1": .int(2),
            "2": .int(1),
        ])
        XCTAssert(Set.ronToJs(rawFrame: "*set#test1@3:d!:0>object@2=2#test@1=1#test1@=3") == [
            "0": .uuid(Uuid.fromString("object")),
            "1": .int(2),
            "2": .int(3),
        ])
        XCTAssert(Set.ronToJs(rawFrame: "*set#object@1ABC3+user!,") == [:]);
        XCTAssert(Set.ronToJs(rawFrame: "*set#test1@3:d!:2,@1:0=1") == ["0": .int(1) ]);
        XCTAssert(Set.ronToJs(rawFrame: "*set#object@1ABC2+user!:1ABC1+user,") == [:]);
    }
}
