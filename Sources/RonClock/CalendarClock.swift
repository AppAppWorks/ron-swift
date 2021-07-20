//
//  File.swift
//  
//
//  Created by Lau Chun Kai on 15/7/2021.
//
import Foundation
import RonCore

public struct CalendarClock : Clock {
    typealias Pair = (high: Int, low: Int)
    
    public internal(set) var origin: String
    public internal(set) var last: Uuid
    var lastPair = (high: -1, low: -1)
    var lastBase = "0"
    var offset: Event
    var minCount: Int
    
    public init(origin: String,
                last: ClockLast? = nil,
                offset: Event? = nil,
                count: Int? = nil) {
        self.offset = offset ?? 0
        self.origin = origin
        self.last = (last?.uuid).map {
            Uuid(
                value: $0.value,
                origin: origin,
                sep: "+"
            )
        } ?? .zero
        minCount = count ?? 6
    }
}

public extension CalendarClock {
    typealias Event = TimeInterval
    
    mutating func time() throws -> Uuid {
        var pair = Date().addingTimeInterval(offset).pair
        var next = try! String(pair: pair)
        
        if (
            pair.high <= lastPair.high ||
                (pair.high == lastPair.high && pair.low <= lastPair.low)
        ) {
            pair = further(
                pair: pair,
                prev: lastPair
            )
            next = try! String(pair: pair)
        } else if minCount < 8 {
            next = String(
                relaxNext: next,
                prev: lastBase,
                minCount: minCount
            )
        }
        
        lastBase = next
        lastPair = pair
        last = .init(
            value: lastBase,
            origin: origin,
            sep: "+"
        )
        return last
    }
    
    mutating func see(uuid: Uuid) throws -> Bool {
        if isSane(event: uuid) && last < uuid {
            last = uuid
            lastBase = uuid.value
            lastPair = try lastBase.asPair()
            return true
        }
        return false
    }
    
    mutating func adjust(_ event: Event) throws -> Event {
        offset = event - Date().timeIntervalSince1970
        let d = Date(timeIntervalSince1970: event)
        lastPair = d.pair
        lastBase = try String(pair: lastPair)
        last = Uuid(
            value: lastBase,
            origin: origin,
            sep: "+"
        )
        
        return offset
    }
    
    mutating func adjust(_ event: Uuid) throws -> Event {
        let value = event.value
        offset = try Date(calendarBase: value)
            .timeIntervalSince(Date())
        last = .init(
            value: value,
            origin: origin,
            sep: "+"
        )
        lastPair = try value.asPair()
        lastBase = value
        
        return offset
    }
    
    func isSane(event: Uuid) -> Bool {
        !event.value.isEmpty && event.value < "~"
    }
}

extension Date {
    var pair: CalendarClock.Pair {
        var c = Calendar.current
        c.timeZone = TimeZone(abbreviation: "GMT")!
        let components = c.dateComponents(
            [.year, .month, .day, .hour, .minute, .second, .nanosecond,],
            from: self
        )
        
        var high = (components.year! - 2010) * 12 + components.month! - 1
        high <<= 6
        high |= components.day! - 1
        high <<= 6
        high |= components.hour!
        high <<= 6
        high |= components.minute!
        
        var low = components.second!
        low <<= 12
        low |= (components.nanosecond! / 100_000)
        low <<= 12
        
        return (high, low)
    }
    
    init(pair: CalendarClock.Pair) {
        var (high, low) = pair
        low >>= 12
        let msec = low & 4095
        low >>= 12
        let second = low & 63
        let minute = high & 63
        high >>= 6
        let hour = high & 63
        high >>= 6
        let day = (high & 63) + 1
        high >>= 6
        let months = high & 4095
        let month = months % 12
        let year = 2010 + (((months - month) / 12) | 0)
        
        let components = DateComponents(
            calendar: .current,
            timeZone: TimeZone(abbreviation: "GMT")!,
            year: year,
            month: month + 1,
            day: day,
            hour: hour,
            minute: minute,
            second: second,
            nanosecond: msec * 100_000
        )

        self = components.date!
    }
    
    init(calendarBase: String) throws {
        try self.init(pair: calendarBase.asPair())
    }
}

enum Base64x32Error<B> : Error where B : BinaryInteger {
    case outOfRange(B)
    case moreThan30Bits
    case invalidChar
    case nonBased64Char
}

extension String {
    func asPair() throws -> CalendarClock.Pair {
        let high = try Int(base64x32: String(prefix(5)))
        let low = count <= 5 ? 0 : try Int(base64x32: String(dropFirst(5).prefix(5)))
        return (high, low)
    }
    
    init(pair: CalendarClock.Pair) throws {
        var ret = try pair.high.base64x32(pad: pair.low != 0)
        if pair.low == 0 {
            if ret.isEmpty {
                ret = "0"
            }
        } else {
            ret += try pair.low.base64x32(pad: false)
        }
        self = ret
    }
    
    var fullString: String {
        self + String(repeating: "0", count: max(count, 10))
    }
    
    init(relaxNext next: String,
         prev: String,
         minCount: Int = 1) {
        let reper = prev.fullString
        let mine = next.fullString
        var p = zip(mine, reper).prefix(10).prefix(while: ==).count + 1
        p = Swift.max(p, minCount)
        self = String(mine.prefix(p))
    }
}

postfix operator ++
prefix operator ++

extension BinaryInteger {
    static prefix func ++ (self: inout Self) -> Self {
        self += 1
        return self
    }
    
    static postfix func ++ (self: inout Self) -> Self {
        defer {
            self += 1
        }
        return self
    }
    
    init(base64x32 base: String) throws {
        guard base.count <= 5 else {
            throw Base64x32Error<Self>.moreThan30Bits
        }
        var ret: Self = 0
        var i = 0
        let baseCodes = base.utf8CString
        
        while i < base.count {
            ret <<= 6
            let code = baseCodes[i]
//            guard code < 128 else {
//                throw Base64x32Error<Self>.invalidChar
//            }
            let de = Uuid.codes[Int(code)]
            guard de != -1 else {
                throw Base64x32Error<Self>.nonBased64Char
            }
            ret |= Self(de)
            i += 1
        }
        while i++ < 5 {
            ret <<= 6
        }
        self = ret
    }
    
    func base64x32(pad: Bool) throws -> String {
        guard (0..<1 << 30).contains(self) else {
            throw Base64x32Error.outOfRange(self)
        }
        
        var ret = ""
        var pos = 0
        var value = self
        
        while !pad && (value & 63) == 0 && pos++ < 5 {
            value >>= 6
        }
        
        while pos++ < 5 {
            ret += String(
                Unicode.Scalar(
                    UInt8(
                        Uuid.base64[Int(value & 63)]
                    )
                )
            )
            value >>= 6
        }
        
        return String(ret.reversed())
    }
}

func further(pair: CalendarClock.Pair,
             prev: CalendarClock.Pair) -> CalendarClock.Pair {
    if pair.low < Int32.max {
        return (high: max(pair.high, prev.high),
                low: max(pair.low, prev.low) + 1)
    } else {
        return (high: max(pair.high, prev.high) + 1,
                low: 0)
    }
}

