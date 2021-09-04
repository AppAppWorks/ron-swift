//
//  File.swift
//  
//
//  Created by Lau Chun Kai on 31/7/2021.
//

import XCTest
@testable import RonCore_xx
import CommonCrypto

final class HashTests : XCTestCase {
    typealias Frame = Ron.TextFrame
    typealias Cursor = Frame.Cursor
    typealias Builder = Frame.Builder

    func testSerialization() {
        var builder = Builder()
        builder.appendOp(with: Ron.Op(id: "1+src",
                                      ref: "lww"))
        builder.appendOp(with: Ron.Op(id: "2+orig",
                                      ref: "1+src",
                                      .string("key"),
                                      .string("value")))
        let frame = builder.release()
        let data = frame.data
        var cur = frame.cursor
        cur.next()
        let srcHash = Ron.SHA2(uuid: "0+src")
        let lwwHash = Ron.SHA2(uuid: "lww")
        var ophash = Ron.SHA2.stream
        ophash.writeOpHashable(cursor: cur,
                               prevHash: srcHash,
                               refHash: lwwHash)
        var opHash = Ron.SHA2()
        opHash.bits = ophash.close()
        let okhex = "97fa0525e009867adffe5e2c71f93057dfb8293c25c27292cd4caf230a0e39ec"
        let okbase = "a~d59U09XcgV~athSV_lLyztAJlalcAIoKnk8ldEEUl"
//        XCTAssertEqual(opHash.hex, okhex)
        XCTAssertEqual(opHash.bits.map { String(format: "%02X", $0) }.joined(), okhex)
    }

    func testStupid() {
        var sha2 = Ron.SHA2()
        var ophash = Ron.SHA2.stream
        ophash.writeData("z".data(using: .utf8)!)
        sha2.bits = ophash.close()
        print(sha2.bits.map { String(format: "%02X", $0) }.joined())
//        print(sha2._knownBits)
//        print(sha2.hex)
        
//        var digest = [UInt8](repeating: 0, count: .init(CC_SHA512_DIGEST_LENGTH))
//        "1".data(using: .utf8)?.withUnsafeBytes { ptr in
//            CC_SHA512(ptr.baseAddress!, 1, &digest)
//        }
//        print(digest.map { String(format: "%02X", $0) }.joined())
    }
}

//455e518824bc0601f9fb858ff5c37d417d67c2f8e0df2babe4808858aea830f8
//D1B328AF90774ECD25EA6A7E6F412F5FF1EE29AF5A8C698ED4ED54F425C950AA


//    SHA2Stream ophash;
//    WriteOpHashable<Cursor, SHA2Stream>(cur, ophash, SRC_HASH, LWW_HASH);
//    SHA2 OP_HASH;
//    ophash.close(OP_HASH.bits_);
//    string okhex =  "97fa0525e009867adffe5e2c71f93057dfb8293c25c27292cd4caf230a0e39ec";
//    string okbase = "a~d59U09XcgV~athSV_lLyztAJlalcAIoKnk8ldEEUl";
//    ASSERT_EQ(OP_HASH.hex(), okhex);
//    ASSERT_EQ(OP_HASH.base64(), okbase);
//    ASSERT_EQ(SHA2::ParseBase64(okbase), OP_HASH);
//    ASSERT_TRUE(SHA2::valid(okbase));
//    string not_a_hash = okbase;
//    not_a_hash[SHA2::BASE64_SIZE-1] = '1';
//    ASSERT_FALSE(SHA2::valid(not_a_hash));
//    SHA2 op2 = SHA2::ParseBase64(okbase);
//    SHA2 op3 = SHA2::ParseHex(okhex);
//    ASSERT_GE(op2.known_bits(), 0);
//    ASSERT_EQ(op2, OP_HASH);
//    ASSERT_GE(op3.known_bits(), 0);
//    ASSERT_EQ(op3, OP_HASH);
//}
//
//TEST (SHA2, PartialMatch) {
//    SHA2 a = SHA2::ParseHex("97fa0525e009867adffe5e2c71f93057dfb8293c25c27292cd4caf230a0e39ec");
//    SHA2 a2 = SHA2::ParseHex("97fa");
//    ASSERT_TRUE(a.known_bits());
//    ASSERT_TRUE(a2.known_bits());
//    ASSERT_TRUE(a.matches(a2));
//    ASSERT_NE(a, a2);
//    SHA2 caps = SHA2::ParseHex("97fA0525E");
//    SHA2 half = SHA2::ParseHex("97fa0");
//    SHA2 badhalf = SHA2::ParseHex("97fa1");
//    SHA2 nothex = SHA2::ParseHex("z");
//    ASSERT_TRUE(caps.known_bits());
//    ASSERT_TRUE(half.known_bits());
//    ASSERT_TRUE(badhalf.known_bits());
//    ASSERT_TRUE(caps.matches(a));
//    ASSERT_TRUE(half.matches(a));
//    ASSERT_FALSE(badhalf.matches(a));
//    ASSERT_FALSE(nothex.known_bits());
//}
