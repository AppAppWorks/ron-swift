//
//  Log.swift
//  
//
//  Created by Lau Chun Kai on 3/8/2021.
//

import RonCore_xx

public extension Ron {
    enum OpLog {}
}

public extension Ron.OpLog {
    static func merge(output: inout Ron.TextFrame.Builder,
                      inputs: inout [Ron.TextFrame.Cursor]) -> Ron.Status {
        for i in inputs.indices {
            output.appendAll(from: &inputs[i])
        }
        return .ok
    }
    
    static func gc(output: inout Ron.TextFrame.Builder,
                   input: Ron.TextFrame) -> Ron.Status {
        .ok
    }
    
    static func mergeGc(output: inout Ron.TextFrame.Builder,
                        inputs: inout [Ron.TextFrame.Cursor]) -> Ron.Status {
        merge(output: &output,
              inputs: &inputs)
    }
}
