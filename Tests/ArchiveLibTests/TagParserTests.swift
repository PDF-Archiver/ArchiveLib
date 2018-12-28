//
//  TagParserTests.swift
//  ArchiveLib
//
//  Created by Julian Kahnert on 28.12.18.
//

import ArchiveLib
import XCTest

class TagParserTests: XCTestCase {

    func testParsingValidDate() {

        // setup the raw string
        let longText = """
        Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua.
        At vero eos et accusam et justo duo dolores et ea rebum.
        Stet clita kasd gubergren, 20050201 no sea takimata sanctus est Lorem ipsum dolor sit amet.
        Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua.
        At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet.
        """
        let rawStringMapping: [String: Set<String>] = [
            longText: Set()
        ]

        for (raw, referenceTags) in rawStringMapping {

            // calculate
            let tags = TagParser.parse(raw)

            // assert
            XCTAssertEqual(tags, referenceTags)
        }
    }
}
