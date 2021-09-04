import XCTest
@testable import RonCore_xx

extension Ron.TextFrame {
    var pattern: String {
        var ret = [UInt8]()
        var c = cursor
        while c.next()() {
            if !c.op.isEmpty {
                ret.append("@")
            }
            if c.op.count > 1 {
                ret.append(":")
            }
            for i in 2..<UInt32(c.op.count) {
                ret.append(c.atom(at: i).type.punct)
            }
            ret.append(c.term.punct)
        }
        return .init(bytes: ret,
                     encoding: .utf8)!
    }
}

final class TextTests : XCTestCase {
    typealias Frame = Ron.TextFrame
    typealias Cursor = Frame.Cursor
    typealias Builder = Frame.Builder
    
    func testTextFrameNewOp() {
        var id: Ron.UUID = "1lQA32+0"
        var b = Builder()
        b.appendOp(with: Ron.Op(id: id,
                                ref: Ron.UUID.lwwForm))
        b.appendOp(with: Ron.Op(id: id + 1,
                                ref: id,
                                .uuid("int"),
                                .integer(1)))
        id += 1
        b.appendOp(with: Ron.Op(id: id + 1,
                                ref: id,
                                .uuid("float"),
                                .float(3.14159265359)))
        id += 1
        b.appendOp(with: Ron.Op(id: id + 1,
                                ref: id,
                                .uuid("string"),
                                .string("юникод")))
        b.endChunk(term: .raw)
        let correct = "@1lQA32+0 :lww,\n int 1,\n float 3.1415926535900001,\n string 'юникод';\n"
        XCTAssertEqual(b.data, correct)
    }
    
    func testTextFrameBasicCycle() {
        var builder = Builder()
        let time1 = "1+src"
        let time2 = "2+orig"
        let lww = "lww"
        let key = "key"
        let value = "value"
        builder.appendOp(with: Ron.Op(id: time1,
                                      ref: lww))
        builder.appendOp(with: Ron.Op(id: time2,
                                      ref: time1,
                                      .string(key),
                                      .string(value)))
        
        let frame = builder.release()
        let data = frame.data
        XCTAssertNotNil(data.range(of: time1))
        XCTAssertNotNil(data.range(of: key))
        XCTAssertNotNil(data.range(of: value))
        
        var cursor = frame.cursor
        XCTAssert(cursor.next()())
        XCTAssertEqual(cursor.op.count, 2)
        XCTAssertEqual(cursor.ref, .init(buf: lww))
        XCTAssertEqual(cursor.id.str, time1)
        XCTAssertEqual(cursor.term, .reduced)
        XCTAssert(cursor.next()())
        
        XCTAssertEqual(cursor.term, .raw)
        XCTAssertEqual(cursor.ref.str, time1)
        XCTAssertEqual(cursor.id.str, time2)
        XCTAssertEqual(cursor.string(at: 2).string, key)
        XCTAssertEqual(cursor.string(at: 3).string, value)
        XCTAssertFalse(cursor.next()())
    }
    
    func testTextFrameOptionalChar() {
        let tangled = "@1A 234 56K;+9223372036854775807'abc' 3, @id 3.1415 >uuid;"
        let abc = "abc"
        let opt = Frame(data: tangled)
        var copt = opt.cursor
        XCTAssert(copt.next()())
        XCTAssert(copt.isValid)
        XCTAssertEqual(copt.op.count, 4)
        XCTAssertEqual(copt.atom(at: 0) as? Ron.UUID, "1A")
        XCTAssertEqual(copt.id, "1A")
        XCTAssertEqual(copt.atom(at: 2).type, .int)
        XCTAssertEqual(copt.atom(at: 2).value.integer, 234)
        XCTAssertEqual(copt.atom(at: 3).type, .uuid)
        XCTAssertEqual(copt.atom(at: 3) as? Ron.UUID, "56K")
        XCTAssertFalse(copt.id.isZero)
        XCTAssert(copt.ref.isZero)
        
        let ok = copt.next()
        XCTAssert(ok())
        XCTAssertEqual(copt.id, "1A00000001")
        XCTAssertEqual(copt.ref, "1A")
        XCTAssert(copt.hasValue(of: .int))
        
        XCTAssertEqual(copt.atom(at: 2).value.integer, 9223372036854775807)
        XCTAssertEqual(copt.string(at: 3).string, abc)
        XCTAssertEqual(copt.atom(at: 4).value.integer, 3)
        
        XCTAssert(copt.next()())
        XCTAssertEqual(copt.atom(at: 2).value.float, 3.1415)
        
        XCTAssertFalse(copt.next()())
        XCTAssertFalse(copt.isValid)
        
        var unparsed = Cursor(str: tangled)
        XCTAssert(unparsed.next()())
        XCTAssertEqual(unparsed.op.count, 4)
        XCTAssertEqual(unparsed.op[2].value.integer, 0)
        XCTAssertEqual(unparsed.atom(at: 2).value.integer, 234)
        XCTAssert(unparsed.next()())
        XCTAssertEqual(unparsed.atom(at: 3).value.cp, 0)
        
        var abcAtom = unparsed.atom(at: 3)
        XCTAssertEqual(abcAtom.value.cp, 0)
        XCTAssertEqual(abcAtom.value.size.1, 3)
        unparsed.nextCodepoint(&abcAtom)
        XCTAssertEqual(abcAtom.value.cp, abc.unicodeScalars.first?.value)
        XCTAssertEqual(abcAtom.value.cpSize, 2)
        unparsed.nextCodepoint(&abcAtom)
        XCTAssertEqual(abcAtom.value.cp, Array(abc.unicodeScalars)[1].value)
        XCTAssertEqual(abcAtom.value.cpSize, 1)
        unparsed.nextCodepoint(&abcAtom)
        XCTAssertEqual(abcAtom.value.cp, Array(abc.unicodeScalars)[2].value)
        XCTAssertEqual(abcAtom.value.cpSize, 0)
    }
    
    func testTextFrameSigns() {
        let SIGNS = "@2:1 -1 ,-1.2, +1.23,-1e+2, -2.0e+1,"
        let signs = Frame(data: SIGNS)
        var cur = signs.cursor
        XCTAssert(cur.next()())
        XCTAssertEqual(cur.atom(at: 2).value.integer, -1)
        XCTAssert(cur.next()())
        XCTAssertEqual(cur.atom(at: 2).value.float, -1.2)
        XCTAssert(cur.next()())
        XCTAssertEqual(cur.atom(at: 2).value.float, 1.23)
        XCTAssert(cur.next()())
        XCTAssertEqual(cur.atom(at: 2).value.float, -100)
        XCTAssert(cur.next()())
        XCTAssertEqual(cur.atom(at: 2).value.float, -20)
        XCTAssertFalse(cur.next()())
    }
    
    func testTextFrameSizeLimits() {
        let overlimit = "=1,=1000000000000000000001,"
        let toolong = Frame(data: overlimit)
        var cur = toolong.cursor
        XCTAssert(cur.next()())
        XCTAssertFalse(cur.next()())
    }
    
    func testStringEscapes() {
        var builder = Builder()
        let str1 = "'esc'"
        let str2 = "=\r\n\t\\="
        builder.appendOp(with: Ron.Op(id: "1+a",
                                      ref: "2+b",
                                      .string(str1),
                                      .string(str2)))
        let cycle = builder.release()
        var cc = cycle.cursor
        XCTAssert(cc.next()())
        XCTAssertEqual(cc.string(at: 2).string, str1)
        XCTAssertEqual(cc.string(at: 3).string, str2)
    }
    
    func testTextFrameTerms() {
        let commas = "@1+A:2+B 1,2 ,\n,\t4   ,,"
        var c = Cursor(str: commas)
        var i = 0
        while c.next()() { i += 1 }
        XCTAssertEqual(i, 5)
    }
    
    func testTextFrameDefaults() {
        var b = Builder()
        let raw = "@12345+test :lww; @1234500001+test :12345+test 'key' 'value';"
        b.append(.init(data: raw))
        let nice = b.release()
        let correct = "@12345+test :lww;\n 'key' 'value';\n"
        XCTAssertEqual(nice.data, correct)
        var nc = nice.cursor
        XCTAssert(nc.next()())
        XCTAssertEqual(nc.id, "12345+test")
        XCTAssertEqual(nc.ref, "lww")
        XCTAssert(nc.next()())
        XCTAssertEqual(nc.id, "1234500001+test")
        XCTAssertEqual(nc.ref, "12345+test")
    }
    
    func testTextFrameSpanSpread() {
        let raw = "@1iDEKK+gYpLcnUnF6 :1iDEKA+gYpLcnUnF6 ('abcd');"
        var c = Cursor(str: raw)
        XCTAssert(c.next()())
    }
    
    func testTextFrameSyntaxErrors() {
        let invalid = "@line+ok\n:bad/"
        var cur = Cursor(data: Ron.Slice(data: invalid))
        let ok = cur.next()
        let msg = "syntax error at line 2 col 5 (offset 13)"
        XCTAssertEqual(ok.comment, msg)
    }
    
    func testFrameUtf16() {
        let pikachu = "'пикачу\\u0020ピカチュウ'!"
        XCTAssertEqual(pikachu.utf8.count, 36)
        let frame = Frame(data: pikachu)
        var cur = frame.cursor
        XCTAssert(cur.next()())
        XCTAssert(cur.hasValue(of: .string))
        let (str, _) = cur.string(at: 2)
        XCTAssertEqual(str, "пикачу ピカチュウ")
        XCTAssertEqual(str.utf16.count, 12)
    }
    
    func testTextFrameEnd() {
        let frame = "@1kK7vk+0 :lww ;\n"
        var c = Cursor(str: frame)
        XCTAssert(c.next()())
        XCTAssertEqual(c.next(), .endOfFrame)
    }
    
    func testTextFrameSpans() {
        let str = "@1lNBfg+0 :1lNBf+0 rm(3);\n"
        let frame = str
        var c = Cursor(str: frame)
        var b = Builder()
        XCTAssert(c.next()())
        XCTAssert(c.hasValue(of: .uuid))
        XCTAssertEqual(Ron.UUID(a: c.atom(at: 2)), "rm")
        b.appendOp(with: c)
        XCTAssert(c.next()())
        XCTAssertEqual(c.atom(at: 2).type, .uuid)
        XCTAssertEqual(c.atom(at: 2) as? Ron.UUID, "rm")
        b.appendOp(with: c)
        XCTAssert(c.next()())
        XCTAssertEqual(c.atom(at: 2).type, .uuid)
        XCTAssertEqual(c.atom(at: 2) as? Ron.UUID, "rm")
        b.appendOp(with: c)
        XCTAssertFalse(c.next()())
        
        var str2 = ""
        b.release(to: &str2)
        XCTAssertEqual(str, str2)
        
        let nospan = "@1lNBku+0 :max 1,\n 2,\n 3;\n"
        var nob = Builder()
        nob.append(.init(data: nospan))
        var no2 = ""
        nob.release(to: &no2)
        XCTAssertEqual(nospan, no2)
    }
    
    func testTextFrameSpreads() {
        let str = "@1lNBvg+0 :1lNBf+0 ('aㅂц');\n"
        let frame = str
        var b = Builder()
        var c = Cursor(str: frame)
        XCTAssert(c.next()())
        XCTAssert(c.op[2].value.cp == UInt8(ascii: "a"))
        XCTAssert(c.char() == UInt8(ascii: "a"))
        b.appendOp(with: c)
        XCTAssert(c.next()())
        XCTAssertEqual(c.op[2].value.cp, 0x3142)
        XCTAssertEqual(c.string().string, "ㅂ")
        b.appendOp(with: c)
        XCTAssert(c.next()())
        XCTAssertEqual(c.string().string, "ц")
        XCTAssertEqual(c.op[2].value.cp, 0x0446)
        b.appendOp(with: c)
        XCTAssertFalse(c.next()())
        
        var str2 = ""
        b.release(to: &str2)
        
        XCTAssertEqual(str, str2)
    }
    
    func testMakeSpread() {
        let separate = Frame(data: "@1lNBvg+0 :1lNBf+0 'a','ㅂ','ц';\n")
        let spread = "@1lNBvg+0 :1lNBf+0 ('aㅂц');\n"
        var b = Builder()
        b.append(separate)
        var condensed = ""
        b.release(to: &condensed)
        XCTAssertEqual(condensed, spread)
    }
}
