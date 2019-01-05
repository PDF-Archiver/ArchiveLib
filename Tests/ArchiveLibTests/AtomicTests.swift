//
//  AtomicTests.swift
//  ArchiveLib
//
//  Created by Julian Kahnert on 05.01.19.
//
// Some documentation about GCD: https://www.swiftbysundell.com/posts/a-deep-dive-into-grand-central-dispatch-in-swift

@testable import ArchiveLib
import Foundation
import XCTest

class AtomicTests: XCTestCase {

//    func testThreadUnsafe() {
//
//        var array = [Int]()
//
//        for _ in 1...10 {
//
//            // start calculations on a new thread
//            DispatchQueue.global().async {
//                for index in 1...100 {
//
//                    // This will crash the loop
//                    array.append(index)
//                }
//            }
//        }
//    }

    func testThreadSafe() {

        // create a dispatch group to keep track of all loops
        let group = DispatchGroup()

        // create an thread safe array
        let array = Atomic([Int]())

        for _ in 1...10 {

            // start calculations on a new thread
            group.enter()
            DispatchQueue.global().async {
                for index in 1...100 {
                    array.mutate { $0.append(index) }
                }

                // signal that calculations on this thread ended
                group.leave()
            }
        }

        // Wait until all calculations are completed (with a timeout of 10s).
        let result = group.wait(timeout: .now() + 10)

        // assert
        XCTAssertEqual(result, .success)
        XCTAssertEqual(array.value.reduce(into: 0, +=), 50500)
    }
}
