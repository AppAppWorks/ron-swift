public extension Ron.TextFrame.Cursor {
    @usableFromInline
    internal static let start: UInt8 = 74
    @usableFromInline
    internal static let firstFinal: UInt8 = 74
    @usableFromInline
    internal static let error: UInt8 = 0
    
    @usableFromInline
    internal static let enMain: UInt8 = 74
    
    /** Parses the next op. Populates the atom vector (see op(), atom(i)).
     */
    @inlinable
    mutating func next() -> Ron.Status {
        assert(Self.firstFinal <= .max, "this grammar should not change much")
        
        guard spanSize == 0 else {
            spanSize -= 1
            op[1] = op[0]
            op[0] += 1
            if op.last!.type == .string && op.last!.value.cp > 0 {
                _ = nextCodepoint(&op[op.count - 1])
            }
            return .ok
        }
        
        switch ragelState {
        case Self.error:
            if data.range.lowerBound != 0 {
                return .badState
            }
            
            ragelState = Self.start
        case Self.ronFullStop:
            ragelState = Self.error
            return .endOfFrame
        default: break
        }
        
        guard !data.isEmpty else {
            ragelState = Self.error
            return .endOfFrame
        }
        
        return data.withUTF8 {
            body(root: $0,
                 pb: $1,
                 pe: $2)
        }
    }
     
    @inline(__always)
    @usableFromInline
    internal mutating func body(root: UnsafePointer<UInt8>,
                                pb: UnsafePointer<UInt8>,
                                pe: UnsafePointer<UInt8>) -> Ron.Status {
        var p = pb
        var lineb = pb
        var intb = p
        var floatb = p
        var strb = p
        var uuidb: UnsafePointer<UInt8>? = p
        var wordb = p
        var cp: Ron.Codepoint = 0
        var cpSize: Ron.FSize = 0
        spanSize = 0
        var term: UInt8 = 0
        var value = Ron.Slice()
        var origin = Ron.Slice()
        var variety: UInt8 = 0
        var version: UInt8 = 0
        
        var escapedCnt: Ron.FSize = 0
        
        let prev = op.isEmpty ? .nil : (op[0] as! Ron.UUID)
        op.removeAll()
        op.append(prev + 1)
        op.append(prev)
        
        func out() {
            
        }
        
        func testEof() {
            
        }
        
        func testEof(cs: UInt8) {
            ragelState = cs
        }
        
        func st0() {
            ragelState = 0
            out()
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
        
        func st9() {
            p += 1
            if p == pe {
                testEof(cs: 9)
            } else {
                case9()
            }
        }
        
        func st10() {
            p += 1
            if p == pe {
                testEof(cs: 10)
            } else {
                case10()
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
        
        func st12() {
            p += 1
            if p == pe {
                testEof(cs: 12)
            } else {
                case12()
            }
        }
        
        func st13() {
            p += 1
            if p == pe {
                testEof(cs: 13)
            } else {
                case13()
            }
        }
        
        func st14() {
            p += 1
            if p == pe {
                testEof(cs: 14)
            } else {
                case14()
            }
        }
        
        func st15() {
            p += 1
            if p == pe {
                testEof(cs: 15)
            } else {
                case15()
            }
        }
        
        func st16() {
            p += 1
            if p == pe {
                testEof(cs: 16)
            } else {
                case16()
            }
        }
        
        func st17() {
            p += 1
            if p == pe {
                testEof(cs: 17)
            } else {
                case17()
            }
        }
        
        func st18() {
            p += 1
            if p == pe {
                testEof(cs: 18)
            } else {
                case18()
            }
        }
        
        func st19() {
            p += 1
            if p == pe {
                testEof(cs: 19)
            } else {
                case19()
            }
        }
        
        func st20() {
            p += 1
            if p == pe {
                testEof(cs: 20)
            } else {
                case20()
            }
        }
        
        func st21() {
            p += 1
            if p == pe {
                testEof(cs: 21)
            } else {
                case21()
            }
        }
        
        func st22() {
            p += 1
            if p == pe {
                testEof(cs: 22)
            } else {
                case22()
            }
        }
        
        func st23() {
            p += 1
            if p == pe {
                testEof(cs: 23)
            } else {
                case23()
            }
        }
        
        func st24() {
            p += 1
            if p == pe {
                testEof(cs: 24)
            } else {
                case24()
            }
        }
        
        func st25() {
            p += 1
            if p == pe {
                testEof(cs: 25)
            } else {
                case25()
            }
        }
        
        func st26() {
            p += 1
            if p == pe {
                testEof(cs: 26)
            } else {
                case26()
            }
        }
        
        func st27() {
            p += 1
            if p == pe {
                testEof(cs: 27)
            } else {
                case27()
            }
        }
        
        func st28() {
            p += 1
            if p == pe {
                testEof(cs: 28)
            } else {
                case28()
            }
        }
        
        func st29() {
            p += 1
            if p == pe {
                testEof(cs: 29)
            } else {
                case29()
            }
        }
        
        func st30() {
            p += 1
            if p == pe {
                testEof(cs: 30)
            } else {
                case30()
            }
        }
        
        func st31() {
            p += 1
            if p == pe {
                testEof(cs: 31)
            } else {
                case31()
            }
        }
        
        func st32() {
            p += 1
            if p == pe {
                testEof(cs: 32)
            } else {
                case32()
            }
        }
        
        func st33() {
            p += 1
            if p == pe {
                testEof(cs: 33)
            } else {
                case33()
            }
        }
        
        func st34() {
            p += 1
            if p == pe {
                testEof(cs: 34)
            } else {
                case34()
            }
        }
        
        func st35() {
            p += 1
            if p == pe {
                testEof(cs: 35)
            } else {
                case35()
            }
        }
        
        func st36() {
            p += 1
            if p == pe {
                testEof(cs: 36)
            } else {
                case36()
            }
        }
        
        func st37() {
            p += 1
            if p == pe {
                testEof(cs: 37)
            } else {
                case37()
            }
        }
        
        func st38() {
            p += 1
            if p == pe {
                testEof(cs: 38)
            } else {
                case38()
            }
        }
        
        func st39() {
            p += 1
            if p == pe {
                testEof(cs: 39)
            } else {
                case39()
            }
        }
        
        func st40() {
            p += 1
            if p == pe {
                testEof(cs: 40)
            } else {
                case40()
            }
        }
        
        func st41() {
            p += 1
            if p == pe {
                testEof(cs: 41)
            } else {
                case41()
            }
        }
        
        func st42() {
            p += 1
            if p == pe {
                testEof(cs: 42)
            } else {
                case42()
            }
        }
        
        func st43() {
            p += 1
            if p == pe {
                testEof(cs: 43)
            } else {
                case43()
            }
        }
        
        func st44() {
            p += 1
            if p == pe {
                testEof(cs: 44)
            } else {
                case44()
            }
        }
        
        func st45() {
            p += 1
            if p == pe {
                testEof(cs: 45)
            } else {
                case45()
            }
        }
        
        func st46() {
            p += 1
            if p == pe {
                testEof(cs: 46)
            } else {
                case46()
            }
        }
        
        func st47() {
            p += 1
            if p == pe {
                testEof(cs: 47)
            } else {
                case47()
            }
        }
        
        func st48() {
            p += 1
            if p == pe {
                testEof(cs: 48)
            } else {
                case48()
            }
        }
        
        func st49() {
            p += 1
            if p == pe {
                testEof(cs: 49)
            } else {
                case49()
            }
        }
        
        func st50() {
            p += 1
            if p == pe {
                testEof(cs: 50)
            } else {
                case50()
            }
        }
        
        func st51() {
            p += 1
            if p == pe {
                testEof(cs: 51)
            } else {
                case51()
            }
        }
        
        func st52() {
            p += 1
            if p == pe {
                testEof(cs: 52)
            } else {
                case52()
            }
        }
        
        func st53() {
            p += 1
            if p == pe {
                testEof(cs: 53)
            } else {
                case53()
            }
        }
        
        func st54() {
            p += 1
            if p == pe {
                testEof(cs: 54)
            } else {
                case54()
            }
        }
        
        func st55() {
            p += 1
            if p == pe {
                testEof(cs: 55)
            } else {
                case55()
            }
        }
        
        func st56() {
            p += 1
            if p == pe {
                testEof(cs: 56)
            } else {
                case56()
            }
        }
        
        func st57() {
            p += 1
            if p == pe {
                testEof(cs: 57)
            } else {
                case57()
            }
        }
        
        func st58() {
            p += 1
            if p == pe {
                testEof(cs: 58)
            } else {
                case58()
            }
        }
        
        func st59() {
            p += 1
            if p == pe {
                testEof(cs: 59)
            } else {
                case59()
            }
        }
        
        func st60() {
            p += 1
            if p == pe {
                testEof(cs: 60)
            } else {
                case60()
            }
        }
        
        func st75() {
            p += 1
            if p == pe {
                testEof(cs: 75)
            } else {
                case75()
            }
        }
        
        func st61() {
            p += 1
            if p == pe {
                testEof(cs: 61)
            } else {
                case61()
            }
        }
        
        func st62() {
            p += 1
            if p == pe {
                testEof(cs: 62)
            } else {
                case62()
            }
        }
        
        func st63() {
            p += 1
            if p == pe {
                testEof(cs: 63)
            } else {
                case63()
            }
        }
        
        func st64() {
            p += 1
            if p == pe {
                testEof(cs: 64)
            } else {
                case64()
            }
        }
        
        func st65() {
            p += 1
            if p == pe {
                testEof(cs: 65)
            } else {
                case65()
            }
        }
        
        func st66() {
            p += 1
            if p == pe {
                testEof(cs: 66)
            } else {
                case66()
            }
        }
        
        func st67() {
            p += 1
            if p == pe {
                testEof(cs: 67)
            } else {
                case67()
            }
        }
        
        func st68() {
            p += 1
            if p == pe {
                testEof(cs: 68)
            } else {
                case68()
            }
        }
        
        func st69() {
            p += 1
            if p == pe {
                testEof(cs: 69)
            } else {
                case69()
            }
        }
        
        func st70() {
            p += 1
            if p == pe {
                testEof(cs: 70)
            } else {
                case70()
            }
        }
        
        func st71() {
            p += 1
            if p == pe {
                testEof(cs: 71)
            } else {
                case71()
            }
        }
        
        func st72() {
            p += 1
            if p == pe {
                testEof(cs: 72)
            } else {
                case72()
            }
        }
        
        func st73() {
            p += 1
            if p == pe {
                testEof(cs: 73)
            } else {
                case73()
            }
        }
        
        //#line 3828 "ron/text-parser.cc"
        func case73() {
            switch p.pointee {
                case 13:
                    return tr177()
                case 32:
                    return tr177()
                case 33:
                    return tr178()
                case 39:
                    return tr180()
                case 40:
                    return tr181()
                case 44:
                    return tr178()
                case 58:
                    return tr184()
                case 59:
                    return tr178()
                case 61:
                    return tr185()
                case 62:
                    return tr186()
                case 63:
                    return tr178()
                case 94:
                    return tr187()
                case 95:
                    return st73()
                case 126:
                    return st73()
            case _: break
            }
            if p.pointee < 43 {
                if p.pointee > 10 {
                    if 36 <= p.pointee && p.pointee <= 37 { return tr179() }
                } else if p.pointee >= 9
                    { return tr177() }
            } else if p.pointee > 45 {
                if p.pointee < 65 {
                    if 48 <= p.pointee && p.pointee <= 57 { return st73() }
                } else if p.pointee > 90 {
                    if 97 <= p.pointee && p.pointee <= 122 { return st73() }
                } else
                    { return st73() }
            } else
                { return tr179() }
            st0()
        }
        
        //#line 3795 "ron/text-parser.cc"
        func case72() {
            switch p.pointee {
                case 95:
                    return tr222()
                case 126:
                    return tr222()
            case _: break
            }
            if p.pointee < 65 {
                if 48 <= p.pointee && p.pointee <= 57 { return tr222() }
            } else if p.pointee > 90 {
                if 97 <= p.pointee && p.pointee <= 122 { return tr222() }
            } else
                { return tr222() }
            st0()
        }
        
        //#line 3758 "ron/text-parser.cc"
        func case71() {
            switch p.pointee {
                case 13:
                    return tr213()
                case 32:
                    return tr213()
                case 33:
                    return tr214()
                case 39:
                    return tr215()
                case 40:
                    return tr216()
                case 44:
                    return tr214()
                case 58:
                    return tr218()
                case 59:
                    return tr214()
                case 61:
                    return tr219()
                case 62:
                    return tr220()
                case 63:
                    return tr214()
                case 94:
                    return tr221()
                case 95:
                    return st71()
                case 126:
                    return st71()
            case _: break
            }
            if p.pointee < 48 {
                if 9 <= p.pointee && p.pointee <= 10 { return tr213() }
            } else if p.pointee > 57 {
                if p.pointee > 90 {
                    if 97 <= p.pointee && p.pointee <= 122 { return st71() }
                } else if p.pointee >= 65
                    { return st71() }
            } else
                { return st71() }
            st0()
        }
        
        //#line 3736 "ron/text-parser.cc"
        func case70() {
            switch p.pointee {
                case 95:
                    return tr212()
                case 126:
                    return tr212()
            case _: break
            }
            if p.pointee < 65 {
                if 48 <= p.pointee && p.pointee <= 57 { return tr212() }
            } else if p.pointee > 90 {
                if 97 <= p.pointee && p.pointee <= 122 { return tr212() }
            } else
                { return tr212() }
            st0()
        }
        
        //#line 3692 "ron/text-parser.cc"
        func case69() {
            switch p.pointee {
                case 13:
                    return tr192()
                case 32:
                    return tr192()
                case 33:
                    return tr193()
                case 39:
                    return tr195()
                case 40:
                    return tr196()
                case 44:
                    return tr193()
                case 59:
                    return tr193()
                case 61:
                    return tr199()
                case 62:
                    return tr200()
                case 63:
                    return tr193()
                case 94:
                    return tr201()
                case 95:
                    return st69()
                case 126:
                    return st69()
            case _: break
            }
            if p.pointee < 43 {
                if p.pointee > 10 {
                    if 36 <= p.pointee && p.pointee <= 37 { return tr194() }
                } else if p.pointee >= 9
                    { return tr192() }
            } else if p.pointee > 45 {
                if p.pointee < 65 {
                    if 48 <= p.pointee && p.pointee <= 57 { return st69() }
                } else if p.pointee > 90 {
                    if 97 <= p.pointee && p.pointee <= 122 { return st69() }
                } else
                    { return st69() }
            } else
                { return tr194() }
            st0()
        }
        
        //#line 3659 "ron/text-parser.cc"
        func case68() {
            switch p.pointee {
                case 95:
                    return tr211()
                case 126:
                    return tr211()
            case _: break
            }
            if p.pointee < 65 {
                if 48 <= p.pointee && p.pointee <= 57 { return tr211() }
            } else if p.pointee > 90 {
                if 97 <= p.pointee && p.pointee <= 122 { return tr211() }
            } else
                { return tr211() }
            st0()
        }
        
        //#line 3623 "ron/text-parser.cc"
        func case67() {
            switch p.pointee {
            case 13:
                return tr203()
            case 32:
                return tr203()
            case 33:
                return tr204()
            case 39:
                return tr205()
            case 40:
                return tr206()
            case 44:
                return tr204()
            case 59:
                return tr204()
            case 61:
                return tr208()
            case 62:
                return tr209()
            case 63:
                return tr204()
            case 94:
                return tr210()
            case 95:
                return st67()
            case 126:
                return st67()
            case _: break
            }
            if p.pointee < 48 {
                if 9 <= p.pointee && p.pointee <= 10 { return tr203() }
            } else if p.pointee > 57 {
                if p.pointee > 90 {
                    if 97 <= p.pointee && p.pointee <= 122 { return st67() }
                } else if p.pointee >= 65
                { return st67() }
            } else
            { return st67() }
            st0()
        }
        
        //#line 3601 "ron/text-parser.cc"
        func case66() {
            switch p.pointee {
            case 95:
                return tr202()
            case 126:
                return tr202()
            case _: break
            }
            if p.pointee < 65 {
                if 48 <= p.pointee && p.pointee <= 57 { return tr202() }
            } else if p.pointee > 90 {
                if 97 <= p.pointee && p.pointee <= 122 { return tr202() }
            } else
            { return tr202() }
            st0()
        }
        
        //#line 3556 "ron/text-parser.cc"
        func case65() {
            let v = p.pointee
            switch v {
            case 13:
                return tr192()
            case 32:
                return tr192()
            case 33:
                return tr193()
            case 39:
                return tr195()
            case 40:
                return tr196()
            case 44:
                return tr193()
            case 47:
                return tr197()
            case 59:
                return tr193()
            case 61:
                return tr199()
            case 62:
                return tr200()
            case 63:
                return tr193()
            case 94:
                return tr201()
            case 95:
                return st69()
            case 126:
                return st69()
            case ..<43:
                switch v {
                case 11...:
                    if 36 <= v && v <= 37 {
                        return tr194()
                    }
                case 9...:
                    return tr192()
                case _: break
                }
            case 46...:
                switch v {
                case ..<65:
                    if 48...57 ~= v {
                        return st69()
                    }
                case 91...:
                    if 97...122 ~= v {
                        return st69()
                    }
                case _:
                    return st69()
                }
            case _:
                return tr194()
            }
//            if p.pointee < 43 {
//                if p.pointee > 10 {
//                    if 36 <= p.pointee && p.pointee <= 37 { return tr194() }
//                } else if p.pointee >= 9
//                { return tr192() }
//            } else
//            if p.pointee > 45 {
//                if p.pointee < 65 {
//                    if 48 <= p.pointee && p.pointee <= 57 { return st69() }
//                } else if p.pointee > 90 {
//                    if 97 <= p.pointee && p.pointee <= 122 { return st69() }
//                } else
//                { return st69() }
//            } else
//            { return tr194() }
            st0()
        }
        
        //#line 3524 "ron/text-parser.cc"
        func case64() {
            switch p.pointee {
                case 95:
                    return tr191()
                case 126:
                    return tr191()
            case _: break
            }
            if p.pointee < 65 {
                if 48 <= p.pointee && p.pointee <= 57 { return tr190() }
            } else if p.pointee > 70 {
                if p.pointee > 90 {
                    if 97 <= p.pointee && p.pointee <= 122 { return tr191() }
                } else if p.pointee >= 71
                    { return tr191() }
            } else
                { return tr190() }
            st0()
        }
        
        //#line 3461 "ron/text-parser.cc"
        func case63() {
            switch p.pointee {
            case 13:
                return tr188()
            case 32:
                return tr188()
            case 33:
                return tr14()
            case 39:
                return st1()
            case 40:
                return st5()
            case 44:
                return tr14()
            case 58:
                return st64()
            case 59:
                return tr14()
            case 61:
                return st25()
            case 62:
                return st28()
            case 63:
                return tr14()
            case 94:
                return st32()
            case 95:
                return tr23()
            case 126:
                return tr23()
            case _: break
            }
            if p.pointee < 48 {
                if p.pointee > 10 {
                    if 43 <= p.pointee && p.pointee <= 45 { return tr20() }
                } else if p.pointee >= 9
                { return tr188() }
            } else if p.pointee > 57 {
                if p.pointee < 71 {
                    if 65 <= p.pointee && p.pointee <= 70 { return tr22() }
                } else if p.pointee > 90 {
                    if 97 <= p.pointee && p.pointee <= 122 { return tr23() }
                } else
                { return tr23() }
            } else
            { return tr21() }
            st0()
        }
        
        //#line 3374 "ron/text-parser.cc"
        func case62() {
            switch p.pointee {
                case 13:
                    return tr177()
                case 32:
                    return tr177()
                case 33:
                    return tr178()
                case 39:
                    return tr180()
                case 40:
                    return tr181()
                case 44:
                    return tr178()
                case 47:
                    return tr182()
                case 58:
                    return tr184()
                case 59:
                    return tr178()
                case 61:
                    return tr185()
                case 62:
                    return tr186()
                case 63:
                    return tr178()
                case 94:
                    return tr187()
                case 95:
                    return st73()
                case 126:
                    return st73()
            case _: break
            }
            if p.pointee < 43 {
                if p.pointee > 10 {
                    if 36 <= p.pointee && p.pointee <= 37 { return tr179() }
                } else if p.pointee >= 9
                    { return tr177() }
            } else if p.pointee > 45 {
                if p.pointee < 65 {
                    if 48 <= p.pointee && p.pointee <= 57 { return st73() }
                } else if p.pointee > 90 {
                    if 97 <= p.pointee && p.pointee <= 122 { return st73() }
                } else
                    { return st73() }
            } else
                { return tr179() }
            st0()
        }
        
        func case61() {
            switch p.pointee {
                case 95:
                    return tr176()
                case 126:
                    return tr176()
            case _: break
            }
            if p.pointee < 65 {
                if 48 <= p.pointee && p.pointee <= 57 { return tr175() }
            } else if p.pointee > 70 {
                if p.pointee > 90 {
                    if 97 <= p.pointee && p.pointee <= 122 { return tr176() }
                } else if p.pointee >= 71
                    { return tr176() }
            } else
                { return tr175() }
            st0()
        }
        
        func case75() {
            st0()
        }
        
        func case60() {
            if p.pointee == 10 {
                st75()
            } else {
                st0()
            }
        }
        
        //#line 3323 "ron/text-parser.cc"
        func case59() {
            if 128 <= p.pointee && p.pointee <= 191 { return tr173() }
            st0()
        }
        
        //#line 3291 "ron/text-parser.cc"
        func case58() {
            if 128 <= p.pointee && p.pointee <= 191 { return tr172() }
            st0()
        }
        
        //#line 3255 "ron/text-parser.cc"
        func case57() {
            if 128 <= p.pointee && p.pointee <= 191 { return tr171() }
            st0()
        }
        
        func case56() {
            switch p.pointee {
                case 0:
                    return st0()
                case 10:
                    return st0()
                case 13:
                    return st0()
                case 39:
                    return tr166()
                case 92:
                    return tr167()
            case _: break
            }
            if p.pointee < 224 {
                if p.pointee > 191 {
                    if 192 <= p.pointee && p.pointee <= 223 { return tr168() }
                } else if p.pointee >= 128
                    { return st0() }
            } else if p.pointee > 239 {
                if p.pointee > 247 {
                    if 248 <= p.pointee { return st0() }
                } else if p.pointee >= 240
                    { return tr170() }
            } else
                { return tr169() }
            tr165()
        }
        
        func case55() {
            if p.pointee < 65 {
                if 48 <= p.pointee && p.pointee <= 57 { return st56() }
            } else if p.pointee > 70 {
                if 97 <= p.pointee && p.pointee <= 102 { return st56() }
            } else
                { return st56() }
            st0()
        }
        
        func case54() {
            if p.pointee < 65 {
                if 48 <= p.pointee && p.pointee <= 57 { return st55() }
            } else if p.pointee > 70 {
                if 97 <= p.pointee && p.pointee <= 102 { return st55() }
            } else
                { return st55() }
            st0()
        }
        
        func case53() {
            if p.pointee < 65 {
                if 48 <= p.pointee && p.pointee <= 57 { return st54() }
            } else if p.pointee > 70 {
                if 97 <= p.pointee && p.pointee <= 102 { return st54() }
            } else
                { return st54() }
            st0()
        }
        
        func case52() {
            if p.pointee < 65 {
                if 48 <= p.pointee && p.pointee <= 57 { return st53() }
            } else if p.pointee > 70 {
                if 97 <= p.pointee && p.pointee <= 102 { return st53() }
            } else
                { return st53() }
            st0()
        }
        
        //#line 3132 "ron/text-parser.cc"
        func case51() {
            switch p.pointee {
            case 34:
                return tr159()
            case 39:
                return tr159()
            case 47:
                return tr159()
            case 92:
                return tr159()
            case 98:
                return tr159()
            case 110:
                return tr159()
            case 114:
                return tr159()
            case 116:
                return tr159()
            case 117:
                return st52()
            case _: break
            }
            st0()
        }
        
        //#line 3075 "ron/text-parser.cc"
        func case50() {
            switch p.pointee {
            case 13:
                return tr134()
            case 32:
                return tr134()
            case 33:
                return tr135()
            case 39:
                return tr136()
            case 40:
                return tr137()
            case 44:
                return tr135()
            case 47:
                return tr117()
            case 59:
                return tr135()
            case 61:
                return tr138()
            case 62:
                return tr139()
            case 63:
                return tr135()
            case 94:
                return tr140()
            case 95:
                return st44()
            case 126:
                return st44()
            case _: break
            }
            if p.pointee < 43 {
                if p.pointee > 10 {
                    if 36 <= p.pointee && p.pointee <= 37 { return tr114() }
                } else if p.pointee >= 9
                { return tr134() }
            } else if p.pointee > 45 {
                if p.pointee < 65 {
                    if 48 <= p.pointee && p.pointee <= 57 { return st44() }
                } else if p.pointee > 90 {
                    if 97 <= p.pointee && p.pointee <= 122 { return st44() }
                } else
                { return st44() }
            } else
            { return tr114() }
            st0()
        }
        
        func case49() {
            switch p.pointee {
            case 13:
                return tr152()
            case 32:
                return tr152()
            case 33:
                return tr153()
            case 39:
                return tr154()
            case 40:
                return tr155()
            case 44:
                return tr153()
            case 59:
                return tr153()
            case 61:
                return tr156()
            case 62:
                return tr157()
            case 63:
                return tr153()
            case 94:
                return tr158()
            case 95:
                return st44()
            case 126:
                return st44()
            case _: break
            }
            if p.pointee < 43 {
                if p.pointee > 10 {
                    if 36 <= p.pointee && p.pointee <= 37 { return tr114() }
                } else if p.pointee >= 9
                { return tr152() }
            } else if p.pointee > 45 {
                if p.pointee < 65 {
                    if 48 <= p.pointee && p.pointee <= 57 { return st49() }
                } else if p.pointee > 90 {
                    if 97 <= p.pointee && p.pointee <= 122 { return st44() }
                } else
                { return st44() }
            } else
            { return tr114() }
            st0()
        }
        
        //#line 2995 "ron/text-parser.cc"
        func case48() {
            switch p.pointee {
            case 13:
                return tr144()
            case 32:
                return tr144()
            case 33:
                return tr145()
            case 39:
                return tr146()
            case 40:
                return tr147()
            case 44:
                return tr145()
            case 59:
                return tr145()
            case 61:
                return tr149()
            case 62:
                return tr150()
            case 63:
                return tr145()
            case 94:
                return tr151()
            case 95:
                return st42()
            case 126:
                return st42()
            case _: break
            }
            if p.pointee < 48 {
                if 9 <= p.pointee && p.pointee <= 10 { return tr144() }
            } else if p.pointee > 57 {
                if p.pointee > 90 {
                    if 97 <= p.pointee && p.pointee <= 122 { return st42() }
                } else if p.pointee >= 65
                { return st42() }
            } else
            { return st48() }
            st0()
        }
        
        //#line 2973 "ron/text-parser.cc"
        func case47() {
            switch p.pointee {
            case 95:
                return tr124()
            case 126:
                return tr124()
            case _: break
            }
            if p.pointee < 65 {
                if 48 <= p.pointee && p.pointee <= 57 { return tr143() }
            } else if p.pointee > 90 {
                if 97 <= p.pointee && p.pointee <= 122 { return tr124() }
            } else
            { return tr124() }
            st0()
        }
        
        func case46() {
            switch p.pointee {
            case 13:
                return tr134()
            case 32:
                return tr134()
            case 33:
                return tr135()
            case 39:
                return tr136()
            case 40:
                return tr137()
            case 44:
                return tr135()
            case 59:
                return tr135()
            case 61:
                return tr138()
            case 62:
                return tr139()
            case 63:
                return tr135()
            case 94:
                return tr140()
            case 95:
                return st44()
            case 126:
                return st44()
            case _: break
            }
            if p.pointee < 43 {
                if p.pointee > 10 {
                    if 36 <= p.pointee && p.pointee <= 37 { return tr114() }
                } else if p.pointee >= 9
                { return tr134() }
            } else if p.pointee > 45 {
                if p.pointee < 65 {
                    if 48 <= p.pointee && p.pointee <= 57 { return st49() }
                } else if p.pointee > 90 {
                    if 97 <= p.pointee && p.pointee <= 122 { return st44() }
                } else
                { return st44() }
            } else
            { return tr141() }
            st0()
        }
        
        func case45() {
            switch p.pointee {
            case 13:
                return tr112()
            case 32:
                return tr112()
            case 33:
                return tr113()
            case 39:
                return tr115()
            case 40:
                return tr116()
            case 44:
                return tr113()
            case 46:
                return st23()
            case 59:
                return tr113()
            case 61:
                return tr119()
            case 62:
                return tr120()
            case 63:
                return tr113()
            case 69:
                return st46()
            case 94:
                return tr123()
            case 95:
                return st44()
            case 101:
                return st46()
            case 126:
                return st44()
            case _: break
            }
            if p.pointee < 43 {
                if p.pointee > 10 {
                    if 36 <= p.pointee && p.pointee <= 37 { return tr114() }
                } else if p.pointee >= 9
                { return tr112() }
            } else if p.pointee > 45 {
                if p.pointee < 65 {
                    if 48 <= p.pointee && p.pointee <= 57 { return st45() }
                } else if p.pointee > 90 {
                    if 97 <= p.pointee && p.pointee <= 122 { return st44() }
                } else
                { return st44() }
            } else
            { return tr114() }
            st0()
        }
        
        //#line 2852 "ron/text-parser.cc"
        func case44() {
            switch p.pointee {
            case 13:
                return tr134()
            case 32:
                return tr134()
            case 33:
                return tr135()
            case 39:
                return tr136()
            case 40:
                return tr137()
            case 44:
                return tr135()
            case 59:
                return tr135()
            case 61:
                return tr138()
            case 62:
                return tr139()
            case 63:
                return tr135()
            case 94:
                return tr140()
            case 95:
                return st44()
            case 126:
                return st44()
            case _: break
            }
            if p.pointee < 43 {
                if p.pointee > 10 {
                    if 36 <= p.pointee && p.pointee <= 37 { return tr114() }
                } else if p.pointee >= 9
                { return tr134() }
            } else if p.pointee > 45 {
                if p.pointee < 65 {
                    if 48 <= p.pointee && p.pointee <= 57 { return st44() }
                } else if p.pointee > 90 {
                    if 97 <= p.pointee && p.pointee <= 122 { return st44() }
                } else
                { return st44() }
            } else
            { return tr114() }
            st0()
        }
        
        //#line 2819 "ron/text-parser.cc"
        func case43() {
            switch p.pointee {
            case 95:
                return tr133()
            case 126:
                return tr133()
            case _: break
            }
            if p.pointee < 65 {
                if 48 <= p.pointee && p.pointee <= 57 { return tr133() }
            } else if p.pointee > 90 {
                if 97 <= p.pointee && p.pointee <= 122 { return tr133() }
            } else
            { return tr133() }
            st0()
        }
        
        //#line 2783 "ron/text-parser.cc"
        func case42() {
            switch p.pointee {
            case 13:
                return tr125()
            case 32:
                return tr125()
            case 33:
                return tr126()
            case 39:
                return tr127()
            case 40:
                return tr128()
            case 44:
                return tr126()
            case 59:
                return tr126()
            case 61:
                return tr130()
            case 62:
                return tr131()
            case 63:
                return tr126()
            case 94:
                return tr132()
            case 95:
                return st42()
            case 126:
                return st42()
            case _: break
            }
            if p.pointee < 48 {
                if 9 <= p.pointee && p.pointee <= 10 { return tr125() }
            } else if p.pointee > 57 {
                if p.pointee > 90 {
                    if 97 <= p.pointee && p.pointee <= 122 { return st42() }
                } else if p.pointee >= 65
                { return st42() }
            } else
            { return st42() }
            st0()
        }
        
        //#line 2761 "ron/text-parser.cc"
        func case41() {
            switch p.pointee {
            case 95:
                return tr124()
            case 126:
                return tr124()
            case _: break
            }
            if p.pointee < 65 {
                if 48 <= p.pointee && p.pointee <= 57 { return tr124() }
            } else if p.pointee > 90 {
                if 97 <= p.pointee && p.pointee <= 122 { return tr124() }
            } else
            { return tr124() }
            st0()
        }
        
        //#line 2713 "ron/text-parser.cc"
        func case40() {
            switch p.pointee {
            case 13:
                return tr112()
            case 32:
                return tr112()
            case 33:
                return tr113()
            case 39:
                return tr115()
            case 40:
                return tr116()
            case 44:
                return tr113()
            case 46:
                return st23()
            case 47:
                return tr117()
            case 59:
                return tr113()
            case 61:
                return tr119()
            case 62:
                return tr120()
            case 63:
                return tr113()
            case 69:
                return st46()
            case 94:
                return tr123()
            case 95:
                return st44()
            case 101:
                return st46()
            case 126:
                return st44()
            case _: break
            }
            if p.pointee < 43 {
                if p.pointee > 10 {
                    if 36 <= p.pointee && p.pointee <= 37 { return tr114() }
                } else if p.pointee >= 9
                { return tr112() }
            } else if p.pointee > 45 {
                if p.pointee < 65 {
                    if 48 <= p.pointee && p.pointee <= 57 { return st45() }
                } else if p.pointee > 90 {
                    if 97 <= p.pointee && p.pointee <= 122 { return st44() }
                } else
                { return st44() }
            } else
            { return tr114() }
            st0()
        }
        
        //#line 2660 "ron/text-parser.cc"
        func case39() {
            switch p.pointee {
            case 13:
                return tr86()
            case 32:
                return tr86()
            case 33:
                return tr87()
            case 39:
                return tr89()
            case 40:
                return tr90()
            case 44:
                return tr87()
            case 59:
                return tr87()
            case 61:
                return tr93()
            case 62:
                return tr94()
            case 63:
                return tr87()
            case 94:
                return tr95()
            case 95:
                return st39()
            case 126:
                return st39()
            case _: break
            }
            if p.pointee < 43 {
                if p.pointee > 10 {
                    if 36 <= p.pointee && p.pointee <= 37 { return tr88() }
                } else if p.pointee >= 9
                { return tr86() }
            } else if p.pointee > 45 {
                if p.pointee < 65 {
                    if 48 <= p.pointee && p.pointee <= 57 { return st39() }
                } else if p.pointee > 90 {
                    if 97 <= p.pointee && p.pointee <= 122 { return st39() }
                } else
                { return st39() }
            } else
            { return tr88() }
            st0()
        }
        
        //#line 2627 "ron/text-parser.cc"
        func case38() {
            switch p.pointee {
            case 95:
                return tr111()
            case 126:
                return tr111()
            case _: break
            }
            if p.pointee < 65 {
                if 48 <= p.pointee && p.pointee <= 57 { return tr111() }
            } else if p.pointee > 90 {
                if 97 <= p.pointee && p.pointee <= 122 { return tr111() }
            } else
            { return tr111() }
            st0()
        }
        
        func case37() {
            switch p.pointee {
            case 13:
                return tr72()
            case 32:
                return tr72()
            case 33:
                return tr73()
            case 39:
                return tr74()
            case 40:
                return tr75()
            case 44:
                return tr73()
            case 59:
                return tr73()
            case 61:
                return tr76()
            case 62:
                return tr77()
            case 63:
                return tr73()
            case 94:
                return tr78()
            case _: break
            }
            if p.pointee > 10 {
                if 48 <= p.pointee && p.pointee <= 57 { return st37() }
            } else if p.pointee >= 9
            { return tr72() }
            st0()
        }
        
        func case36() {
            if 48 <= p.pointee && p.pointee <= 57 { return st37() }
            st0()
        }
        
        func case35() {
            switch p.pointee {
            case 43:
                return st36()
            case 45:
                return st36()
            case _: break
            }
            if 48 <= p.pointee && p.pointee <= 57 { return st37() }
            st0()
        }
        
        //#line 2569 "ron/text-parser.cc"
        func case34() {
            switch p.pointee {
            case 46:
                return st23()
            case 69:
                return st35()
            case 101:
                return st35()
            case _: break
            }
            if 48 <= p.pointee && p.pointee <= 57 { return st34() }
            st0()
        }
        
        //#line 2557 "ron/text-parser.cc"
        func case33() {
            if 48 <= p.pointee && p.pointee <= 57 { return st34() }
            st0()
        }
        
        //#line 2536 "ron/text-parser.cc"
        func case32() {
            switch p.pointee {
            case 13:
                return tr105()
            case 32:
                return tr105()
            case 43:
                return tr106()
            case 45:
                return tr106()
            case _: break
            }
            if p.pointee > 10 {
                if 48 <= p.pointee && p.pointee <= 57 { return tr107() }
            } else if p.pointee >= 9
            { return tr105() }
            st0()
        }
        
        //#line 2310 "ron/text-parser.cc"
        func case31() {
            switch p.pointee {
            case 13:
                return tr97()
            case 32:
                return tr97()
            case 33:
                return tr98()
            case 39:
                return tr99()
            case 40:
                return tr100()
            case 44:
                return tr98()
            case 59:
                return tr98()
            case 61:
                return tr102()
            case 62:
                return tr103()
            case 63:
                return tr98()
            case 94:
                return tr104()
            case 95:
                return st31()
            case 126:
                return st31()
            case _: break
            }
            if p.pointee < 48 {
                if 9 <= p.pointee && p.pointee <= 10 { return tr97() }
            } else if p.pointee > 57 {
                if p.pointee > 90 {
                    if 97 <= p.pointee && p.pointee <= 122 { return st31() }
                } else if p.pointee >= 65
                { return st31() }
            } else
            { return st31() }
            st0()
        }
        
        //#line 2288 "ron/text-parser.cc"
        func case30() {
            switch p.pointee {
            case 95:
                return tr96()
            case 126:
                return tr96()
            case _: break
            }
            if p.pointee < 65 {
                if 48 <= p.pointee && p.pointee <= 57 { return tr96() }
            } else if p.pointee > 90 {
                if 97 <= p.pointee && p.pointee <= 122 { return tr96() }
            } else
            { return tr96() }
            st0()
        }
        
        //#line 2243 "ron/text-parser.cc"
        func case29() {
            switch p.pointee {
            case 13:
                return tr86()
            case 32:
                return tr86()
            case 33:
                return tr87()
            case 39:
                return tr89()
            case 40:
                return tr90()
            case 44:
                return tr87()
            case 47:
                return tr91()
            case 59:
                return tr87()
            case 61:
                return tr93()
            case 62:
                return tr94()
            case 63:
                return tr87()
            case 94:
                return tr95()
            case 95:
                return st39()
            case 126:
                return st39()
            case _: break
            }
            if p.pointee < 43 {
                if p.pointee > 10 {
                    if 36 <= p.pointee && p.pointee <= 37 { return tr88() }
                } else if p.pointee >= 9
                { return tr86() }
            } else if p.pointee > 45 {
                if p.pointee < 65 {
                    if 48 <= p.pointee && p.pointee <= 57 { return st39() }
                } else if p.pointee > 90 {
                    if 97 <= p.pointee && p.pointee <= 122 { return st39() }
                } else
                { return st39() }
            } else
            { return tr88() }
            st0()
        }
        
        //#line 2206 "ron/text-parser.cc"
        func case28() {
            switch p.pointee {
            case 13:
                return tr83()
            case 32:
                return tr83()
            case 95:
                return tr85()
            case 126:
                return tr85()
            case _: break
            }
            if p.pointee < 65 {
                if p.pointee > 10 {
                    if 48 <= p.pointee && p.pointee <= 57 { return tr84() }
                } else if p.pointee >= 9
                { return tr83() }
            } else if p.pointee > 70 {
                if p.pointee > 90 {
                    if 97 <= p.pointee && p.pointee <= 122 { return tr85() }
                } else if p.pointee >= 71
                { return tr85() }
            } else
            { return tr84() }
            st0()
        }
        
        //#line 1988 "ron/text-parser.cc"
        func case27() {
            switch p.pointee {
            case 13:
                return tr62()
            case 32:
                return tr62()
            case 33:
                return tr63()
            case 39:
                return tr64()
            case 40:
                return tr65()
            case 44:
                return tr63()
            case 59:
                return tr63()
            case 61:
                return tr67()
            case 62:
                return tr68()
            case 63:
                return tr63()
            case 94:
                return tr70()
            case _: break
            }
            if p.pointee > 10 {
                if 48 <= p.pointee && p.pointee <= 57 { return st27() }
            } else if p.pointee >= 9
            { return tr62() }
            st0()
        }
        
        //#line 1976 "ron/text-parser.cc"
        func case26() {
            if 48 <= p.pointee && p.pointee <= 57 { return st27() }
            st0()
        }
        
        //#line 1955 "ron/text-parser.cc"
        func case25() {
            switch p.pointee {
            case 13:
                return tr79()
            case 32:
                return tr79()
            case 43:
                return tr80()
            case 45:
                return tr80()
            case _: break
            }
            if p.pointee > 10 {
                if 48 <= p.pointee && p.pointee <= 57 { return tr81() }
            } else if p.pointee >= 9
            { return tr79() }
            st0()
        }
        
        func case24() {
            switch p.pointee {
            case 13:
                return tr72()
            case 32:
                return tr72()
            case 33:
                return tr73()
            case 39:
                return tr74()
            case 40:
                return tr75()
            case 44:
                return tr73()
            case 59:
                return tr73()
            case 61:
                return tr76()
            case 62:
                return tr77()
            case 63:
                return tr73()
            case 69:
                return st35()
            case 94:
                return tr78()
            case 101:
                return st35()
            case _: break
            }
            if p.pointee > 10 {
                if 48 <= p.pointee && p.pointee <= 57 { return st24() }
            } else if p.pointee >= 9
            { return tr72() }
            st0()
        }
        
        func case23() {
            if 48 <= p.pointee && p.pointee <= 57 { return st24() }
            st0()
        }
        
        func case22() {
            switch p.pointee {
            case 13:
                return tr62()
            case 32:
                return tr62()
            case 33:
                return tr63()
            case 39:
                return tr64()
            case 40:
                return tr65()
            case 44:
                return tr63()
            case 46:
                return st23()
            case 59:
                return tr63()
            case 61:
                return tr67()
            case 62:
                return tr68()
            case 63:
                return tr63()
            case 69:
                return st35()
            case 94:
                return tr70()
            case 101:
                return st35()
            case _: break
            }
            if p.pointee > 10 {
                if 48 <= p.pointee && p.pointee <= 57 { return st22() }
            } else if p.pointee >= 9
            { return tr62() }
            st0()
        }
        
        //#line 1695 "ron/text-parser.cc"
        func case21() {
            if 48 <= p.pointee && p.pointee <= 57 { return st22() }
            st0()
        }
        
        //#line 1673 "ron/text-parser.cc"
        func case20() {
            switch p.pointee {
            case 13:
                return tr59()
            case 32:
                return tr59()
            case 41:
                return tr60()
            case _: break
            }
            if p.pointee > 10 {
                if 48 <= p.pointee && p.pointee <= 57 { return tr26() }
            } else if p.pointee >= 9
            { return tr59() }
            st0()
        }
        
        //#line 1658 "ron/text-parser.cc"
        func case19() {
            if 128 <= p.pointee && p.pointee <= 191 { return tr58() }
            st0()
        }
        
        //#line 1626 "ron/text-parser.cc"
        func case18() {
            if 128 <= p.pointee && p.pointee <= 191 { return tr57() }
            st0()
        }
        
        //#line 1590 "ron/text-parser.cc"
        func case17() {
            if 128 <= p.pointee && p.pointee <= 191 { return tr56() }
            st0()
        }
        
        func case16() {
            switch p.pointee {
            case 0:
                return st0()
            case 10:
                return st0()
            case 13:
                return st0()
            case 39:
                return tr51()
            case 92:
                return tr52()
            case _: break
            }
            if p.pointee < 224 {
                if p.pointee > 191 {
                    if 192 <= p.pointee && p.pointee <= 223 { return tr53() }
                } else if p.pointee >= 128
                { return st0() }
            } else if p.pointee > 239 {
                if p.pointee > 247 {
                    if 248 <= p.pointee { return st0() }
                } else if p.pointee >= 240
                { return tr55() }
            } else
            { return tr54() }
            tr50()
        }
        
        func case15() {
            if p.pointee < 65 {
                if 48 <= p.pointee && p.pointee <= 57 { return st16() }
            } else if p.pointee > 70 {
                if 97 <= p.pointee && p.pointee <= 102 { return st16() }
            } else
            { return st16() }
            st0()
        }
        
        func case14() {
            if p.pointee < 65 {
                if 48 <= p.pointee && p.pointee <= 57 { return st15() }
            } else if p.pointee > 70 {
                if 97 <= p.pointee && p.pointee <= 102 { return st15() }
            } else
            { return st15() }
            st0()
        }
        
        func case13() {
            if p.pointee < 65 {
                if 48 <= p.pointee && p.pointee <= 57 { return st14() }
            } else if p.pointee > 70 {
                if 97 <= p.pointee && p.pointee <= 102 { return st14() }
            } else
            { return st14() }
            st0()
        }
        
        func case12() {
            if p.pointee < 65 {
                if 48 <= p.pointee && p.pointee <= 57 { return st13() }
            } else if p.pointee > 70 {
                if 97 <= p.pointee && p.pointee <= 102 { return st13() }
            } else
            { return st13() }
            st0()
        }
        
        //#line 1467 "ron/text-parser.cc"
        func case11() {
            switch p.pointee {
            case 34:
                return tr44()
            case 39:
                return tr44()
            case 47:
                return tr44()
            case 92:
                return tr44()
            case 98:
                return tr44()
            case 110:
                return tr44()
            case 114:
                return tr44()
            case 116:
                return tr44()
            case 117:
                return st12()
            case _: break
            }
            st0()
        }
        
        //#line 1433 "ron/text-parser.cc"
        func case10() {
            switch p.pointee {
            case 13:
                return tr43()
            case 32:
                return tr43()
            case 33:
                return tr14()
            case 44:
                return tr14()
            case 59:
                return tr14()
            case 63:
                return tr14()
            case _: break
            }
            if 9 <= p.pointee && p.pointee <= 10 { return tr43() }
            st0()
        }
        
        //#line 1398 "ron/text-parser.cc"
        func case9() {
            switch p.pointee {
            case 13:
                return tr41()
            case 32:
                return tr41()
            case 41:
                return st10()
            case _: break
            }
            if 9 <= p.pointee && p.pointee <= 10 { return tr41() }
            st0()
        }
        
        //#line 1349 "ron/text-parser.cc"
        func case8() {
            switch p.pointee {
            case 13:
                return tr39()
            case 32:
                return tr39()
            case 41:
                return tr40()
            case _: break
            }
            if 9 <= p.pointee && p.pointee <= 10 { return tr39() }
            st0()
        }
        
        //#line 1289 "ron/text-parser.cc"
        func case7() {
            switch p.pointee {
            case 0:
                return st0()
            case 10:
                return st0()
            case 13:
                return st0()
            case 39:
                return tr34()
            case 92:
                return tr35()
            case _: break
            }
            if p.pointee < 224 {
                if p.pointee > 191 {
                    if 192 <= p.pointee && p.pointee <= 223 { return tr36() }
                } else if p.pointee >= 128
                { return st0() }
            } else if p.pointee > 239 {
                if p.pointee > 247 {
                    if 248 <= p.pointee { return st0() }
                } else if p.pointee >= 240
                { return tr38() }
            } else
            { return tr37() }
            tr33()
        }
        
        func case6() {
            switch p.pointee {
            case 0:
                return st0()
            case 10:
                return st0()
            case 13:
                return st0()
            case 39:
                return tr28()
            case 92:
                return tr29()
            case _: break
            }
            if p.pointee < 224 {
                if p.pointee > 191 {
                    if 192 <= p.pointee && p.pointee <= 223 { return tr30() }
                } else if p.pointee >= 128
                { return st0() }
            } else if p.pointee > 239 {
                if p.pointee > 247 {
                    if 248 <= p.pointee { return st0() }
                } else if p.pointee >= 240
                { return tr32() }
            } else
            { return tr31() }
            tr27()
        }
        
        //#line 1215 "ron/text-parser.cc"
        func case5() {
            switch p.pointee {
            case 13:
                return tr24()
            case 32:
                return tr24()
            case 39:
                return st6()
            case _: break
            }
            if p.pointee > 10 {
                if 48 <= p.pointee && p.pointee <= 57 { return tr26() }
            } else if p.pointee >= 9
            { return tr24() }
            st0()
        }
        
        //#line 983 "ron/text-parser.cc"
        func case4() {
            switch p.pointee {
            case 13:
                return tr13()
            case 32:
                return tr13()
            case 33:
                return tr14()
            case 39:
                return st1()
            case 40:
                return st5()
            case 44:
                return tr14()
            case 59:
                return tr14()
            case 61:
                return st25()
            case 62:
                return st28()
            case 63:
                return tr14()
            case 94:
                return st32()
            case 95:
                return tr23()
            case 126:
                return tr23()
            case _: break
            }
            if p.pointee < 48 {
                if p.pointee > 10 {
                    if 43 <= p.pointee && p.pointee <= 45 { return tr20() }
                } else if p.pointee >= 9
                { return tr13() }
            } else if p.pointee > 57 {
                if p.pointee < 71 {
                    if 65 <= p.pointee && p.pointee <= 70 { return tr22() }
                } else if p.pointee > 90 {
                    if 97 <= p.pointee && p.pointee <= 122 { return tr23() }
                } else
                { return tr23() }
            } else
            { return tr21() }
            st0()
        }
        
        //#line 715 "ron/text-parser.cc"
        func case3() {
            switch p.pointee {
            case 13:
                return tr13()
            case 32:
                return tr13()
            case 33:
                return tr14()
            case 39:
                return st1()
            case 40:
                return st5()
            case 44:
                return tr14()
            case 59:
                return tr14()
            case 61:
                return st25()
            case 62:
                return st28()
            case 63:
                return tr14()
            case 94:
                return st32()
            case _: break
            }
            if 9 <= p.pointee && p.pointee <= 10 { return tr13() }
            st0()
        }
        
        //#line 655 "ron/text-parser.cc"
        func case2() {
            switch p.pointee {
            case 0:
                return st0()
            case 10:
                return st0()
            case 13:
                return st0()
            case 39:
                return tr8()
            case 92:
                return tr9()
            case _: break
            }
            if p.pointee < 224 {
                if p.pointee > 191 {
                    if 192 <= p.pointee && p.pointee <= 223 { return tr10() }
                } else if p.pointee >= 128
                { return st0() }
            } else if p.pointee > 239 {
                if p.pointee > 247 {
                    if 248 <= p.pointee { return st0() }
                } else if p.pointee >= 240
                { return tr12() }
            } else
            { return tr11() }
            return tr7()
        }
        
        //#line 596 "ron/text-parser.cc"
        func case1() {
            switch p.pointee {
            case 0:
                return st0()
            case 10:
                return st0()
            case 13:
                return st0()
            case 39:
                return tr2()
            case 92:
                return tr3()
            case _: break
            }
            if p.pointee < 224 {
                if p.pointee > 191 {
                    if 192 <= p.pointee && p.pointee <= 223 { return tr4() }
                } else if p.pointee >= 128
                { return st0() }
            } else if p.pointee > 239 {
                if p.pointee > 247 {
                    if 248 <= p.pointee { return st0() }
                } else if p.pointee >= 240
                { return tr6() }
            } else
            { return tr5() }
            return tr0()
        }
        
        //#line 368 "ron/text-parser.cc"
        func case74() {
            switch p.pointee {
            case 13:
                return tr223()
            case 32:
                return tr223()
            case 33:
                return tr14()
            case 39:
                return st1()
            case 40:
                return st5()
            case 44:
                return tr14()
            case 46:
                return st60()
            case 59:
                return tr14()
            case 61:
                return st25()
            case 62:
                return st28()
            case 63:
                return tr14()
            case 64:
                return st61()
            case 94:
                return st32()
            case 95:
                return tr23()
            case 126:
                return tr23()
            case _: break
            }
            
            if p.pointee < 48 {
                if p.pointee > 10 {
                    if 43 <= p.pointee && p.pointee <= 45 { return tr20() }
                } else if p.pointee >= 9 {
                    return tr223()
                }
            } else if p.pointee > 57 {
                if p.pointee < 71 {
                    if 65 <= p.pointee && p.pointee <= 70 { return tr22() }
                } else if p.pointee > 90 {
                    if 97 <= p.pointee && p.pointee <= 122 { return tr23() }
                } else {
                    return tr23()
                }
            } else {
                return tr21()
            }
            st0()
        }
        
        func st74() {
            p += 1
            if p == pe {
                testEof(cs: 74)
            } else {
                case74()
            }
        }
        
        //#line 6 "ragel/././uuid-grammar.rl"
        @inline(__always)
        func line6UUIDGrammar() {
            variety = "0"
            version = "$"
            origin = .init()
            uuidb = p
        }
        
        //#line 7 "ragel/././utf8-grammar.rl"
        @inline(__always)
        func line7Utf8Grammar() {
            cp = (cp << 6) | (.init(p.pointee) & 0x3f)
        }
        
        //#line 8 "ragel/././utf8-grammar.rl"
        @inline(__always)
        func line8Utf8Grammar() {
            cp = .init(p.pointee)
        }
        
        //#line 9 "ragel/./text-grammar.rl"
        @inline(__always)
        func line9TextGrammar() {
            op[0] = Ron.UUID(variety: .init(variety),
                             value: value,
                             version: .init(version),
                             origin: origin)
        }
        
        //#line 9 "ragel/././utf8-grammar.rl"
        @inline(__always)
        func line9Utf8Grammar() {
            cp = .init(p.pointee) & 0x1f
        }
        
        //#line 10 "ragel/././utf8-grammar.rl"
        @inline(__always)
        func line10Utf8Grammar() {
            cp = .init(p.pointee) & 0xf
        }
        
        //#line 11 "ragel/././utf8-grammar.rl"
        @inline(__always)
        func line11Utf8Grammar() {
            cp = .init(p.pointee) & 7
        }
        
        //#line 12 "ragel/./text-grammar.rl"
        @inline(__always)
        func line12TextGrammar() {
            op[1] = Ron.UUID(variety: .init(variety),
                             value: value,
                             version: .init(version),
                             origin: origin)
        }
        
        //#line 12 "ragel/././uuid-grammar.rl"
        @inline(__always)
        func line12UUIDGrammar() {
            variety = .init((p - 1).pointee)
        }
        
        //#line 13 "ragel/././uuid-grammar.rl"
        @inline(__always)
        func line13UUIDGrammar() {
            wordb = p
        }
        
        //#line 14 "ragel/././uuid-grammar.rl"
        @inline(__always)
        func line14UUIDGrammar() {
            value = data.slice(range: wordb..<p,
                               root: root)
        }
        
        //#line 15 "ragel/././uuid-grammar.rl"
        @inline(__always)
        func line15UUIDGrammar() {
            version = .init(p.pointee)
        }
        
        //#line 15 "ragel/./text-grammar.rl"
        @inline(__always)
        func line15TextGrammar() {
            intb = p
        }
        
        //#line 16 "ragel/././uuid-grammar.rl"
        @inline(__always)
        func line16UUIDGrammar() {
            wordb = p
        }
        
        //#line 16 "ragel/./text-grammar.rl"
        @inline(__always)
        func line16TextGrammar(cs _cs: UInt8, _ body: () -> Void) {
            let range = intb..<p
            if range.count >= 19 && data.slice(range: range,
                                               root: root).intTooBig {
                p += 1
                ragelState = _cs
                return out()
            }
            
            op.append(Ron.Atom(type: .int,
                               range: range.inIntRange(root: root)))
            uuidb = nil // sabotage uuid
            body()
        }
        
        //#line 17 "ragel/././uuid-grammar.rl"
        @inline(__always)
        func line17UUIDGrammar() {
            origin = data.slice(range: wordb..<p,
                                root: root)
        }
        
        //#line 18 "ragel/././uuid-grammar.rl"
        @inline(__always)
        func line18UUIDGrammar() {}
        
        //#line 22 "ragel/./text-grammar.rl"
        @inline(__always)
        func line22TextGrammar() {
            strb = p
            cpSize = 0
        }
        
        //#line 23 "ragel/./text-grammar.rl"
        @inline(__always)
        func line23TextGrammar() {
            var atom = Ron.Atom(type: .string,
                                range: (strb..<p).inIntRange(root: root))
            atom.value.cpSize = cpSize - escapedCnt
            op.append(atom)
            escapedCnt = 0
        }
        
        //#line 27 "ragel/./text-grammar.rl"
        @inline(__always)
        func line27TextGrammar() {
            floatb = p
        }
        
        //#line 28 "ragel/./text-grammar.rl"
        @inline(__always)
        func line28TextGrammar(cs _cs: UInt8, _ body: () -> Void) {
            let range = floatb..<p
            if range.count > 24 {
                p += 1
                ragelState = _cs
                return out()
            }
            op.append(Ron.Atom(type: .float,
                               range: range.inIntRange(root: root)))
            body()
        }
        
        //#line 33 "ragel/./text-grammar.rl"
        @inline(__always)
        func line33TextGrammar(cs _cs: UInt8, _ body: () -> Void) {
            if value.wordTooBig || origin.wordTooBig {
                p += 1
                ragelState = _cs
                return out()
            }
            op.append(Ron.UUID(variety: .init(variety),
                               value: value,
                               version: .init(version),
                               origin: origin))
            body()
        }
        
        //#line 37 "ragel/./text-grammar.rl"
        @inline(__always)
        func line37TextGrammar(cs _cs: UInt8, _ body: () -> Void) {
            if uuidb != nil { // " 123 " is an int, not an UUID
                if value.wordTooBig || origin.wordTooBig {
                    p += 1
                    ragelState = _cs
                    return out()
                }
                op.append(Ron.UUID(variety: .init(variety),
                                   value: value,
                                   version: .init(version),
                                   origin: origin))
            }
            body()
        }
        
        //#line 43 "ragel/./text-grammar.rl"
        @inline(__always)
        func line43TextGrammar() {
            cpSize += 1
        }
        
        //#line 48 "ragel/./text-grammar.rl"
        @inline(__always)
        func line48TextGrammar(cs _cs: UInt8, _ body: () -> Void) {
            term = p.pointee
            if (p < pe - 1) {
                p += 1
                ragelState = _cs
                return out()
            }
            body()
        }
        
        //#line 52 "ragel/./text-grammar.rl"
        @inline(__always)
        func line52TextGrammar() {
            if p.pointee == "\n" {
                line += 1
                lineb = p
            }
        }
        
        //#line 58 "ragel/./text-grammar.rl"
        @inline(__always)
        func line58TextGrammar() {
            cp = .init(p.pointee.decodedEsc)
            escapedCnt += 1
        }
        
        //#line 59 "ragel/./text-grammar.rl"
        @inline(__always)
        func line59TextGrammar() {
            cp = data.slice(range: p - 4..<p,
                            root: root)
                .decodedHexCp
        }
        
        //#line 61 "ragel/./text-grammar.rl"
        @inline(__always)
        func line61TextGrammar() {
            spanSize *= 10
            spanSize += .init(p.pointee - "0")
        }
        
        //#line 65 "ragel/./text-grammar.rl"
        @inline(__always)
        func line65TextGrammar() {
            spanSize -= 1
        }
        
        //#line 68 "ragel/./text-grammar.rl"
        @inline(__always)
        func line68TextGrammar() {
            if op.last?.value.cpSize ?? 0 > 0 {
                _ = nextCodepoint(&op[op.count - 1])
            }
            spanSize = cpSize - 1
        }
        
        func tr223() {
            line52TextGrammar()
            
            st74()
        }
        
        func tr14() {
            line48TextGrammar(cs: 74, st74)
        }
        
        func tr63() {
            line16TextGrammar(cs: 74) {
                line48TextGrammar(cs: 74, st74)
            }
        }
        
        func tr73() {
            line28TextGrammar(cs: 74) {
                line48TextGrammar(cs: 74, st74)
            }
        }
        
        func tr87() {
            line14UUIDGrammar()
            
            line18UUIDGrammar()
            
            line33TextGrammar(cs: 74) {
                line48TextGrammar(cs: 74, st74)
            }
        }
        
        func tr98() {
            line17UUIDGrammar()
            
            line18UUIDGrammar()
            
            line33TextGrammar(cs: 74) {
                line48TextGrammar(cs: 74, st74)
            }
        }
        
        func tr113() {
            line16TextGrammar(cs: 74) {
                line14UUIDGrammar()
                
                line18UUIDGrammar()
                
                line37TextGrammar(cs: 74) {
                    line48TextGrammar(cs: 74, st74)
                }
            }
        }
        
        func tr126() {
            line17UUIDGrammar()
            
            line18UUIDGrammar()
            
            line37TextGrammar(cs: 74) {
                line48TextGrammar(cs: 74, st74)
            }
        }
        
        func tr135() {
            line14UUIDGrammar()
            
            line18UUIDGrammar()
            
            line37TextGrammar(cs: 74) {
                line48TextGrammar(cs:74, st74)
            }
        }
        
        func tr145() {
            line28TextGrammar(cs: 74) {
                line17UUIDGrammar()
                
                line18UUIDGrammar()
                
                line37TextGrammar(cs: 74) {
                    line48TextGrammar(cs: 74, st74)
                }
            }
        }
        
        func tr153() {
            line28TextGrammar(cs: 74) {
                line14UUIDGrammar()
                
                line18UUIDGrammar()
                
                line37TextGrammar(cs: 74) {
                    line48TextGrammar(cs: 74, st74)
                }
            }
        }
        
        func tr178() {
            line14UUIDGrammar()
            
            line18UUIDGrammar()
            
            line9TextGrammar()
            
            line48TextGrammar(cs: 74, st74)
        }
        
        func tr193() {
            line14UUIDGrammar()
            
            line18UUIDGrammar()
            
            line12TextGrammar()
            
            line48TextGrammar(cs: 74, st74)
        }
        
        func tr204() {
            line17UUIDGrammar()
            
            line18UUIDGrammar()
            
            line12TextGrammar()
            
            line48TextGrammar(cs: 74, st74)
        }
        
        func tr214() {
            line17UUIDGrammar()
            
            line18UUIDGrammar()
            
            line9TextGrammar()
            
            line48TextGrammar(cs: 74, st74)
        }
        
        func tr64() {
            line16TextGrammar(cs: 1, st1)
        }
        
        func tr74() {
            line28TextGrammar(cs: 1, st1)
        }
        
        func tr89() {
            line14UUIDGrammar()
            
            line18UUIDGrammar()
            
            line33TextGrammar(cs: 1, st1)
        }
        
        func tr99() {
            line17UUIDGrammar()
            
            line18UUIDGrammar()
            
            line33TextGrammar(cs: 1, st1)
        }
        
        func tr115() {
            line16TextGrammar(cs: 1) {
                line14UUIDGrammar()
                
                line18UUIDGrammar()
                
                line37TextGrammar(cs: 1, st1)
            }
        }
        
        func tr127() {
            line17UUIDGrammar()
            
            line18UUIDGrammar()
            
            line37TextGrammar(cs: 1, st1)
        }
        
        func tr136() {
            line14UUIDGrammar()
            
            line18UUIDGrammar()
            
            line37TextGrammar(cs: 1, st1)
        }
        
        func tr146() {
            line28TextGrammar(cs: 1) {
                line17UUIDGrammar()
                
                line18UUIDGrammar()
                
                line37TextGrammar(cs: 1, st1)
            }
        }
        
        func tr154() {
            line28TextGrammar(cs: 1) {
                line14UUIDGrammar()
                
                line18UUIDGrammar()
                
                line37TextGrammar(cs: 1, st1)
            }
        }
        
        func tr180() {
            line14UUIDGrammar()
            
            line18UUIDGrammar()
            
            line9TextGrammar()
            
            st1()
        }
        
        func tr195() {
            line14UUIDGrammar()
            
            line18UUIDGrammar()
            
            line12TextGrammar()
            
            st1()
        }
        
        func tr205() {
            line17UUIDGrammar()
            
            line18UUIDGrammar()
            
            line12TextGrammar()
            
            st1()
        }
        
        func tr215() {
            line17UUIDGrammar()
            
            line18UUIDGrammar()
            
            line9TextGrammar()
            
            st1()
        }
        
        func tr0() {
            line22TextGrammar()
            
            line8Utf8Grammar()
            
            st2()
        }
        
        func tr7() {
            line43TextGrammar()
            
            line8Utf8Grammar()
            
            st2()
        }
        
        func tr159() {
            line58TextGrammar()
            
            line59TextGrammar()
            
            line43TextGrammar()
            
            line8Utf8Grammar()
            
            st2()
        }
        
        func tr165() {
            line59TextGrammar()
            
            line43TextGrammar()
            
            line8Utf8Grammar()
            
            st2()
        }
        
        func tr171() {
            line7Utf8Grammar()
            
            st2()
        }
        
        func tr2() {
            line22TextGrammar()
            
            line23TextGrammar()
            
            st3()
        }
        
        func tr8() {
            line43TextGrammar()
            
            line23TextGrammar()
            
            st3()
        }
        
        func tr166() {
            line59TextGrammar()
            
            line43TextGrammar()
            
            line23TextGrammar()
            
            st3()
        }
        
        func tr13() {
            line52TextGrammar()
            
            st4()
        }
        
        func tr62() {
            line16TextGrammar(cs: 4) {
                line52TextGrammar()
                
                st4()
            }
        }
        
        func tr72() {
            line28TextGrammar(cs: 4) {
                line52TextGrammar()
                
                st4()
            }
        }
        
        func tr86() {
            line14UUIDGrammar()
            
            line18UUIDGrammar()
            
            line33TextGrammar(cs: 4) {
                line52TextGrammar()
                
                st4()
            }
        }
        
        func tr97() {
            line17UUIDGrammar()
            
            line18UUIDGrammar()
            
            line33TextGrammar(cs: 4) {
                line52TextGrammar()
                
                st4()
            }
        }
        
        func tr112() {
            line16TextGrammar(cs: 4) {
                line14UUIDGrammar()
                
                line18UUIDGrammar()
                
                line37TextGrammar(cs: 4) {
                    line52TextGrammar()
                    
                    st4()
                }
            }
        }
        
        func tr125() {
            line17UUIDGrammar()
            
            line18UUIDGrammar()
            
            line37TextGrammar(cs: 4) {
                line52TextGrammar()
                
                st4()
            }
        }
        
        func tr134() {
            line14UUIDGrammar()
            
            line18UUIDGrammar()
            
            line37TextGrammar(cs: 4) {
                line52TextGrammar()
                
                st4()
            }
        }
        
        func tr144() {
            line28TextGrammar(cs: 4) {
                line17UUIDGrammar()
                
                line18UUIDGrammar()
                
                line37TextGrammar(cs: 4) {
                    line52TextGrammar()
                    
                    st4()
                }
            }
        }
        
        func tr152() {
            line28TextGrammar(cs: 4) {
                line14UUIDGrammar()
                
                line18UUIDGrammar()
                
                line37TextGrammar(cs: 4) {
                    line52TextGrammar()
                    
                    st4()
                }
            }
        }
        
        func tr192() {
            line14UUIDGrammar()
            
            line18UUIDGrammar()
            
            line12TextGrammar()
            
            line52TextGrammar()
            
            st4()
        }
        
        func tr203() {
            line17UUIDGrammar()
            
            line18UUIDGrammar()
            
            line12TextGrammar()
            
            line52TextGrammar()
            
            st4()
        }
        
        func tr24() {
            line52TextGrammar()
            
            st5()
        }
        
        func tr65() {
            line16TextGrammar(cs: 5, st5)
        }
        
        func tr75() {
            line28TextGrammar(cs: 5, st5)
        }
        
        func tr90() {
            line14UUIDGrammar()
            
            line18UUIDGrammar()
            
            line33TextGrammar(cs: 5, st5)
        }
        
        func tr100() {
            line17UUIDGrammar()
            
            line18UUIDGrammar()
            
            line33TextGrammar(cs: 5, st5)
        }
        
        func tr116() {
            line16TextGrammar(cs: 5) {
                line14UUIDGrammar()
                
                line18UUIDGrammar()
                
                line37TextGrammar(cs: 5, st5)
            }
        }
        
        func tr128() {
            line17UUIDGrammar()
            
            line18UUIDGrammar()
            
            line37TextGrammar(cs: 5, st5)
        }
        
        func tr137() {
            line14UUIDGrammar()
            
            line18UUIDGrammar()
            
            line37TextGrammar(cs: 5, st5)
        }
        
        func tr147() {
            line28TextGrammar(cs: 5) {
                line17UUIDGrammar()
                
                line18UUIDGrammar()
                
                line37TextGrammar(cs: 5, st5)
            }
        }
        
        func tr155() {
            line28TextGrammar(cs: 5) {
                line14UUIDGrammar()
                
                line18UUIDGrammar()
                
                line37TextGrammar(cs: 5, st5)
            }
        }
        
        func tr181() {
            line14UUIDGrammar()
            
            line18UUIDGrammar()
            
            line9TextGrammar()
            
            st5()
        }
        
        func tr196() {
            line14UUIDGrammar()
            
            line18UUIDGrammar()
            
            line12TextGrammar()
            
            st5()
        }
        
        func tr206() {
            line17UUIDGrammar()
            
            line18UUIDGrammar()
            
            line12TextGrammar()
            
            st5()
        }
        
        func tr216() {
            line17UUIDGrammar()
            
            line18UUIDGrammar()
            
            line9TextGrammar()
            
            st5()
        }
        
        func tr27() {
            line22TextGrammar()
            
            line8Utf8Grammar()
            
            st7()
        }
        
        func tr33() {
            line43TextGrammar()
            
            line8Utf8Grammar()
            
            st7()
        }
        
        func tr44() {
            line58TextGrammar()
            
            st7()
        }
        
        func tr50() {
            line59TextGrammar()
            
            line43TextGrammar()
            
            line8Utf8Grammar()
            
            st7()
        }
        
        func tr56() {
            line7Utf8Grammar()
            
            st7()
        }
        
        func tr28() {
            line22TextGrammar()
            
            line23TextGrammar()
            
            st8()
        }
        
        func tr34() {
            line43TextGrammar()
            
            line23TextGrammar()
            
            st8()
        }
        
        func tr51() {
            line59TextGrammar()
            
            line43TextGrammar()
            
            line23TextGrammar()
            
            st8()
        }
        
        func tr41() {
            line52TextGrammar()
            
            st9()
        }
        
        func tr39() {
            line68TextGrammar()
            
            line52TextGrammar()
            
            st9()
        }
        
        func tr59() {
            line65TextGrammar()
            
            line52TextGrammar()
            
            st9()
        }
        
        func tr43() {
            line52TextGrammar()
            
            st10()
        }
        
        func tr40() {
            line68TextGrammar()
            
            st10()
        }
        
        func tr60() {
            line65TextGrammar()
            
            st10()
        }
        
        func tr29() {
            line22TextGrammar()
            
            st11()
        }
        
        func tr35() {
            line43TextGrammar()
            
            st11()
        }
        
        func tr52() {
            line59TextGrammar()
            
            line43TextGrammar()
            
            st11()
        }
        
        func tr30() {
            line22TextGrammar()
            
            line9Utf8Grammar()
            
            st17()
        }
        
        func tr36() {
            line43TextGrammar()
            
            line9Utf8Grammar()
            
            st17()
        }
        
        func tr53() {
            line59TextGrammar()
            
            line43TextGrammar()
            
            line9Utf8Grammar()
            
            st17()
        }
        
        func tr57() {
            line7Utf8Grammar()
            
            st17()
        }
        
        func tr31() {
            line22TextGrammar()
            
            line10Utf8Grammar()
            
            st18()
        }
        
        func tr37() {
            line43TextGrammar()
            
            line10Utf8Grammar()
            
            st18()
        }
        
        func tr54() {
            line59TextGrammar()
            
            line43TextGrammar()
            
            line10Utf8Grammar()
            
            st18()
        }
        
        func tr58() {
            line7Utf8Grammar()
            
            st18()
        }
        
        func tr32() {
            line22TextGrammar()
            
            line11Utf8Grammar()
            
            st19()
        }
        
        func tr38() {
            line43TextGrammar()
            
            line11Utf8Grammar()
            
            st19()
        }
        
        func tr55() {
            line59TextGrammar()
            
            line43TextGrammar()
            
            line11Utf8Grammar()
            
            st19()
        }
        
        func tr26() {
            line61TextGrammar()
            
            st20()
        }
        
        func tr20() {
            line15TextGrammar()
            
            line27TextGrammar()
            
            st21()
        }
        
        func tr79() {
            line52TextGrammar()
            
            st25()
        }
        
        func tr67() {
            line16TextGrammar(cs: 25, st25)
        }
        
        func tr76() {
            line28TextGrammar(cs: 25, st25)
        }
        
        func tr93() {
            line14UUIDGrammar()
            
            line18UUIDGrammar()
            
            line33TextGrammar(cs: 25, st25)
        }
        
        func tr119() {
            line16TextGrammar(cs: 25) {
                line14UUIDGrammar()
                
                line18UUIDGrammar()
                
                line37TextGrammar(cs: 25, st25)
            }
        }
        
        func tr102() {
            line17UUIDGrammar()
            
            line18UUIDGrammar()
            
            line33TextGrammar(cs: 25, st25)
        }
        
        func tr130() {
            line17UUIDGrammar()
            
            line18UUIDGrammar()
            
            line37TextGrammar(cs: 25, st25)
        }
        
        func tr138() {
            line14UUIDGrammar()
            
            line18UUIDGrammar()
            
            line37TextGrammar(cs: 25, st25)
        }
        
        func tr149() {
            line28TextGrammar(cs: 25) {
                line17UUIDGrammar()
                
                line18UUIDGrammar()
                
                line37TextGrammar(cs: 25, st25)
            }
        }
        
        func tr156() {
            line28TextGrammar(cs: 25) {
                line14UUIDGrammar()
                
                line18UUIDGrammar()
                
                line37TextGrammar(cs: 25, st25)
            }
        }
        
        func tr185() {
            line14UUIDGrammar()
            
            line18UUIDGrammar()
            
            line9TextGrammar()
            
            st25()
        }
        
        func tr199() {
            line14UUIDGrammar()
            
            line18UUIDGrammar()
            
            line12TextGrammar()
            
            st25()
        }
        
        func tr208() {
            line17UUIDGrammar()
            
            line18UUIDGrammar()
            
            line12TextGrammar()
            
            st25()
        }
        
        func tr219() {
            line17UUIDGrammar()
            
            line18UUIDGrammar()
            
            line9TextGrammar()
            
            st25()
        }
        
        func tr80() {
            line15TextGrammar()
            
            st26()
        }
        
        func tr81() {
            line15TextGrammar()
            
            st27()
        }
        
        func tr83() {
            line52TextGrammar()
            
            st28()
        }
        
        func tr68() {
            line16TextGrammar(cs: 28, st28)
        }
        
        func tr77() {
            line28TextGrammar(cs: 28, st28)
        }
        
        func tr94() {
            line14UUIDGrammar()
            
            line18UUIDGrammar()
            
            line33TextGrammar(cs: 28, st28)
        }
        
        func tr103() {
            line17UUIDGrammar()
            
            line18UUIDGrammar()
            
            line33TextGrammar(cs: 28, st28)
        }
        
        func tr120() {
            line16TextGrammar(cs: 28) {
                line14UUIDGrammar()
                
                line18UUIDGrammar()
                
                line37TextGrammar(cs: 28, st28)
            }
        }
        
        func tr131() {
            line17UUIDGrammar()
            
            line18UUIDGrammar()
            
            line37TextGrammar(cs: 28, st28)
        }
        
        func tr139() {
            line14UUIDGrammar()
            
            line18UUIDGrammar()
            
            line37TextGrammar(cs: 28, st28)
        }
        
        func tr150() {
            line28TextGrammar(cs: 28) {
                line17UUIDGrammar()
                
                line18UUIDGrammar()
                
                line37TextGrammar(cs: 28, st28)
            }
        }
        
        func tr186() {
            line14UUIDGrammar()
            
            line18UUIDGrammar()
            
            line9TextGrammar()
            
            st28()
        }
        
        func tr200() {
            line14UUIDGrammar()
            
            line18UUIDGrammar()
            
            line12TextGrammar()
            
            st28()
        }
        
        func tr209() {
            line17UUIDGrammar()
            
            line18UUIDGrammar()
            
            line12TextGrammar()
            
            st28()
        }
        
        func tr220() {
            line17UUIDGrammar()
            
            line18UUIDGrammar()
            
            line9TextGrammar()
            
            st28()
        }
        
        func tr157() {
            line28TextGrammar(cs: 28) {
                line14UUIDGrammar()
                
                line18UUIDGrammar()
                
                line37TextGrammar(cs: 28, st28)
            }
        }
        
        func tr84() {
            line6UUIDGrammar()
            
            line13UUIDGrammar()
            
            st29()
        }
        
        func tr88() {
            line14UUIDGrammar()
            
            line15UUIDGrammar()
            
            st30()
        }
        
        func tr96() {
            line16UUIDGrammar()
            
            st31()
        }
        
        func tr105() {
            line52TextGrammar()
            
            st32()
        }
        
        func tr70() {
            line16TextGrammar(cs: 32, st32)
        }
        
        func tr78() {
            line28TextGrammar(cs: 32, st32)
        }
        
        func tr95() {
            line14UUIDGrammar()
            
            line18UUIDGrammar()
            
            line33TextGrammar(cs: 32, st32)
        }
        
        func tr104() {
            line17UUIDGrammar()
            
            line18UUIDGrammar()
            
            line33TextGrammar(cs: 32, st32)
        }
        
        func tr123() {
            line16TextGrammar(cs: 32) {
                line14UUIDGrammar()
                
                line18UUIDGrammar()
                
                line37TextGrammar(cs: 32, st32)
            }
        }
        
        func tr132() {
            line17UUIDGrammar()
            
            line18UUIDGrammar()
            
            line37TextGrammar(cs: 32, st32)
        }
        
        func tr140() {
            line14UUIDGrammar()
            
            line18UUIDGrammar()
            
            line37TextGrammar(cs: 32, st32)
        }
        
        func tr151() {
            line28TextGrammar(cs: 32) {
                line17UUIDGrammar()
                
                line18UUIDGrammar()
                
                line37TextGrammar(cs: 32, st32)
            }
        }
        
        func tr158() {
            line28TextGrammar(cs: 32) {
                line14UUIDGrammar()
                
                line18UUIDGrammar()
                
                line37TextGrammar(cs: 32, st32)
            }
        }
        
        func tr187() {
            line14UUIDGrammar()
            
            line18UUIDGrammar()
            
            line9TextGrammar()
            
            st32()
        }
        
        func tr201() {
            line14UUIDGrammar()
            
            line18UUIDGrammar()
            
            line12TextGrammar()
            
            st32()
        }
        
        func tr210() {
            line17UUIDGrammar()
            
            line18UUIDGrammar()
            
            line12TextGrammar()
            
            st32()
        }
        
        func tr221() {
            line17UUIDGrammar()
            
            line18UUIDGrammar()
            
            line9TextGrammar()
            
            st32()
        }
        
        func tr106() {
            line27TextGrammar()
            
            st33()
        }
        
        func tr107() {
            line27TextGrammar()
            
            st34()
        }
        
        func tr91() {
            line12UUIDGrammar()
            
            st38()
        }
        
        func tr85() {
            line6UUIDGrammar()
            
            line13UUIDGrammar()
            
            st39()
        }
        
        func tr111() {
            line13UUIDGrammar()
            
            st39()
        }
        
        func tr21() {
            line15TextGrammar()
            
            line27TextGrammar()
            
            line6UUIDGrammar()
            
            line13UUIDGrammar()
            
            st40()
        }
        
        func tr114() {
            line14UUIDGrammar()
            
            line15UUIDGrammar()
            
            st41()
        }
        
        func tr124() {
            line16UUIDGrammar()
            
            st42()
        }
        
        func tr117() {
            line12UUIDGrammar()
            
            st43()
        }
        
        func tr23() {
            line6UUIDGrammar()
            
            line13UUIDGrammar()
            
            st44()
        }
        
        func tr133() {
            line13UUIDGrammar()
            
            st44()
        }
        
        func tr141() {
            line14UUIDGrammar()
            
            line15UUIDGrammar()
            
            st47()
        }
        
        func tr143() {
            line16UUIDGrammar()
            
            st48()
        }
        
        func tr22() {
            line6UUIDGrammar()
            
            line13UUIDGrammar()
            
            st50()
        }
        
        func tr3() {
            line22TextGrammar()
            
            st51()
        }
        
        func tr9() {
            line43TextGrammar()
            
            st51()
        }
        
        func tr167() {
            line59TextGrammar()
            
            line43TextGrammar()
            
            st51()
        }
        
        func tr4() {
            line22TextGrammar()
            
            line9Utf8Grammar()
            
            st57()
        }
        
        func tr10() {
            line43TextGrammar()
            
            line9Utf8Grammar()
            
            st57()
        }
        
        func tr168() {
            line59TextGrammar()
            
            line43TextGrammar()
            
            line9Utf8Grammar()
            
            st57()
        }
        
        func tr172() {
            line7Utf8Grammar()
            
            st57()
        }
        
        func tr5() {
            line22TextGrammar()
            
            line10Utf8Grammar()
            
            st58()
        }
        
        func tr11() {
            line43TextGrammar()
            
            line10Utf8Grammar()
            
            st58()
        }
        
        func tr169() {
            line59TextGrammar()
            
            line43TextGrammar()
            
            line10Utf8Grammar()
            
            st58()
        }
        
        func tr173() {
            line7Utf8Grammar()
            
            st58()
        }
        
        func tr6() {
            line22TextGrammar()
            
            line11Utf8Grammar()
            
            st59()
        }
        
        func tr12() {
            line43TextGrammar()
            
            line11Utf8Grammar()
            
            st59()
        }
        
        func tr170() {
            line59TextGrammar()
            
            line43TextGrammar()
            
            line11Utf8Grammar()
            
            st59()
        }
        
        func tr175() {
            line6UUIDGrammar()
            
            line13UUIDGrammar()
            
            st62()
        }
        
        func tr188() {
            line52TextGrammar()
            
            st63()
        }
        
        func tr177() {
            line14UUIDGrammar()
            
            line18UUIDGrammar()
            
            line9TextGrammar()
            
            line52TextGrammar()
            
            st63()
        }
        
        func tr213() {
            line17UUIDGrammar()
            
            line18UUIDGrammar()
            
            line9TextGrammar()
            
            line52TextGrammar()
            
            st63()
        }
        
        func tr184() {
            line14UUIDGrammar()
            
            line18UUIDGrammar()
            
            line9TextGrammar()
            
            st64()
        }
        
        func tr218() {
            line17UUIDGrammar()
            
            line18UUIDGrammar()
            
            line9TextGrammar()
            
            st64()
        }
        
        func tr190() {
            line6UUIDGrammar()
            
            line13UUIDGrammar()
            
            st65()
        }
        
        func tr194() {
            line14UUIDGrammar()
            
            line15UUIDGrammar()
            
            st66()
        }
        
        func tr202() {
            line16UUIDGrammar()
            
            st67()
        }
        
        func tr197() {
            line12UUIDGrammar()
            
            st68()
        }
        
        func tr191() {
            line6UUIDGrammar()
            
            line13UUIDGrammar()
            
            st69()
        }
        
        func tr211() {
            line13UUIDGrammar()
            
            st69()
        }
        
        func tr179() {
            line14UUIDGrammar()
            
            line15UUIDGrammar()
            
            st70()
        }
        
        func tr212() {
            line16UUIDGrammar()
            
            st71()
        }
        
        func tr182() {
            line12UUIDGrammar()
            
            st72()
        }
        
        func tr176() {
            line6UUIDGrammar()
            
            line13UUIDGrammar()
            
            st73()
        }
        
        func tr222() {
            line13UUIDGrammar()
            
            st73()
        }
        
        if p == pe {
            testEof()
        } else {
            switch ragelState {
            case 74: case74()
            case 1: case1()
            case 2: case2()
            case 3: case3()
            case 4: case4()
            case 5: case5()
            case 6: case6()
            case 7: case7()
            case 8: case8()
            case 9: case9()
            case 10: case10()
            case 11: case11()
            case 12: case12()
            case 13: case13()
            case 14: case14()
            case 15: case15()
            case 16: case16()
            case 17: case17()
            case 18: case18()
            case 19: case19()
            case 20: case20()
            case 21: case21()
            case 22: case22()
            case 23: case23()
            case 24: case24()
            case 25: case25()
            case 26: case26()
            case 27: case27()
            case 28: case28()
            case 29: case29()
            case 30: case30()
            case 31: case31()
            case 32: case32()
            case 33: case33()
            case 34: case34()
            case 35: case35()
            case 36: case36()
            case 37: case37()
            case 38: case38()
            case 39: case39()
            case 40: case40()
            case 41: case41()
            case 42: case42()
            case 43: case43()
            case 44: case44()
            case 45: case45()
            case 46: case46()
            case 47: case47()
            case 48: case48()
            case 49: case49()
            case 50: case50()
            case 51: case51()
            case 52: case52()
            case 53: case53()
            case 54: case54()
            case 55: case55()
            case 56: case56()
            case 57: case57()
            case 58: case58()
            case 59: case59()
            case 60: case60()
            case 61: case61()
            case 62: case62()
            case 63: case63()
            case 64: case64()
            case 65: case65()
            case 66: case66()
            case 67: case67()
            case 68: case68()
            case 69: case69()
            case 70: case70()
            case 71: case71()
            case 72: case72()
            case 73: case73()
            case _: break
            }
        }
        
        data.consume(p - pb)
        
        if term != 0 && ragelState != Self.error {
            self.term = .init(punct: term)!
            return .ok
        } else if ragelState >= Self.firstFinal {
            ragelState = Self.error
            return .endOfFrame
        } else {
            ragelState = Self.error
            let msg = "syntax error at line \(line) col \(p - lineb) (offset \(p - pb))"
            return .badState.commenting(msg)
        }
    }
}
