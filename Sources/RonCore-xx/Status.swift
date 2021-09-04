public extension Ron {
    /** Error codes are RON UUIDs - to serialize them as ops, store, send.
     *  For example, `@error :1gOFEM+gritzko CAUSEBREAK;`
     *  The OK status is 0 (aka "nil UUID"). */
    struct Status {
        public var code: Ron.UUID
        public var comment: String
        
        @usableFromInline
        init(code: Ron.UUID,
             comment: String = "") {
            self.code = code
            self.comment = comment
        }
    }
}

public extension Ron.Status {
    @inlinable
    init() {
        self.init(code: .init(value: 0,
                              origin: 0))
    }
    
    @inlinable
    init(errCode: UInt64) {
        self.init(code: .init(value: errCode,
                              origin: Ron.Word.payloadBits))
    }
    
    @inlinable
    func commenting(_ comment: String) -> Self {
        .init(code: code,
              comment: comment)
    }
    
    @inlinable
    func callAsFunction() -> Bool {
        code.origin.u64 != Ron.Word.payloadBits
    }
    
    @inlinable
    func callAsFunction() -> Ron.UUID {
        code
    }
    
    var str: String {
        "\(code.value.str)\t\(comment)"
    }
    
    static let ok = Self()
    static let endOfFrame = Self(errCode: 258734343834084750)
    static let endOfInput = Self(errCode: 258734343883429789)
    static let notImplemented = Self(errCode: 421215369505919885)
    static let notFound = Self(errCode: 428933766657507328)
    static let badState = Self(errCode: 201032812431266688)
    static let badArgs = Self(errCode: 201031024437624832)
    static let badSyntax = Self(errCode: 201032269022144576)
    static let dbFail = Self(errCode: 237442776878546944)
    static let ioFail = Self(errCode: 331081250183839744)
    static let badFrame = Self(errCode: 201031367932829696)
    static let badId = Self(errCode: 201031558885277696)
    static let badRef = Self(errCode: 201032178685968384)
    static let badValue = Self(errCode: 201032449377492992)

    static let noType = Self(errCode: 421216472048599040)
    static let notOpen = Self(errCode: 421215784859860992)

    static let chainBreak = Self(errCode: 221003099021304468)
    static let hashBreak = Self(errCode: 309183850229572864)
    static let treeBreak = Self(errCode: 530079928137852160)
    static let causeBreak = Self(errCode: 219121412645642900)

    static let `repeat` = Self(errCode: 490440333889372160)
    static let reorder = Self(errCode: 490436832172703744)
    static let conflict = Self(errCode: 223030390270578688)

    static let treeGap = Self(errCode: 530079933224189952)
    static let yarnGap = Self(errCode: 615424644247453696)

}

extension Ron.Status : Equatable {
    @inline(__always)
    public static func == (lhs: Self,
                           rhs: Self) -> Bool {
        lhs.code == rhs.code
    }
}
