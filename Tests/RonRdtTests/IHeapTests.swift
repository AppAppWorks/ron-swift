//
//  File.swift
//  
//
//  Created by Lau Chun Kai on 8/7/2021.
//

import XCTest
@testable import RonRdt
import RonCore

final class IHeapTests : XCTestCase {
    func testInsertFrame() {
        let frameA = "*lww#test@time1-orig:number=1@(2:string'2'"
        let frameB = "*lww#test@time3-orig:number=3@(4:string'4'"
        let frameC = "*lww#test@time1-orig:number=1@(2:string'2'@(3:number=3@(4:string'4'"
        
        var heap = IHeap(primary: eventComparator)
        
        heap.insert(Frame(str: frameA))
        heap.insert(Frame(str: frameB))
        
        XCTAssertEqual(heap.frame().toString(), frameC)
    }
    
    func testOp() {
        let frames = Batch(
            frames: Frame(str: "*lww#test@time1-orig:number=1@(2:string'2'"),
            Frame(str: "*lww#test@time3-orig:number=3@(4:string'4'"),
            Frame(str: "*lww#test@time2-orig:number=2@(2:string'2'@(3:number=3@(4:string'4'")
        )
        
        var heap = IHeap(primary: refComparator)
        heap.insert(frames)
        // $FlowFixMe
        let loc = heap.current?.uuid(.three)
        var count = 0
        
        while (
            heap
                .current?
                .uuid(.three)
                == loc
        ) {
            count += 1
            _ = heap.next()
        }
        XCTAssertEqual(count, 3)
    }
    
    func testMerge() {
        let frameA = "*rga#test@1:0'A'@2'B'" //  D E A C B
        let frameB = "*rga#test@1:0'A'@3'C'"
        let frameC = "*rga#test@4:0'D'@5'E'"
        let frameR = "*rga#test@4'D'@5'E'@1'A'@3'C'@2'B'"
        var heap = IHeap(primary: eventComparatorDesc,
                         secondary: refComparator)
        heap.insert(Frame(str: frameA))
        heap.insert(Frame(str: frameB))
        heap.insert(Frame(str: frameC))
        var res = Frame()
        while !heap.eof {
            let op = heap.current ?? .zero
            res.append(op)
            _ = heap.nextPrim()
        }
        XCTAssertEqual(res.toString(), frameR)
    }
}
