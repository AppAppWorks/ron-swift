public extension Array where Element == Ron.Codepoint {
    @usableFromInline
    internal enum UTF8 {
        @usableFromInline
        static let start = 4
        @usableFromInline
        static let firstFinal = 4
        static let error = 0
        
        static let en_main = 4
    }
    
    @inline(__always)
    @inlinable
    mutating func parseUtf8(from string: String) -> Ron.Result {
        string.utf8.withContiguousStorageIfAvailable {
            parseUtf8(from: $0)
        }!
    }
    
    @usableFromInline
    internal mutating func parseUtf8(from data: UnsafeBufferPointer<UInt8>) -> Ron.Result {
        var p = data.baseAddress!
        let pe = p + data.count
        let eof = pe
        var cp: Ron.Codepoint = 0
        var cs = 0
        
        //#line 32 "ron/utf8-parser.cc"
        cs = UTF8.start
        
        //#line 19 "ragel/utf8-parser.rl"
        
        //#line 39 "ron/utf8-parser.cc"
        if p == pe {
            testEof()
        } else {
            switch cs {
            case 4: case4()
            case 5: case5()
            case 1: case1()
            case 2: case2()
            case 3: case3()
            case _: break
            }
        }
        
        func case4() {
            let v = p.pointee
            switch v {
            case ..<224:
                switch v {
                case (191 + 1)...:
                    if 192...233 ~= v {
                        return tr5()
                    }
                case 128...:
                    return st0()
                case _: break
                }
            case (239 + 1)...:
                switch v {
                case (247 + 1)...:
                    if 248 <= v {
                        return st0()
                    }
                case 240...:
                    return tr7()
                case _: break
                }
            case _:
                return tr6()
            }
//                if p.pointee < 224 {
//                    if p.pointee > 191 {
//                        if 192 <= p.pointee && p.pointee <= 223 { return tr5() }
//                    } else if p.pointee >= 128
//                    { return st0() }
//                } else if p.pointee > 239 {
//                    if p.pointee > 247 {
//                        if 248 <= p.pointee { return st0() }
//                    } else if p.pointee >= 240
//                    { return tr7() }
//                } else
//                { return tr6() }
            tr4()
        }
        
        func tr0() {
            //#line 7 "ragel/./utf8-grammar.rl"
            cp = (cp << 6) | (.init(p.pointee) & 0x3f)
            
            st5()
        }
        
        func tr4() {
            //#line 8 "ragel/./utf8-grammar.rl"
            cp = .init(p.pointee)
            
            st5()
        }
        
        func tr8() {
            //#line 21 "ragel/utf8-parser.rl"
            append(cp)
            cp = 0
            
            //#line 8 "ragel/./utf8-grammar.rl"
            cp = .init(p.pointee)
            
            st5()
        }
        
        func st5() {
            p += 1
            if p == pe {
                testEof(cs: 5)
            } else {
                case5()
            }
        }
        
        //#line 82 "ron/utf8-parser.cc"
        func case5() {
            if p.pointee < 224 {
                if p.pointee > 191 {
                    if 192 <= p.pointee && p.pointee <= 223 { return tr9() }
                } else if p.pointee >= 128
                { return st0() }
            } else if p.pointee > 239 {
                if p.pointee > 247 {
                    if 248 <= p.pointee { return st0() }
                } else if p.pointee >= 240
                { return tr11() }
            } else
            { return tr10() }
            tr8()
        }
        
        func st0() {
            cs = 0
            out()
        }
        
        
        func tr2() {
            //#line 7 "ragel/./utf8-grammar.rl"
            cp = (cp << 6) | (.init(p.pointee) & 0x3f)
            
            st1()
        }
        
        func tr5() {
            //#line 9 "ragel/./utf8-grammar.rl"
            cp = .init(p.pointee) & 0x1f
            
            st1()
        }
        
        func tr9() {
            //#line 21 "ragel/utf8-parser.rl"
            append(cp)
            cp = 0
            
            //#line 9 "ragel/./utf8-grammar.rl"
            cp = .init(p.pointee) & 0x1f
            
            st1()
        }
        
        func st1() {
            p += 1
            if p == pe {
                testEof(cs: 1)
            } else {
                case1()
            }
        }
        
        //#line 122 "ron/utf8-parser.cc"
        func case1() {
            if 128...191 ~= p.pointee { return tr0() }
            st0()
        }
        
        func tr3() {
            //#line 7 "ragel/./utf8-grammar.rl"
            cp = (cp << 6) | (.init(p.pointee) & 0x3f)
            
            st2()
        }
        
        func tr6() {
            //#line 10 "ragel/./utf8-grammar.rl"
            cp = .init(p.pointee) & 0xf
            
            st2()
        }
        
        func tr10() {
            //#line 21 "ragel/utf8-parser.rl"
            append(cp)
            cp = 0
            
            //#line 10 "ragel/./utf8-grammar.rl"
            cp = .init(p.pointee) & 0xf
            
            st2()
        }
        
        func st2() {
            p += 1
            if p == pe {
                testEof(cs: 2)
            } else {
                case2()
            }
        }
        
        //#line 147 "ron/utf8-parser.cc"
        func case2() {
            if 128...191 ~= p.pointee { return tr2() }
            st0()
        }
        
        func tr7() {
            //#line 11 "ragel/./utf8-grammar.rl"
            cp = .init(p.pointee) & 7
            
            st3()
        }
        
        func tr11() {
            //#line 21 "ragel/utf8-parser.rl"
            append(cp)
            cp = 0
            
            //#line 11 "ragel/./utf8-grammar.rl"
            cp = .init(p.pointee) & 7
            
            st3()
        }
        
        func st3() {
            p += 1
            if p == pe {
                testEof(cs: 3)
            } else {
                case3()
            }
        }
        
        func case3() {
            //#line 168 "ron/utf8-parser.cc"
            if 128...191 ~= p.pointee { return tr3() }
            st0()
        }
        
        func testEof(cs _cs: Int) {
            cs = _cs
            testEof()
        }
        
        func testEof() {
            if p == eof && cs == 5 {
                //#line 21 "ragel/utf8-parser.rl"
                append(cp)
                cp = 0
            }
        }
        
        func out() {}
        
        return cs >= UTF8.firstFinal ? .ok : .badSyntax
    }
}
