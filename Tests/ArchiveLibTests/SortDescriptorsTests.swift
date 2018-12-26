//
//  SortDescriptorsTests.swift
//  ArchiveLib
//
//  Created by Julian Kahnert on 20.12.18.
//

@testable import ArchiveLib
import Foundation
import XCTest

class SortDescriptorsTests: XCTestCase {

    let tag1 = Tag(name: "aaa", count: 10)
    let tag2 = Tag(name: "aaa", count: 20)
    let tag3 = Tag(name: "ccc", count: 1)
    var tags = Array<Tag>()

    let sortDescriptor1 = NSSortDescriptor(key: "name", ascending: true)
    let sortDescriptor2 = NSSortDescriptor(key: "name", ascending: false)
    let sortDescriptor3 = NSSortDescriptor(key: "count", ascending: true)
    let sortDescriptor4 = NSSortDescriptor(key: "count", ascending: false)

    override func setUp() {
        super.setUp()
        
        // reset the tags
        tags = [tag1, tag2, tag3]
    }

    // MARK: - single sort descriptor
    
    func testSortDescriptor1() {
        
        // setup
        let sortDescriptor = [sortDescriptor1]
        
        // calculate
        guard let sortedTags = try? sort(tags, by: sortDescriptor) else { XCTFail(); return }
        
        // assert
        XCTAssertEqual(sortedTags[0], tag1)
        XCTAssertEqual(sortedTags[1], tag2)
        XCTAssertEqual(sortedTags[2], tag3)
    }

    func testSortDescriptor2() {
        
        // setup
        let sortDescriptor = [sortDescriptor2]
        
        // calculate
        guard let sortedTags = try? sort(tags, by: sortDescriptor) else { XCTFail(); return }
        
        // assert
        XCTAssertEqual(sortedTags[0], tag3)
        XCTAssertEqual(sortedTags[1], tag2)
        XCTAssertEqual(sortedTags[2], tag1)
    }
    
    func testSortDescriptor3() {
        
        // setup
        let sortDescriptor = [sortDescriptor3]
        
        // calculate
        guard let sortedTags = try? sort(tags, by: sortDescriptor) else { XCTFail(); return }
        
        // assert
        XCTAssertEqual(sortedTags[0], tag3)
        XCTAssertEqual(sortedTags[1], tag1)
        XCTAssertEqual(sortedTags[2], tag2)
    }
    
    func testSortDescriptor4() {
        
        // setup
        let sortDescriptor = [sortDescriptor4]
        
        // calculate
        guard let sortedTags = try? sort(tags, by: sortDescriptor) else { XCTFail(); return }
        
        // assert
        XCTAssertEqual(sortedTags[0], tag2)
        XCTAssertEqual(sortedTags[1], tag1)
        XCTAssertEqual(sortedTags[2], tag3)
    }

    // MARK: - multiple sort descriptors
    
    func testSortDescriptors1() {

        // setup
        let sortDescriptor = [sortDescriptor1, sortDescriptor4]
        let tag = Tag(name: "aaa", count: 30)
        tags.append(tag)
        
        // calculate
        guard let sortedTags = try? sort(tags, by: sortDescriptor) else { XCTFail(); return }
        
        // assert
        XCTAssertEqual(sortedTags[0], tag1)
        XCTAssertEqual(sortedTags[1], tag2)
        XCTAssertEqual(sortedTags[2], tag)
        XCTAssertEqual(sortedTags[3], tag3)
    }
    
    func testSortDescriptors2() {
        
        // setup
        let sortDescriptor = [sortDescriptor3, sortDescriptor2]
        let tag = Tag(name: "aaa", count: 1)
        tags.append(tag)
        
        // calculate
        guard let sortedTags = try? sort(tags, by: sortDescriptor) else { XCTFail(); return }
        
        // assert
        XCTAssertEqual(sortedTags[0], tag3)
        XCTAssertEqual(sortedTags[1], tag1)
        XCTAssertEqual(sortedTags[2], tag2)
        XCTAssertEqual(sortedTags[3], tag)
    }
    
    // MARK: - sort errors
    
    func testInvalidSortDescriptors() {
        
        // setup
        let invalidSortDescriptor = NSSortDescriptor(key: "test", ascending: true)
        
        // calculate
        XCTAssertThrowsError(try sort(tags, by: [invalidSortDescriptor]))
    }
}
