//
//  LoggingTests.swift
//  ArchiveLib
//
//  Created by Julian Kahnert on 26.12.18.
//

import ArchiveLib
import XCTest

class TestLogging: Logging {
}

class LoggingTests: XCTestCase {

    func testLogging() {

        // setup
        let logObject = TestLogging()

        // calculate

        // assert
        XCTAssertNotNil(logObject.log)
    }
}
