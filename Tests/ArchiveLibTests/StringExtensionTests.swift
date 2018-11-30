//
//  StringExtensionTests.swift
//  ArchiveLib
//
//  Created by Julian Kahnert on 30.11.18.
//

import ArchiveLib
import XCTest

class StringExtensionTests: XCTestCase {

    func testSlugify() {

        // setup
        let stringMapping = ["Ä": "Ae",
                             "Ö": "Oe",
                             "Ü": "Ue",
                             "ä": "ae",
                             "ö": "oe",
                             "ü": "ue",
                             "ß": "ss",
                             "é": "e",
                             "привет": "",
                             "Liebe Grüße aus Ovelgönne": "Liebe-Gruesse-aus-Ovelgoenne",
                             "Hello, ___ this !! is a TEst!?!": "Hello-this-is-a-TEst",
                             "Hello ---- again!!": "Hello-again"]

        for (raw, slugified) in stringMapping {

            // calculate
            let newSlugifiedString = raw.slugified()

            // assert
            XCTAssertEqual(newSlugifiedString, slugified)
        }
    }

    func testCapturedGroups() {

        // setup
        let testString = "2010-05-12--example-description__tag1_tag2_tag3"

        // calculate
        let groups = testString.capturedGroups(withRegex: "__([\\w\\d_]+)")

        // assert
        if let groups = groups {
            XCTAssertEqual(groups[0], "tag1_tag2_tag3")
        } else {
            XCTFail("No group found. This should not happen.")
        }
    }

    func testCapturedGroupsInvalid() {

        // setup
        let testString = "2010-05-12--example-description"

        // calculate
        // no groups in test string
        let groups1 = testString.capturedGroups(withRegex: "__([\\w\\d_]+)")
        // invalid regular expression
        let groups2 = testString.capturedGroups(withRegex: "([")

        // assert
        XCTAssertNil(groups1)
        XCTAssertNil(groups2)
    }

    func testCapitalizingFirstLetter() {

        // setup
        let testString = "test"

        // calculate
        let output = testString.capitalizingFirstLetter()

        // assert
        XCTAssertEqual(output, "Test")
    }

    func testCapitalizingFirstLetter2() {

        // setup
        let testString = "this is another test"

        // calculate
        let output = testString.capitalizingFirstLetter()

        // assert
        XCTAssertEqual(output, "This is another test")
    }
}
