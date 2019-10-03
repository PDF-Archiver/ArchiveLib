//
//  SearchTests.swift
//  ArchiveLibTests
//
//  Created by Julian Kahnert on 14.11.18.
//

import ArchiveLib
import XCTest

class TestElement: Searchable {
    var searchTerm: String

    init(filename: String) {
        self.searchTerm = filename
    }

    static func == (lhs: TestElement, rhs: TestElement) -> Bool {
        return lhs.searchTerm == rhs.searchTerm
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(searchTerm)
    }
}

class TestSearcher: Searcher {
    typealias Element = TestElement

    var allSearchElements: Set<TestElement> = []
}

class SearchTests: XCTestCase {

    func testSearch1() {

        // prepare
        let element1 = TestElement(filename: "2018 05 12 kitchen table bill ikea")
        let element2 = TestElement(filename: "2018 01 07 tom tailor shirt bill")

        let index = TestSearcher()
        index.allSearchElements.insert(element1)
        index.allSearchElements.insert(element2)

        // act
        let foundElements = index.filter(by: "bill")

        // assert
        XCTAssertTrue(foundElements.contains(element1))
        XCTAssertTrue(foundElements.contains(element2))
    }

    func testSearch2() {

        // prepare
        let element1 = TestElement(filename: "2018 05 12 kitchen table bill ikea")
        let element2 = TestElement(filename: "2018 01 07 tom tailor shirt bill")

        let index = TestSearcher()
        index.allSearchElements.insert(element1)
        index.allSearchElements.insert(element2)

        // act
        let foundElements = index.filter(by: ["shirt", "bill"])

        // assert
        XCTAssertFalse(foundElements.contains(element1))
        XCTAssertTrue(foundElements.contains(element2))
    }

    func testFilterPerformance1() {

        // create the search base
        let index = TestSearcher()
        for idx in stride(from: 0, to: 100, by: 1) {
            index.allSearchElements.insert(TestElement(filename: "2018 05 12 document\(idx) description tag\(idx) tag\(idx * 11)"))
        }

        // performance test with a lot results
        var filteredElements = Set<TestElement>()
        self.measure {
            // Put the code you want to measure the time of here.
            filteredElements = index.filter(by: "description")
        }
        XCTAssertEqual(filteredElements.capacity, 192)
    }

    func testFilterPerformance2() {

        // create the search base
        let index = TestSearcher()
        for idx in stride(from: 0, to: 100, by: 1) {
            index.allSearchElements.insert(TestElement(filename: "2018 05 12 document\(idx) description tag\(idx) tag\(idx * 11)"))
        }

        // performance test with only a few results
        var filteredElements = Set<TestElement>()
        self.measure {
            // Put the code you want to measure the time of here.
            filteredElements = index.filter(by: "tag11")
        }
        XCTAssertEqual(filteredElements.capacity, 3)
    }
}
