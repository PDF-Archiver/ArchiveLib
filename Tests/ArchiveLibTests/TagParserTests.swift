//
//  TagParserTests.swift
//  ArchiveLib
//
//  Created by Julian Kahnert on 28.12.18.
//

import ArchiveLib
import XCTest

class TagParserTests: XCTestCase {

    func testParsingValidTags() {

        // setup the raw string
        let longText = """
        Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua.
        At vero eos et accusam et justo duo dolores et ea rebum.
        Stet clita kasd gubergren, 20050201 no sea takimata sanctus est Lorem ipsum dolor sit amet.
        Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua.
        At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet.
        """
        let rawStringMapping: [String: Set<String>] = [
            longText: Set(["clita", "gubergren", "kasd", "stet"]),
            "This is a IKEA tradfri bulb!": Set(["ikea"]),
            "Bill of an Apple MacBook.": Set(["apple", "bill", "macbook"])
        ]

        for (raw, referenceTags) in rawStringMapping {

            // calculate
            let tags = TagParser.parse(raw)

            // assert
            if #available(iOS 12.0, OSX 10.14, *) {
                XCTAssertEqual(tags, referenceTags)
            } else {
                XCTAssertEqual(tags, Set())
            }
        }
    }

    func testParsingInvalidTags() {

        // setup the raw string
        let rawStringMapping: [String: Set<String>] = [
            "Die DKB ist eine Bank.": Set()
        ]

        for (raw, referenceTags) in rawStringMapping {

            // calculate
            let tags = TagParser.parse(raw)

            // assert
            XCTAssertEqual(tags, referenceTags)
        }
    }
}
