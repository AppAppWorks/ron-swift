import Foundation

public struct Batch {
    var frames: [Frame]
    var index = 0
}

public extension Batch {
    init(_ frames: [Frame]) {
        self.frames = frames
    }
    
    init(frames: Frame...) {
        self.frames = frames
    }
    
    init(_ strings: [String]) {
        frames = strings.map(Frame.init(str:))
    }
    
    init(strings: String...) {
        frames = strings.map(Frame.init(str:))
    }
    
    func toString() -> String {
        frames.map { $0.toString() }.joined(separator: "\n")
    }
    
    var long: Int {
        frames.reduce(0) { $0 + $1.body.count }
    }
    
    var hasFullState: Bool {
        frames.contains(where: \.isFullState)
    }
    
    static func splitById(source: String) -> Self {
        var b = Self(frames: [])
        var id = Uuid.zero
        var c = Frame()
        
        for op in Frame(str: source) {
            if op.uuid(.one) == id {
                c.append(op)
            } else {
                if id != .zero {
                    b.append(c)
                }
                id = op.uuid(.one)
                c = Frame()
                c.append(op)
            }
        }
        
        b.append(c)
        return b
    }
}

extension Batch : MutableCollection {
    public typealias Index = Int
    public typealias Element = Frame
    
    public func index(after i: Int) -> Int {
        i + 1
    }
    
    public subscript(position: Int) -> Frame {
        get { frames[position] }
        set { frames[position] = newValue }
    }
    
    public var startIndex: Int {
        frames.startIndex
    }
    
    public var endIndex: Int {
        frames.endIndex
    }
    
    public var count: Int {
        frames.count
    }
    
    public mutating func append(_ frame: Frame) {
        frames.append(frame)
    }
}


