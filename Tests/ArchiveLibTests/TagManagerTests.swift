//
//  TagManagerTests.swift
//  ArchiveLib
//
//  Created by Julian Kahnert on 26.12.18.
//

@testable import ArchiveLib
import Foundation
import XCTest

class TagManagerTests: XCTestCase {

    let defaultDownloadStatus = DownloadStatus.local
    let defaaultSize = Int64(1024)
    var tagManager = TagManager()

    override func setUp() {
        super.setUp()

        // reset the document manager
        tagManager = TagManager()
    }

    func testTagAdd1() {

        // setup

        // calculate
        let tag1 = tagManager.add("tag1")
        let tag2 = tagManager.add("tag2", count: 2)

        // assert
        XCTAssertEqual(tag1.name, "tag1")
        XCTAssertEqual(tag1.count, 1)
        XCTAssertEqual(tag2.name, "tag2")
        XCTAssertEqual(tag2.count, 2)
    }

    func testTagAdd2() {

        // setup

        // calculate
        let tag1 = tagManager.add("tag1")
        XCTAssertEqual(tag1.name, "tag1")
        XCTAssertEqual(tag1.count, 1)

        // assert
        let tag2 = tagManager.add("tag1")
        XCTAssertEqual(tag2.name, "tag1")
        XCTAssertEqual(tag2.count, 2)
    }

    func testTagRemove() {

        // setup
        _ = tagManager.add("tag1")
        _ = tagManager.add("tag2", count: 2)
        _ = tagManager.add("tag3", count: 3)

        // calculate
        tagManager.remove("tag1")
        tagManager.remove("tag3")
        let tag1 = tagManager.filterBy("tag1").first
        let tag3 = tagManager.filterBy("tag3").first

        // assert
        XCTAssertEqual(tagManager.availableTags.count, 2)
        XCTAssertNil(tag1)
        XCTAssertNotNil(tag3)
    }

    func testGetAvailableTags() {

        // setup
        _ = tagManager.add("tag1")
        _ = tagManager.add("tag2", count: 2)
        _ = tagManager.add("tag3", count: 3)

        // calculate
        let tags1 = tagManager.getAvailableTags(with: ["tag0"])
        let tags2 = tagManager.getAvailableTags(with: ["tag2"])
        let tags3 = tagManager.getAvailableTags(with: ["tag"])
        let tags4 = tagManager.getAvailableTags(with: [])

        // assert
        XCTAssertEqual(tagManager.availableTags.count, 3)
        XCTAssertEqual(tags1, [])
        XCTAssertEqual(tags2.count, 1)
        XCTAssertEqual(tags3.count, 3)
        XCTAssertEqual(tags4.count, 3)
    }
}
