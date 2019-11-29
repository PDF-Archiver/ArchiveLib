//
//  DocumenTagTests.swift
//  
//
//  Created by Julian Kahnert on 29.11.19.
//

import XCTest

class DocumenTagTests: XCTestCase {

    var tempUrl: URL?

    override func setUp() {
        super.setUp()
        let url = generatedTempFileURL()
        touch(url: url)
        tempUrl = url
    }

    #if(OSX)
    func testReadFileTags() {
        guard let tempUrl = tempUrl else {
            XCTFail("Could not find ")
            return
        }
        let tags = ["bla", "foo"]

        // setup all tags
        XCTAssertNoThrow(try (tempUrl as NSURL).setResourceValues([.tagNamesKey: tags]))
        let urlValues = try? tempUrl.resourceValues(forKeys: [.tagNamesKey])
        XCTAssertEqual(urlValues?.tagNames, tags)

        // validate if url tags can be found
        let urlTags = tempUrl.fileTags
        XCTAssertEqual(urlTags, tags)
    }
    #endif

    #if(OSX)
    func testWriteFileTags() {
        guard var tempUrl = tempUrl else {
            XCTFail("Could not find ")
            return
        }
        let tags = ["bla", "foo"]

        // setup all tags
        tempUrl.fileTags = tags

        // validate if url tags can be found
        let urlValues = try? tempUrl.resourceValues(forKeys: [.tagNamesKey])
        XCTAssertEqual(urlValues?.tagNames, tags)
    }
    #endif

    func testReadWriteTags() {
        guard var tempUrl = tempUrl else {
            XCTFail("Could not find ")
            return
        }
        let tags = ["bla", "foo"]

        // setup all tags
        tempUrl.fileTags = tags

        // validate if url tags can be found
        let urlTags = tempUrl.fileTags
        XCTAssertEqual(urlTags, tags)
    }
}
