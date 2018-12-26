//
//  TagTests.swift
//  ArchiveLib-iOS Tests
//
//  Created by Julian Kahnert on 29.11.18.
//

@testable import ArchiveLib
import XCTest

class TagSearcher: Searcher {
    typealias Element = Tag

    var allSearchElements: Set<Tag> = []
}

class TagTests: XCTestCase {

    func testInit() {

        // define constants values
        let tagName = "tag1"
        let tagCount = 10

        // create a tag
        let newTag = Tag(name: tagName, count: tagCount)

        // assert
        XCTAssertEqual(newTag.name, tagName)
        XCTAssertEqual(newTag.count, tagCount)
    }

    func testHashable() {

        // define constants values
        let tagName = "tag1"
        let tagCount1 = 11
        let tagCount2 = 22

        // create some tags
        let newTag1 = Tag(name: tagName, count: tagCount1)
        let newTag2 = Tag(name: tagName, count: tagCount2)

        // force a hashMap collision
        var hashMap: [Tag: String] = [newTag1: "tag1"]
        hashMap.updateValue("tag2", forKey: newTag2)

        // assert
        XCTAssertEqual(newTag1, newTag2)
        XCTAssertEqual(newTag1.name.hashValue, newTag1.hashValue)
        XCTAssertEqual(hashMap.count, 1)
    }

    func testCustomStringConvertible() {

        // define constants values
        let tagName = "tag1"
        let tagCount = 11

        // create a tag
        let newTag = Tag(name: tagName, count: tagCount)

        // assert
        XCTAssertEqual(newTag.description, "\(tagName) (\(tagCount))")
    }

    func testComparable() {

        // create tags
        let tag1 = Tag(name: "tag1", count: 2)
        let tag2 = Tag(name: "tag2", count: 1)

        // assert
        XCTAssertLessThan(tag1, tag2)
    }

    func testTagSearch() {

        // create some tags
        let tag1 = Tag(name: "tag1", count: 1)
        let tag2 = Tag(name: "tag2", count: 2)
        let tag3 = Tag(name: "tag3", count: 3)

        // calculate
        let tagSearcher = TagSearcher()
        tagSearcher.allSearchElements.insert(tag1)
        tagSearcher.allSearchElements.insert(tag2)
        tagSearcher.allSearchElements.insert(tag3)

        let filteredTags = tagSearcher.filterBy("tag1")

        // assert
        XCTAssertEqual(filteredTags.count, 1)
        XCTAssertEqual(filteredTags, Set([tag1]))
    }
}
