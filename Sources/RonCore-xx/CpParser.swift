public extension Ron.TextFrame.Cursor {
    @usableFromInline
    internal enum CP {
        @usableFromInline
        static let start = 9
        static let firstFinal = 9
        @usableFromInline
        static let error = 0

        static let en_main = 9
    }

    @discardableResult @inlinable
    func nextCodepoint(_ c: inout RonAtom) -> Ron.Result {
        guard c.value.cpSize > 0 else {
            c.value.cp = 0
            return .endOfInput
        }
        
        let strData = self[c]
        return strData.withUTF8 {
            body(root: $0,
                 pb: $1,
                 pe: $2,
                 strData: strData,
                 c: &c)
        }
    }
    
    @inline(__always)
    @usableFromInline
    internal func body(root: UnsafePointer<UInt8>,
                       pb: UnsafePointer<UInt8>,
                       pe: UnsafePointer<UInt8>,
                       strData: Ron.Slice,
                       c: inout RonAtom) -> Ron.Result {
        var p = pb
        let eof = root
        var cp: Ron.Codepoint = 0
        var cpSize: Ron.FSize = 0
        var cs = 0
        
        //#line 39 "ron/cp-parser.cc"
        cs = CP.start
        
        if p == pe {
            testEof()
        } else {
            switch cs {
            case 9: case9()
            case 10: case10()
            case 1: case1()
            case 2: case2()
            case 3: case3()
            case 4: case4()
            case 5: case5()
            case 6: case6()
            case 7: case7()
            case 8: case8()
            case 11: case11()
            case _: break
            }
        }
        
        func case9() {
            switch p.pointee {
                case 0:
                    return st0()
                case 10:
                    return st0()
                case 13:
                    return st0()
                case 39:
                    return st0()
                case 92:
                    return st1()
            case _: break
            }
            if p.pointee < 224 {
                if p.pointee > 191 {
                    if 192 <= p.pointee && p.pointee <= 223 {return tr12()}
                } else if p.pointee >= 128
                    {return st0()}
            } else if p.pointee > 239 {
                if p.pointee > 247 {
                    if 248 <= p.pointee {return st0()}
                } else if p.pointee >= 240
                    {return tr14()}
            } else
                {return tr13()}
            tr10()
        }
        
        //#line 116 "ron/cp-parser.cc"
        func case10() {
            switch p.pointee {
                case 0:
                    return st0()
                case 10:
                    return st0()
                case 13:
                    return st0()
                case 39:
                    return st0()
                case 92:
                    return tr16()
            case _: break
            }
            if p.pointee < 224 {
                if p.pointee > 191 {
                    if 192 <= p.pointee && p.pointee <= 223 {return tr17()}
                } else if p.pointee >= 128
                    {return st0()}
            } else if p.pointee > 239 {
                if p.pointee > 247 {
                    if 248 <= p.pointee {return st0()}
                } else if p.pointee >= 240
                    {return tr19()}
            } else
                {return tr18()}
            tr15()
        }
        
        //#line 161 "ron/cp-parser.cc"
        func case1() {
            switch p.pointee {
                case 34:
                    return tr0()
                case 39:
                    return tr0()
                case 47:
                    return tr0()
                case 92:
                    return tr0()
                case 98:
                    return tr0()
                case 110:
                    return tr0()
                case 114:
                    return tr0()
                case 116:
                    return tr0()
                case 117:
                    return st2()
            case _: break
            }
            st0()
        }
        
        func case2() {
            if p.pointee < 65 {
                if 48 <= p.pointee && p.pointee <= 57 {return st3()}
            } else if p.pointee > 70 {
                if 97 <= p.pointee && p.pointee <= 102 {return st3()}
            } else
                {return st3()}
            st0()
        }
        
        func case3() {
            if p.pointee < 65 {
                if 48 <= p.pointee && p.pointee <= 57 {return st4()}
            } else if p.pointee > 70 {
                if 97 <= p.pointee && p.pointee <= 102 {return st4()}
            } else
                {return st4()}
            st0()
        }
        
        func case4() {
            if p.pointee < 65 {
                if 48 <= p.pointee && p.pointee <= 57 {return st5()}
            } else if p.pointee > 70 {
                if 97 <= p.pointee && p.pointee <= 102 {return st5()}
            } else
                {return st5()}
            st0()
        }
        
        func case5() {
            if p.pointee < 65 {
                if 48 <= p.pointee && p.pointee <= 57 {return st11()}
            } else if p.pointee > 70 {
                if 97 <= p.pointee && p.pointee <= 102 {return st11()}
            } else
                {return st11()}
            st0()
        }
        
        func case11() {
            switch p.pointee {
                case 0:
                    return st0()
                case 10:
                    return st0()
                case 13:
                    return st0()
                case 39:
                    return st0()
                case 92:
                    return tr21()
            case _: break
            }
            if p.pointee < 224 {
                if p.pointee > 191 {
                    if 192 <= p.pointee && p.pointee <= 223 {return tr22()}
                } else if p.pointee >= 128
                    {return st0()}
            } else if p.pointee > 239 {
                if p.pointee > 247 {
                    if 248 <= p.pointee {return st0()}
                } else if p.pointee >= 240
                    {return tr24()}
            } else
                {return tr23()}
            tr20()
        }
        
        //#line 286 "ron/cp-parser.cc"
        func case6() {
            if 128 <= p.pointee && p.pointee <= 191 {return tr7()}
            st0()
        }
        
        //#line 324 "ron/cp-parser.cc"
        func case7() {
            if 128 <= p.pointee && p.pointee <= 191 {return tr8()}
            st0()
        }
        
        //#line 358 "ron/cp-parser.cc"
        func case8() {
            if 128 <= p.pointee && p.pointee <= 191 {return tr9()}
            st0()
        }
        
        func st0() {
            cs = 0
            out()
        }
        
        func st10() {
            p += 1
            if p == pe {
                testEof(cs: 10)
            } else {
                case10()
            }
        }
        
        func st1() {
            p += 1
            if p == pe {
                testEof(cs: 1)
            } else {
                case1()
            }
        }
        
        func st2() {
            p += 1
            if p == pe {
                testEof(cs: 2)
            } else {
                case2()
            }
        }
        
        func st3() {
            p += 1
            if p == pe {
                testEof(cs: 3)
            } else {
                case3()
            }
        }
        
        func st4() {
            p += 1
            if p == pe {
                testEof(cs: 4)
            } else {
                case4()
            }
        }
        
        func st5() {
            p += 1
            if p == pe {
                testEof(cs: 5)
            } else {
                case5()
            }
        }
        
        func st11() {
            p += 1
            if p == pe {
                testEof(cs: 11)
            } else {
                case11()
            }
        }
        
        func st6() {
            p += 1
            if p == pe {
                testEof(cs: 6)
            } else {
                case6()
            }
        }
        
        func st7() {
            p += 1
            if p == pe {
                testEof(cs: 7)
            } else {
                case7()
            }
        }
        
        func st8() {
            p += 1
            if p == pe {
                testEof(cs: 8)
            } else {
                case8()
            }
        }
        
        func tr0() {
            line58TextGrammar()
            
            st10()
        }
        
        func tr7() {
            line7Utf8Grammar()
            
            st10()
        }
        
        func tr10() {
            line8Utf8Grammar()
            
            st10()
        }
        
        func tr15() {
            line43TextGrammar()
            
            line28CpParser(cs: 10) {
                line8Utf8Grammar()
                
                st10()
            }
        }
        
        func tr20() {
            line59TextGrammar()
            
            line43TextGrammar()
            
            line28CpParser(cs: 10) {
                line8Utf8Grammar()
                
                st10()
            }
        }
        
        func tr16() {
            line43TextGrammar()
            
            line28CpParser(cs: 1, st1)
        }
        
        func tr21() {
            line59TextGrammar()
            
            line43TextGrammar()
            
            line28CpParser(cs: 1, st1)
        }
        
        func tr8() {
            line7Utf8Grammar()
            
            st6()
        }
        
        func tr12() {
            line9Utf8Grammar()
            
            st6()
        }
        
        func tr17() {
            line43TextGrammar()
            
            line28CpParser(cs: 6) {
                line9Utf8Grammar()
                
                st6()
            }
        }
        
        func tr22() {
            line59TextGrammar()
            
            line43TextGrammar()
            
            line28CpParser(cs: 6) {
                line9Utf8Grammar()
                
                st6()
            }
        }
        
        func tr9() {
            line7Utf8Grammar()
            
            line10Utf8Grammar()
            
            st7()
        }
        
        func tr13() {
            line10Utf8Grammar()
            
            st7()
        }
        
        func tr18() {
            line43TextGrammar()
            
            line28CpParser(cs: 7) {
                line10Utf8Grammar()
                
                st7()
            }
        }
        
        func tr23() {
            line59TextGrammar()
            
            line43TextGrammar()
            
            line28CpParser(cs: 7) {
                line10Utf8Grammar()
                
                st7()
            }
        }
        
        func tr14() {
            line11Utf8Grammar()
            
            st8()
        }
        
        func tr19() {
            line43TextGrammar()
            
            line28CpParser(cs: 8) {
                line11Utf8Grammar()
                
                st8()
            }
        }
        
        func tr24() {
            line59TextGrammar()
            
            line43TextGrammar()
            
            line28CpParser(cs: 8) {
                line11Utf8Grammar()
                
                st8()
            }
        }
        
        func testEof(cs _cs: Int) {
            cs = _cs
            testEof()
        }
        
        func testEof() {
            if p == eof {
                switch cs {
                case 10:
                    line43TextGrammar()
                    
                    line28CpParser(cs: 0) {}
                case 11:
                    line59TextGrammar()
                    
                    line43TextGrammar()
                    
                    line28CpParser(cs: 0) {}
                case _: break
                }
            }
        }
        
        func out() {}
        
        @inline(__always)
        func line7Utf8Grammar() {
            cp = (cp << 6) | (.init(p.pointee) & 0x3f)
        }
        
        @inline(__always)
        func line8Utf8Grammar() {
            cp = .init(p.pointee)
        }
        
        @inline(__always)
        func line9Utf8Grammar() {
            cp = .init(p.pointee) & 0x1f
        }
        
        @inline(__always)
        func line10Utf8Grammar() {
            cp = .init(p.pointee) & 0xf
        }
        
        @inline(__always)
        func line11Utf8Grammar() {
            cp = .init(p.pointee) & 7
        }
        
        @inline(__always)
        func line28CpParser(cs _cs: Int, _ body: () -> Void) {
            cs = _cs
            out()
        }
        
        @inline(__always)
        func line43TextGrammar() {
            cpSize += 1
        }
        
        @inline(__always)
        func line58TextGrammar() {
            cp = .init(p.pointee.decodedEsc)
        }
        
        @inline(__always)
        func line59TextGrammar() {
            cp = strData.slice(range: p - 4..<p,
                               root: root)
                .decodedHexCp
        }
        
        if cs != CP.error {
            c.value.cp = cp
            c.value.cpSize -= 1
            c.origin.range.consume(p - pb)
            return .ok
        } else {
            c.value.cp = 0
            return .badSyntax
        }
    }
}

//            case 8:


//        }
//    _test_eof10:
//        cs = 10
//        return _test_eof
//    _test_eof1:
//        cs = 1
//        return _test_eof
//    _test_eof2:
//        cs = 2
//        return _test_eof
//    _test_eof3:
//        cs = 3
//        return _test_eof
//    _test_eof4:
//        cs = 4
//        return _test_eof
//    _test_eof5:
//        cs = 5
//        return _test_eof
//    _test_eof11:
//        cs = 11
//        return _test_eof
//    _test_eof6:
//        cs = 6
//        return _test_eof
//    _test_eof7:
//        cs = 7
//        return _test_eof
//    _test_eof8:
//        cs = 8
//        return _test_eof
//
//    _test_eof : {}
//        if p == eof {
//            switch (cs) {
//                case 10:
//#line 43 "ragel/./text-grammar.rl"
//                {
//                    cp_size++
//                }
//#line 28 "ragel/cp-parser.rl"
//                    {
//                        --p
//                        {
//                            p++
//                            cs = 0
//                            return _out
//                        }
//                    }
//                    break
//                case 11:
//#line 59 "ragel/./text-grammar.rl"
//                {
//                    cp = decode_hex_cp(Slice{p - 4, 4})
//                }
//#line 43 "ragel/./text-grammar.rl"
//                    { cp_size++ }
//#line 28 "ragel/cp-parser.rl"
//                    {
//                        --p
//                        {
//                            p++
//                            cs = 0
//                            return _out
//                        }
//                    }
//                    break
//#line 396 "ron/cp-parser.cc"
//            }
//        }
//
//    _out : {}
//    }
//
//#line 32 "ragel/cp-parser.rl"
//
//    if cs != CP_error {
//        a.value.cp = cp
//        --a.value.cp_size
//        a.origin.as_range.Consume(p - pb)
//        assert(a.origin.as_range.valid())
//        return OK()
//    } else {
//        a.value.cp = 0
//        return BADSYNTAX()
//    }
//}
//
//}  // namespace ron
