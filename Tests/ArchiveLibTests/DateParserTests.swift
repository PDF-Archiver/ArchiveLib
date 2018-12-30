//
//  DateParser.swift
//  ArchiveLib
//
//  Created by Julian Kahnert on 30.11.18.
//

import ArchiveLib
import XCTest

class DateParserTests: XCTestCase {

    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }

    func testParsingValidDate() {

        // setup the raw string
        let hiddenDate = "20050201"
        let longText = """
        Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua.
        At vero eos et accusam et justo duo dolores et ea rebum.
        Stet clita kasd gubergren,\(hiddenDate)no sea takimata sanctus est Lorem ipsum dolor sit amet.
        Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua.
        At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet.
        """
        let rawStringMapping = ["n16072018n": dateFormatter.date(from: "2018-07-16"),
                                "Berlin16072018test": dateFormatter.date(from: "2018-07-16"),
                                "Berlin16072018": dateFormatter.date(from: "2018-07-16"),
                                "12.05.2015": dateFormatter.date(from: "2015-05-12"),
                                "12-05-2015": dateFormatter.date(from: "2015-05-12"),
                                "2015-05-12": dateFormatter.date(from: "2015-05-12"),
                                "1990_02_11": dateFormatter.date(from: "1990-02-11"),
                                "20050201": dateFormatter.date(from: "2005-02-01"),
                                "2010_05_12_15_17": dateFormatter.date(from: "2010-05-12"),
                                "09/10/2018": dateFormatter.date(from: "2018-10-09"),
                                "nn09/10/2018nn": dateFormatter.date(from: "2018-10-09"),
                                longText: dateFormatter.date(from: "2005-02-01")
        ]

        for (raw, date) in rawStringMapping {

            // calculate
            let parsedOutput = DateParser.parse(raw)

            // assert
            if let parsedOutput = parsedOutput {
                XCTAssertEqual(parsedOutput.date, date)
            } else {
                XCTFail("No date was found, this should not happen in this test.")
            }
        }
    }

    func testParsingambiguousDate() {

        // setup the raw string
        let rawStringMapping = ["20150203": dateFormatter.date(from: "2015-02-03"),
                                "02.03.2015": dateFormatter.date(from: "2015-03-02")]

        for (raw, date) in rawStringMapping {

            // calculate
            let parsedOutput = DateParser.parse(raw)

            // assert
            if let parsedOutput = parsedOutput {
                XCTAssertEqual(parsedOutput.date, date)
            } else {
                XCTFail("No date was found, this should not happen in this test.")
            }
        }
    }

    func testParsingInvalidDates() {

        // setup the raw string
        let rawStrings = ["12.05-2020",
                          "2015-35-12",
                          "199002_11",
                          "122005023212",
                          "20050232",
                          "Berlin16072018666"]

        for raw in rawStrings {

            // calculate
            let parsedOutput = DateParser.parse(raw)

            // assert
            XCTAssertNil(parsedOutput)
        }
    }

    func testPerformanceExample() {

        // setup the long string
        let hiddenDate = "20050201"
        let longText = """
        Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua.
        At vero eos et accusam et justo duo dolores et ea rebum.
        Stet clita kasd gubergren,\(hiddenDate)no sea takimata sanctus est Lorem ipsum dolor sit amet.
        Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua.
        At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet.
        """

        var parsedOutput: (date: Date, rawDate: String)?
        // measure the performance of the date parsing
        self.measure {
            parsedOutput = DateParser.parse(longText)
        }

        // assert
        if let parsedOutput = parsedOutput {
            XCTAssertEqual(parsedOutput.date, dateFormatter.date(from: "2005-02-01"))
        } else {
            XCTFail("No date was found, this should not happen in this test.")
        }
    }
}
