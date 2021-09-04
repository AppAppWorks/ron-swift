//
//  Form.swift
//
//
//  Created by Lau Chun Kai on 29/7/2021.
//

public extension Ron {
    /** these indices get saved to the db the list is append-only, see forms.txt */
    enum Form : UInt8 {
        case zeroRaw = 0
        case yarnRaw = 1
        case logRaw = 2
        case tailRaw = 3
        case patchRaw = 4
        case spanRaw = 5
        case chainRaw = 6
        case graphRaw = 7
        case metaMeta = 8
        case prevMeta = 9
        case objMeta = 10
        case sha3Meta = 11
        case vvMeta = 12
        case lwwRdt = 13
        case rgaRdt = 14
        case mxRdt = 15
        case maxRdt = 19
        case jsonMap = 16
        case csvMap = 17
        case txtMap = 18
        case reservedAny = 200
        case errorNo = 255
        
        /** By the definition, a name UUID must be pre-defined (transcendent).
         *  Hence, this header forward-defines all name UUIDs corresponding
         *  to data forms (mappers, RDTs, any other op groupings that cod be
         *  sent over the wire).
         *  Those name UUIDs get mapped to an internal 8-bit id. First, to
         *  use switch(){} everywhere we cod. Second, to fit the @id:form
         *  pair into 16-byte keys (8 bits of UUID are guessable in this case).
         *  swarmdb key-value records are very fine-grained, so this helps. */
        @usableFromInline
        static let ids = [
            1128674180837933056 as UInt64,  // zero
            1109533813702131712,  // yarn
            879235468267356160,   // log
            1019422101297168384,  // tail
            947412314540212224,   // patch
            1005594780505210880,  // span
            715112314629521408,   // chain
            789985133028442112,   // graph
            894494834235015168,   // meta
            952132676872044544,   // prev
            929632683238096896,   // obj
            1003339750876119040,  // sha3
            1061160662199173120,  // vv
            881557636825219072,   // lww
            985043671231496192,   // rga
            899594025567256576,   // mx
            844371191501160448,   // json
            718297752286527488,   // csv
            1025941105738252288,  // txt
            893383983893577728,   // max
        ].createBufferPointer()!
    }
}

public extension Ron.Form {
    @inlinable
    var id: UInt64 {
        Self.ids[.init(rawValue)]
    }
    
    @inlinable
    init(uuid: Ron.UUID) {
        self = Ron.UUID.uuidToForm[uuid] ?? .zeroRaw
    }
}

public extension Ron.UUID {
    static let zeroForm = Self(value: Ron.Form.zeroRaw.id,
                               origin: 0)    // NOLINT
    static let yarnForm = Self(value: Ron.Form.yarnRaw.id,
                               origin: 0)    // NOLINT
    static let logForm = Self(value: Ron.Form.logRaw.id,
                              origin: 0)      // NOLINT
    static let tailForm = Self(value: Ron.Form.tailRaw.id,
                               origin: 0)    // NOLINT
    static let patchForm = Self(value: Ron.Form.patchRaw.id,
                                origin: 0)  // NOLINT
    static let spanForm = Self(value: Ron.Form.spanRaw.id,
                               origin: 0)    // NOLINT
    static let chainForm = Self(value: Ron.Form.chainRaw.id,
                                origin: 0)  // NOLINT
    static let graphForm = Self(value: Ron.Form.graphRaw.id,
                                origin: 0)  // NOLINT
    static let metaForm = Self(value: Ron.Form.metaMeta.id,
                               origin: 0)   // NOLINT
    static let prevForm = Self(value: Ron.Form.prevMeta.id,
                               origin: 0)   // NOLINT
    static let objForm = Self(value: Ron.Form.objMeta.id,
                              origin: 0)     // NOLINT
    static let sha3Form = Self(value: Ron.Form.sha3Meta.id,
                               origin: 0)   // NOLINT
    static let vvForm = Self(value: Ron.Form.vvMeta.id,
                             origin: 0)       // NOLINT
    static let lwwForm = Self(value: Ron.Form.lwwRdt.id,
                              origin: 0)      // NOLINT
    static let rgaForm = Self(value: Ron.Form.rgaRdt.id,
                              origin: 0)      // NOLINT
    static let mxForm = Self(value: Ron.Form.mxRdt.id,
                             origin: 0)        // NOLINT
    static let maxForm = Self(value: Ron.Form.maxRdt.id,
                              origin: 0)      // NOLINT
    static let jsonForm = Self(value: Ron.Form.jsonMap.id,
                               origin: 0)    // NOLINT
    static let csvForm = Self(value: Ron.Form.csvMap.id,
                              origin: 0)      // NOLINT
    static let txtForm = Self(value: Ron.Form.txtMap.id,
                              origin: 0)      // NOLINT
    
    static let uuidToForm: [Ron.UUID : Ron.Form] = [
        .zeroForm: .zeroRaw,   .yarnForm: .yarnRaw,
        .logForm: .logRaw,     .tailForm: .tailRaw,
        .patchForm: .patchRaw, .spanForm: .spanRaw,
        .chainForm: .chainRaw, .graphForm: .graphRaw,
        .metaForm: .metaMeta,  .prevForm: .prevMeta,
        .objForm: .objMeta,    .sha3Form: .sha3Meta,
        .vvForm: .vvMeta,      .lwwForm: .lwwRdt,
        .rgaForm: .rgaRdt,     .mxForm: .mxRdt,
        .maxForm: .maxRdt,     .jsonForm: .jsonMap,
        .csvForm: .csvMap,     .txtForm: .txtMap,
        .fatal: .errorNo,
    ]
}

public extension Ron.UUID {
    @inlinable
    init(form: Ron.Form) {
        self.init(value: form.id,
                  origin: 0)
    }
}
