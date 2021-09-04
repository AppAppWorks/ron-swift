public extension Ron.UUID {
    private static let start = 1
    private static let firstFinal = 4
    private static let error = 0

    private static let enMain = 1
    
    init(data: Slice) {
        self = data.withUTF8 { root, pb, pe in
            var p = pb
            let eof = pe
            var uuidb = p
            var wordb = p
            var cs = 0
            var value = Slice()
            var origin = Slice()
            
            var variety: UInt8 = "0"
            var version: UInt8 = "$"
            
            cs = Self.start
            
            func st0() {
                cs = 0
            }
            
            func st4() {
                if ++p == pe {
                    _test_eof4()
                } else {
                    case4()
                }
            }
            
            func tr0() {
                variety = "0"
                version = "$"
                origin = .init()
                uuidb = p
                
                wordb = p
                st4()
            }
            
            func case4() {
                switch *p {
                case 43:
                    return tr5()
                case 45:
                    return tr5()
                case 47:
                    return tr6()
                case 95:
                    return st6()
                case 126:
                    return st6()
                case _: break
                }
                if *p < 48 {
                    if 36 <= *p && *p <= 37 {
                        return tr5()
                    }
                } else if *p > 57 {
                    if *p > 90 {
                        if 97 <= *p && *p <= 122 {
                            return st6()
                        }
                    } else if *p >= 65 {
                        return st6()
                    }
                } else {
                    return st6()
                }
            }
            
            func tr5() {
                value = data.slice(from: wordb,
                                   till: p,
                                   root: root)
                version = *p
                st2()
            }
            
            func st2() {
                if ++p == pe {
                    _test_eof2()
                }
                else {
                    case2()
                }
            }
            
            func case2() {
                switch *p {
                case 95:
                    return tr3()
                case 126:
                    return tr3()
                case _: break
                }
                if *p < 65 {
                    if 48 <= *p && *p <= 57 { return tr3() }
                } else if *p > 90 {
                    if 97 <= *p && *p <= 122 { return tr3() }
                } else
                { return tr3() }
                st0()
            }
            
            func tr3() {
                wordb = p
                st5()
            }
            
            func st5() {
                if ++p == pe {
                    _test_eof5()
                }
                else {
                    case5()
                }
            }
            
            func case5() {
                switch *p {
                case 95:
                    return st5()
                case 126:
                    return st5()
                case _: break
                }
                if *p < 65 {
                    if 48 <= *p && *p <= 57 { return st5() }
                } else if *p > 90 {
                    if 97 <= *p && *p <= 122 { return st5() }
                } else
                { return st5() }
                st0()
            }
            
            func tr6() {
                variety = *(p - 1)
                st3()
            }
            
            func st3() {
                if ++p == pe {
                    _test_eof3()
                } else {
                    case3()
                }
            }
            
            func case3() {
                switch *p {
                case 95:
                    return tr4()
                case 126:
                    return tr4()
                case _: break
                }
                if *p < 65 {
                    if 48 <= *p && *p <= 57 { return tr4() }
                } else if *p > 90 {
                    if 97 <= *p && *p <= 122 { return tr4() }
                } else
                { return tr4() }
                st0()
            }
            
            func tr2() {
                variety = "0"
                version = "$"
                origin = .init()
                uuidb = p
                
                wordb = p
                st6()
            }
            
            func tr4() {
                wordb = p
                st6()
            }
            
            func st6() {
                if ++p == pe {
                    _test_eof6()
                } else {
                    case6()
                }
            }
            
            func case6() {
                switch *p {
                case 43:
                    return tr5()
                case 45:
                    return tr5()
                case 95:
                    return st6()
                case 126:
                    return st6()
                case _: break
                }
                if *p < 48 {
                    if 36 <= *p && *p <= 37 {
                        return tr5()
                    }
                } else if *p > 57 {
                    if *p > 90 {
                        if 97 <= *p && *p <= 122 {
                            return st6()
                        }
                    } else if *p >= 65 {
                        return st6()
                    }
                } else {
                    return st6()
                }
            }
            
            func _test_eof4() {
                cs = 4
                _test_eof()
            }
            func _test_eof2() {
                cs = 2
                _test_eof()
            }
            func _test_eof5() {
                cs = 5
                _test_eof()
            }
            func _test_eof3() {
                cs = 3
                _test_eof()
            }
            func _test_eof6() {
                cs = 6
                _test_eof()
            }
            
            func _test_eof() {
                if p == eof {
                    switch cs {
                    case 4, 6:
                        value = data.slice(from: wordb,
                                           till: p,
                                           root: root)
                    case 5:
                        origin = data.slice(from: wordb,
                                            till: p,
                                            root: root)
                    case _: break
                    }
                }
                
                _out()
            }
            
            func _out() {}
            
            func case1() {
                switch *p {
                case 95:
                    return tr2()
                case 126:
                    return tr2()
                case _: break
                }
                if *p < 65 {
                    if 48 <= *p && *p <= 57 {
                        return tr0()
                    }
                } else if *p > 70 {
                    if *p > 90 {
                        if 97 <= *p && *p <= 122 {
                            return tr2()
                        }
                    } else if *p >= 71 {
                        return tr2()
                    }
                } else {
                    return tr0()
                }
            }
            
            if p == pe {
                _test_eof()
            } else {
                switch cs {
                case 1:
                    case1()
                case 4:
                    case4()
                case 2:
                    case2()
                case 5:
                    case5()
                case 3:
                    case3()
                case 6:
                    case6()
                case _: break
                }
            }
            
            if cs != 0 && value.count <= Word.maxBase64Count &&
                origin.count <= Word.maxBase64Count {
                return Self(value: .init(flags: Word.abc[Int(variety)],
                                         data: value),
                            origin: .init(flags: Word.abc[Int(version)],
                                          data: origin))
            } else {
                return .fatal
            }
        }
    }
}

prefix operator *
private extension UnsafePointer {
    @inline(__always)
    static prefix func * (value: Self) -> Pointee {
        value.pointee
    }
    
    @inline(__always)
    static prefix func ++ (value: inout Self) -> Self {
        value += 1
        return value
    }
}

extension Range where Bound == UnsafePointer<UInt8> {
    @inline(__always)
    @usableFromInline
    func inIntRange<B>(root: Bound) -> Range<B> where B : BinaryInteger {
        B(lowerBound - root)..<B(upperBound - root)
    }
}

extension Ron.Slice {
    @inline(__always)
    @usableFromInline
    func slice(from: UnsafePointer<UInt8>,
               till: UnsafePointer<UInt8>,
               root: UnsafePointer<UInt8>) -> Self {
        Self(buf: buf,
             range: .init(from - root)..<(.init(till - root)))
    }
    
    @inline(__always)
    @usableFromInline
    func slice(range: Swift.Range<UnsafePointer<UInt8>>,
               root: UnsafePointer<UInt8>) -> Self {
        Self(buf: buf,
             range: .init(range.lowerBound - root)..<(.init(range.upperBound - root)))
    }
}
