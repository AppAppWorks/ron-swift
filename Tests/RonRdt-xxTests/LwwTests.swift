//
//  File.swift
//  
//
//  Created by Lau Chun Kai on 3/8/2021.
//

import XCTest
import RonCore_xx
@testable import RonRdt_xx

final class LwwTests : XCTestCase {
    typealias Frame = Ron.TextFrame
    typealias TextLww = Ron.LastWriteWinsRDT
    typealias Cursors = Frame.Cursors
    
    func testLwwReduction() {
        var abBuilder = Frame.Builder()
        var cBuilder = Frame.Builder()
        var abcBuilder = Frame.Builder()
        var b2Builder = Frame.Builder()
        var abbcBuilder = Frame.Builder()
        var ab2cBuilder = Frame.Builder()
        var ab2cBuilder2 = Frame.Builder()
        var inputs = [Frame]()
        
        abBuilder.appendOp(with: Ron.Op(id: "1+src",
                                        ref: "lww"))
        abBuilder.appendOp(with: Ron.Op(id: "2+src",
                                        ref: "1+src",
                                        .string("a"),
                                        .string("A")))
        abBuilder.appendOp(with: Ron.Op(id: "3+src",
                                        ref: "2+src",
                                        .string("b"),
                                        .string("B")))
        cBuilder.appendOp(with: Ron.Op(id: "3+xyz",
                                        ref: "2+src",
                                        .string("c"),
                                        .string("C")))
        b2Builder.appendOp(with: Ron.Op(id: "4+xyz",
                                        ref: "3+src",
                                        .string("b"),
                                        .string("B2")))
        
        inputs.append(abBuilder.release())
        inputs.append(cBuilder.release())
        
        let i1 = inputs.map(\.cursor)
        TextLww.merge(output: &abcBuilder,
                      inputs: i1)
        let abc = abcBuilder.release()
        XCTAssertEqual(abc.scanned, "_,a,b,c")
    }
    
    func testLwwObject() {
        let `init` = Frame(data: "@12345+orig :lww, abc 123, str 'string'")
        let obj = Ron.LwwObject(state: `init`)
        XCTAssertEqual(obj.string(key: "abc"), "")
        XCTAssertEqual(obj.string(key: "str"), "string")
    }
}

private extension Ron.TextFrame {
    var scanned: String {
        var ret = ""
        var cur = cursor
        while cur.next()() {
            if !ret.isEmpty {
                ret += ","
            }
            if cur.op.count > 2 && cur.atom(at: 2).type == .string {
                ret += cur.string(at: 2)
            } else {
                ret += "_"
            }
        }
        return ret
    }
}

//TEST(LWW, Reduction) {
//    TextFrame::Builder ab_builder, c_builder, abc_builder, b2_builder,
//    abbc_builder, ab2c_builder, ab2c_builder2;
//    vector<TextFrame> inputs;
//    TextLWW lww;
//
//    ab_builder.AppendOp(Op{"1+src", "lww"});
//    ab_builder.AppendOp(Op{"2+src", "1+src", "a", "A"});
//    ab_builder.AppendOp(Op{"3+src", "2+src", "b", "B"});
//    c_builder.AppendOp(Op{"3+xyz", "2+src", "c", "C"});
//    b2_builder.AppendOp(Op{"4+xyz", "3+src", "b", "B2"});
//
//    inputs.push_back(ab_builder.Release());
//    inputs.push_back(c_builder.Release());
//
//    Cursors i1 = cursors(inputs);
//    lww.Merge(abc_builder, i1);
//    TextFrame abc = abc_builder.Release();
//    ASSERT_TRUE(scan(abc)=="_,a,b,c");
//
//    inputs.push_back(b2_builder.Release());
//
//    Cursors i2 = cursors(inputs);
//    lww.Merge(abbc_builder, i2);
//    TextFrame abbc = abbc_builder.Release();
//    ASSERT_TRUE(scan(abbc)=="_,a,b,c,b");
//
//    lww.GC(ab2c_builder, abbc);
//    TextFrame ab2c = ab2c_builder.Release();
//    ASSERT_TRUE(scan(ab2c)=="_,a,c,b");
//
//    Cursors i3 = cursors(inputs);
//    lww.MergeGC(ab2c_builder2, i3);
//    TextFrame ab2c2 = ab2c_builder2.Release();
//    ASSERT_TRUE(scan(ab2c2)=="_,a,c,b");
//    ASSERT_TRUE(ab2c.data()==ab2c2.data());
//}
//
//TEST(LWW, Object) {
//    Frame init{"@12345+orig :lww, abc 123, str 'string';"};
//    LWWObject<Frame> obj{init};
//    //ASSERT_EQ(obj.integer(Uuid{"abc"}), 123);
//    ASSERT_EQ(obj.string(Uuid{"abc"}), "");
//    ASSERT_EQ(obj.string(Uuid{"str"}), "string");
//    Frame update{"@123456+orig :12345+orig abc 234;"};
//    obj.Update(update);
//    //ASSERT_EQ(obj.integer(Uuid{"abc"}), 234);
//}
//
//TEST(RDT, SplitLog) {
//    using Frames = std::vector<Frame>;
//    Frame trivial{" @1lD5lN+A :lww, 'A' 'a', 'B' 'b', @1lD5z+B :1lD5lN0001+A 'C' 'c'; "};
//    Cursors chains;
//    ASSERT_TRUE(SplitLogIntoChains(chains, trivial, Uuid{"1lD5z+A"}));
//    Frames splits;
//    ASSERT_TRUE(Reserialize(splits, chains));
//    ASSERT_TRUE(CompareFrames<Frame>(splits[0], Frame{" @1lD5lN+A :lww, 'A' 'a', 'B' 'b'; "}));
//    ASSERT_TRUE(CompareFrames<Frame>(splits[1], Frame{" @1lD5z+B :1lD5lN0001+A 'C' 'c'; "}));
//    ASSERT_EQ(splits.size(), 2);
//}
//
//int main (int argn, char** args) {
//    ::testing::InitGoogleTest(&argn, args);
//    return RUN_ALL_TESTS();
//}
