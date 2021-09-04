//
//  Encdec.swift
//  
//
//  Created by Lau Chun Kai on 26/7/2021.
//

import Foundation

public extension Ron {
    
}

extension Ron.Result {
    init(utf8Codepoint into: Ron.Codepoint,
         from: String) {
        fatalError()
    }
}

extension Ron.Codepoint {
    @inlinable
    var utf8Esc: String {
        guard self < 128 else {
            return .init(UnicodeScalar(self)!)
        }
        
        switch UInt8(self) {
        case "\"":
            return #"\""#
        case "'":
            return #"\'"#
        case #"\"#:
            return #"\\"#
        case "\u{08}":
            return #"\b"#
        case "\u{c}":
            return #"\f"#
        case "\n":
            return #"\n"#
        case "\r":
            return #"\r"#
        case "\t":
            return #"\t"#
        case _:
            return .init(UnicodeScalar(self)!)
        }
    }
}

extension RandomAccessCollection where Element == UInt8, Index == Int {
    @inlinable
    @inline(__always)
    func encode<UTF8S>(bitWidth: UInt8,
                       hashCount: Int,
                       coding: UTF8S,
                       bitSize: Int) -> String
    where UTF8S : RandomAccessCollection,
          UTF8S.Element == UInt8,
          UTF8S.Index == Int {
        var bitSize = bitSize
        var bits: UInt32 = 0
        var bc: UInt32 = 0
        let mask: UInt32 = (1 << bitWidth) - 1
        var raw = 0
        var coded = [UInt8]()
        coded.reserveCapacity(hashCount)

        while bitSize >= 8 {
            bits <<= 8
            bc += 8
            bits |= .init(self[raw])
            raw += 1
            bitSize -= 8
            while bc >= bitWidth {
                bc -= .init(bitWidth)
                coded.append(coding[.init((bits >> bc) & mask)] )
            }
        }
        if bc > 0 {
            bits <<= bitWidth - .init(bc)
            coded.append(coding[.init(bits & mask)])
        }
        
        return String(bytes: coded,
                      encoding: .utf8)!
    }
    
    @inlinable
    @inline(__always)
    func decode<UTF8S>(bitWidth: Int,
                       table: UTF8S,
                       bitSize: UInt32) -> (Data, Bool)
    where UTF8S : RandomAccessCollection,
          UTF8S.Element == UInt8?,
          UTF8S.Index == Int {
        var bits: UInt32 = 0
        var bc: UInt32 = 0
        var raw = [UInt8]()
        var coded = 0
        var bitSize = bitSize
        
        while bitSize >= bitWidth {
            bits <<= bitWidth
            bc += .init(bitWidth)
            guard let value = table[.init(self[coded])] else {
                return (Data(raw),
                        false)
            }
            coded += 1
            bitSize -= .init(bitWidth)
            bits |= .init(value)
            while bc >= 8 {
                bc -= 8
                raw.append(.init((bits >> bc) & 0xff))
            }
        }
        if bc > 0 {
            raw.append(.init((bits << (8 - bc)) & 0xff))
        }
        return (Data(raw),
                true)
    }
}

//template <int bit_width, const int8_t table[256]>
//bool decode(String& raw, Slice coded, uint32_t bit_size) {
//    uint32_t bits = 0;
//    uint32_t bc = 0;
//    while (bit_size >= bit_width) {
//        bits <<= bit_width;
//        bc += bit_width;
//        int8_t value = table[*coded];
//        if (value < 0) return false;
//        ++coded;
//        bit_size -= bit_width;
//        bits |= value;
//        while (bc >= 8) {
//            bc -= 8;
//            raw.push_back(uint8_t((bits >> bc) & 0xff));
//        }
//    }
//    if (bc > 0) {
//        raw.push_back(uint8_t((bits << (8 - bc)) & 0xff));
//    }
//    return true;
//}
//
///**
//                                UTF-8 / UTF-16
//
//One may wonder, why do we take the labor of implementing UTF-8/UTF-16
//conversions? First of all, the C++ UTF support is a story of pain and misery
//   https://stackoverflow.com/questions/42946335/deprecated-header-codecvt-replacement
//Second, RON has the requirement of bitwise identical results, so this kind of
// control is a plus. In particular, RON has every reason to aggressively enforce
// canonized UTF-8 encoding (e.g. prevent two-byte codepoints from taking three
//bytes). Third, RON(text) has to decode escapes as well as UTF. Just to prevent
//double pass and double allocation, the custom code is preferred. UTF8<->UTF16
//recoding is known to be a major performance sink. Again, RON's raison d'être is
//replica convergence. We intend to transfer, merge and recode data while the
//hashes must stays the same. There is no other choice than to have a very formal
//model and to exercise bit-level control. For the perspective on the multitude of
//potential issues, please read: http://seriot.ch/parsing_json.php Given all of
//the above, paranoid control is a must! Finally, UTF-8/UTF-16 *encoding* is not
//that much of code. We don't care how letters look typographically; we only care
//about the bits.
//*/
//
//inline void utf8append(String& to, Codepoint cp) {
//    if (cp < 128) {
//        to.push_back(static_cast<Char>(cp));
//    } else if (cp < 2048) {
//        to.push_back((cp >> 6) | (128 + 64));
//        to.push_back((cp & 63) | 128);
//    } else if (cp < 65536) {
//        to.push_back((cp >> 12) | (128 + 64 + 32));
//        to.push_back(((cp >> 6) & 63) | 128);
//        to.push_back((cp & 63) | 128);
//    } else {
//        to.push_back(((cp >> 18) & 7) | (128 + 64 + 32 + 16));
//        to.push_back(((cp >> 12) & 63) | 128);
//        to.push_back(((cp >> 6) & 63) | 128);
//        to.push_back((cp & 63) | 128);
//    }
//}
//
//inline void utf8esc_append(String& to, Codepoint cp) {
//    if (cp < 128) {
//        Char i = static_cast<Char>(cp);
//        constexpr Char ESC = '\\';
//        switch (i) {
//            case '\"':
//                to.push_back(ESC);
//                to.push_back('"');
//                break;
//            case '\'':
//                to.push_back(ESC);
//                to.push_back('\'');
//                break;
//            case '\\':
//                to.push_back(ESC);
//                to.push_back('\\');
//                break;
//            case '\b':
//                to.push_back(ESC);
//                to.push_back('b');
//                break;
//            case '\f':
//                to.push_back(ESC);
//                to.push_back('f');
//                break;
//            case '\n':
//                to.push_back(ESC);
//                to.push_back('n');
//                break;
//            case '\r':
//                to.push_back(ESC);
//                to.push_back('r');
//                break;
//            case '\t':
//                to.push_back(ESC);
//                to.push_back('t');
//                break;
//            default:
//                to.push_back(i);
//                break;
//        }
//    } else if (cp < 2048) {
//        to.push_back((cp >> 6) | (128 + 64));
//        to.push_back((cp & 63) | 128);
//    } else if (cp < 65536) {
//        to.push_back((cp >> 12) | (128 + 64 + 32));
//        to.push_back(((cp >> 6) & 63) | 128);
//        to.push_back((cp & 63) | 128);
//    } else {
//        to.push_back(((cp >> 18) & 7) | (128 + 64 + 32 + 16));
//        to.push_back(((cp >> 12) & 63) | 128);
//        to.push_back(((cp >> 6) & 63) | 128);
//        to.push_back((cp & 63) | 128);
//    }
//}
//
//inline void utf16append(std::u16string& to, Codepoint cp) {
//    if (cp < 0xd7ff || (cp < 0x10000 && cp >= 0xe000)) {
//        to.push_back(static_cast<char16_t>(cp));
//    } else {
//        to.push_back(static_cast<char16_t>(0xd800 + (cp >> 10)));
//        to.push_back(static_cast<char16_t>(0xdc00 + (cp & 1023)));
//    }
//}
//
//inline Codepoint utf8read(String::const_iterator& at,
//                          String::const_iterator end) {  // TODO known-size
//    uint8_t head = *at;
//    ++at;
//    if (head < 128) {  // latin fast path
//        return head;
//    }
//    Codepoint ret{0};
//    int sz;
//    if (head <= 0xdf) {
//        sz = 2;
//        ret = head & 0x1f;
//    } else if (head <= 0xef) {
//        sz = 3;
//        ret = head & 0xf;
//    } else if (head <= 0xf7) {
//        sz = 4;
//        ret = head & 0x7;
//    } else {
//        return CP_ERROR;
//    }
//    if (end - at < sz - 1) {  // has bytes?
//        while (at < end) {
//            ++at;
//        }
//        return CP_ERROR;
//    }
//    switch (sz) {
//        case 4:
//            ret <<= 6;
//            ret |= *at & 0x3f;
//            ++at;
//        case 3:
//            ret <<= 6;
//            ret |= *at & 0x3f;
//            ++at;
//        case 2:
//            ret <<= 6;
//            ret |= *at & 0x3f;
//            ++at;
//    }
//    return ret;
//}
//
//inline Codepoint utf16read(std::u16string::const_iterator& at,
//                           std::u16string::const_iterator end,
//                           bool check = true) {
//    Codepoint ret = *at;
//    ++at;
//    if (ret < 0xd800) {
//        return ret;
//    }
//    if (ret >= 0xe000) {
//        return ret;
//    }
//    ret -= 0xd800;
//    uint16_t next = *at;
//    ret <<= 10;
//    ret |= next - 0xdc00;
//    ++at;
//    return ret;
//}
//
//void utf8utf16(std::u16string& to, const String& from);
