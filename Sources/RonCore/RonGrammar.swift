//
//  File.swift
//  
//
//  Created by Lau Chun Kai on 6/7/2021.
//

import Foundation

func resolve(ruleName: String, rules: inout [String : String]) -> String {
    let rule = rules[ruleName]!
    let pattern = rule.replacing(#"\$(\w+)"#) { match in
        let range = Range(match.range(at: 1),
                          in: rule)!
        let parser = resolve(ruleName: String(rule[range]),
                             rules: &rules)
        let pattern = parser
            .replacingOccurrences(of: #"\((?!\?:)"#,
                                  with: "(?:",
                                  options: .regularExpression)
            .replacingOccurrences(of: #"(\\\\)*\\\(\?:"#,
                                  with: #"$1\("#,
                                  options: .regularExpression)
        return pattern
    }
    
    if pattern == rule {
        return rule
    } else {
        rules[ruleName] = pattern
        return pattern
    }
}

extension String {
    func replacing(_ regExpStr: String, replacer: (NSTextCheckingResult) -> String) -> String {
        let regExp = try! NSRegularExpression(pattern: regExpStr)
        let matches = regExp.matches(in: self,
                                     range: .init(location: 0,
                                                  length: utf16.count))
        
        let replaces = matches.map { match in
            (Range(match.range, in: self)! , replacer(match))
        }.reversed()
        
        var this = self
        replaces.forEach {
            this.replaceSubrange($0, with: $1)
        }
        return this
    }
}

public let grammar: (base64: NSRegularExpression,
                     unicode: NSRegularExpression,
                     int: NSRegularExpression,
                     uuid: NSRegularExpression,
                     intAtom: NSRegularExpression,
                     uuidAtom: NSRegularExpression,
                     stringAtom: NSRegularExpression,
                     floatAtom: NSRegularExpression,
                     opTerm: NSRegularExpression,
                     frameTerm: NSRegularExpression,
                     atom: NSRegularExpression,
                     op: NSRegularExpression,
                     frame: NSRegularExpression)
    = {
        var _rules = [
            "BASE64": "[0-9A-Za-z_~]",
            "UNICODE": #"\\u[0-9a-fA-F]{4}"#,
            "INT": #"(SPECIAL)?($BASE64{0,10})"#,
            "UUID": "($INT)?([-+$%])?($INT)?",
            
            "INT_ATOM": #"[+-]?\d{1,17}"#,
            "UUID_ATOM": "[`]?$UUID",
            "STRING_ATOM": #"($UNICODE|\\[^\n\r]|[^'\\\n\r])*"#,
            "FLOAT_ATOM": #"[+-]?\d{0,19}\.\d{1,19}([Ee][+-]?\d{1,3})?"#,
            "OPTERM": "[!?,;]",
            "FRAMETERM": #"\s*[.]"#,
            
            "ATOM": #"=($INT_ATOM)|'($STRING_ATOM)'|\^($FLOAT_ATOM)|>($UUID)"#,
            "OP":  #"(?:\s*\*\s*($UUID_ATOM))?(?:\s*#\s*($UUID_ATOM))?(?:\s*@\s*($UUID_ATOM))?(?:\s*:\s*($UUID_ATOM))?\s*((?:\s*$ATOM)*)\s*($OPTERM)?"#,
            "FRAME": "($OP)+$FRAMETERM?",
        ]
        _ = resolve(ruleName: "FRAME", rules: &_rules)
        let rules = _rules.mapValues {
            try! NSRegularExpression(pattern: $0.replacingOccurrences(of: "SPECIAL",
                                                                      with: #"[\(\[{}\]\)]"#))
        }
        return (rules["BASE64"]!,
                rules["UNICODE"]!,
                rules["INT"]!,
                rules["UUID"]!,
                rules["INT_ATOM"]!,
                rules["UUID_ATOM"]!,
                rules["STRING_ATOM"]!,
                rules["FLOAT_ATOM"]!,
                rules["OPTERM"]!,
                rules["FRAMETERM"]!,
                rules["ATOM"]!,
                rules["OP"]!,
                rules["FRAME"]!)
    }()
