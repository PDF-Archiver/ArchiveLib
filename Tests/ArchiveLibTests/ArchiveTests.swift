//
//  ArchiveTests.swift
//  ArchiveLib
//
//  Created by Julian Kahnert on 26.12.18.
//
// swiftlint:disable force_unwrapping

import ArchiveLib
import Foundation
import XCTest

class ArchiveTests: XCTestCase {

    var archive = Archive()

    override func setUp() {
        super.setUp()

        // reset the document manager
        archive = Archive()
    }

    // MARK: - document handling

    func testDocumentAdd() {

        // setup
        archive.add(from: URL(fileURLWithPath: "~/Downloads/2009/2009-05-12--aaa-example-description__tag1_tag2.pdf"), size: nil, downloadStatus: .local, status: .tagged)
        archive.add(from: URL(fileURLWithPath: "~/Downloads/2010/2010-05-12--bbb-example-description__tag1_tag2.pdf"), size: nil, downloadStatus: .local, status: .tagged)
        archive.add(from: URL(fileURLWithPath: "~/Downloads/2011/2011-05-12--ccc-example-description__tag1_tag2.pdf"), size: nil, downloadStatus: .local, status: .tagged)
        archive.add(from: URL(fileURLWithPath: "~/Downloads/2010/2010-02-11--ddd-example-description__tag1_tag2.pdf"), size: nil, downloadStatus: .local, status: .untagged)

        // calculate
        let documents1 = archive.get(scope: .all, searchterms: [], status: .tagged)
        let documents2 = archive.get(scope: .year(year: "2010"), searchterms: [], status: .tagged)
        let documents3 = archive.get(scope: .year(year: "2000"), searchterms: [], status: .tagged)
        let documents4 = archive.get(scope: .all, searchterms: [], status: .untagged)

        // assert
        XCTAssertEqual(archive.years.count, 3)
        XCTAssertTrue(archive.years.contains("2009"))
        XCTAssertTrue(archive.years.contains("2010"))
        XCTAssertTrue(archive.years.contains("2011"))
        XCTAssertEqual(documents1.count, 3)
        XCTAssertEqual(documents2.count, 1)
        XCTAssertEqual(documents3.count, 0)
        XCTAssertEqual(documents4.count, 1)
    }

    func testDocumentRemove() {

        // setup
        archive.add(from: URL(fileURLWithPath: "~/Downloads/2009/2009-05-12--aaa-example-description__tag1_tag2.pdf"), size: nil, downloadStatus: .local, status: .tagged)
        archive.add(from: URL(fileURLWithPath: "~/Downloads/2010/2010-05-12--bbb-example-description__tag1_tag2.pdf"), size: nil, downloadStatus: .local, status: .tagged)
        archive.add(from: URL(fileURLWithPath: "~/Downloads/2011/2011-05-12--ccc-example-description__tag1_tag2.pdf"), size: nil, downloadStatus: .local, status: .tagged)
        archive.add(from: URL(fileURLWithPath: "~/Downloads/2010/2010-02-11--ddd-example-description__tag1_tag2.pdf"), size: nil, downloadStatus: .local, status: .untagged)

        // calculate
        guard let taggedDocument = archive.get(scope: .all, searchterms: [], status: .tagged).first else { XCTFail("No document found!"); return }
        guard let untaggedDocument = archive.get(scope: .all, searchterms: [], status: .untagged).first else { XCTFail("No document found!"); return }
        archive.remove(Set([taggedDocument, untaggedDocument]))

        // assert
        XCTAssertEqual(archive.get(scope: .all, searchterms: [], status: .tagged).count, 2)
        XCTAssertEqual(archive.get(scope: .all, searchterms: [], status: .untagged).count, 0)
    }

    func testDocumentRemoveAll() {

        // setup
        archive.add(from: URL(fileURLWithPath: "~/Downloads/2009/2009-05-12--aaa-example-description__tag1_tag2.pdf"), size: nil, downloadStatus: .local, status: .tagged)
        archive.add(from: URL(fileURLWithPath: "~/Downloads/2010/2010-05-12--bbb-example-description__tag1_tag2.pdf"), size: nil, downloadStatus: .local, status: .tagged)
        archive.add(from: URL(fileURLWithPath: "~/Downloads/2011/2011-05-12--ccc-example-description__tag1_tag2.pdf"), size: nil, downloadStatus: .local, status: .tagged)
        archive.add(from: URL(fileURLWithPath: "~/Downloads/2010/2010-02-11--ddd-example-description__tag1_tag2.pdf"), size: nil, downloadStatus: .local, status: .untagged)

        // calculate

        // assert
        archive.removeAll(.tagged)
        XCTAssertEqual(archive.get(scope: .all, searchterms: [], status: .tagged).count, 0)
        XCTAssertEqual(archive.get(scope: .all, searchterms: [], status: .untagged).count, 1)

        archive.removeAll(.untagged)
        XCTAssertEqual(archive.get(scope: .all, searchterms: [], status: .tagged).count, 0)
        XCTAssertEqual(archive.get(scope: .all, searchterms: [], status: .untagged).count, 0)
    }

    func testDocumentUpdate1() {

        // setup
        let downloadStatus = DownloadStatus.iCloudDrive
        archive.add(from: URL(fileURLWithPath: "~/Downloads/2009/2009-05-12--aaa-example-description__tag1_tag2.pdf"), size: nil, downloadStatus: .local, status: .tagged)
        archive.add(from: URL(fileURLWithPath: "~/Downloads/2010/2010-05-12--bbb-example-description__tag1_tag2.pdf"), size: nil, downloadStatus: .local, status: .tagged)
        archive.add(from: URL(fileURLWithPath: "~/Downloads/2011/2011-05-12--ccc-example-description__tag1_tag2.pdf"), size: nil, downloadStatus: .local, status: .tagged)
        archive.add(from: URL(fileURLWithPath: "~/Downloads/2010/2010-02-11--ddd-example-description__tag1_tag2.pdf"), size: nil, downloadStatus: .local, status: .untagged)

        // calculate
        guard let taggedDocument = archive.get(scope: .all, searchterms: ["aaa"], status: .tagged).first else { XCTFail("No document found!"); return }
        guard let untaggedDocument = archive.get(scope: .all, searchterms: ["ddd"], status: .untagged).first else { XCTFail("No document found!"); return }
        XCTAssertEqual(taggedDocument.downloadStatus, .local)
        XCTAssertEqual(untaggedDocument.downloadStatus, .local)
        taggedDocument.downloadStatus = downloadStatus
        untaggedDocument.downloadStatus = downloadStatus
        archive.update(taggedDocument)
        archive.update(untaggedDocument)

        // assert
        XCTAssertEqual(archive.get(scope: .all, searchterms: [], status: .tagged).count, 3)
        XCTAssertEqual(archive.get(scope: .all, searchterms: [], status: .untagged).count, 1)
        guard let newTaggedDocument = archive.get(scope: .all, searchterms: ["aaa"], status: .tagged).first else { XCTFail("No document found!"); return }
        guard let newUntaggedDocument = archive.get(scope: .all, searchterms: ["ddd"], status: .untagged).first else { XCTFail("No document found!"); return }
        XCTAssertEqual(newTaggedDocument.downloadStatus, downloadStatus)
        XCTAssertEqual(newUntaggedDocument.downloadStatus, downloadStatus)
    }

    func testDocumentUpdate2() {

        // setup
        let path1 = URL(fileURLWithPath: "~/Downloads/2005/2005-05-12--eee-example-description__tag1_tag2.pdf")
        let path2 = URL(fileURLWithPath: "~/Downloads/2006/2006-02-11--fff-example-description__tag1_tag2.pdf")
        archive.add(from: path1, size: nil, downloadStatus: .local, status: .tagged)
        archive.add(from: path2, size: nil, downloadStatus: .local, status: .untagged)
        XCTAssertEqual(archive.get(scope: .all, searchterms: ["eee"], status: .tagged).first?.downloadStatus, .local)
        XCTAssertEqual(archive.get(scope: .all, searchterms: ["fff"], status: .untagged).first?.downloadStatus, .local)

        // calculate
        let document1 = archive.update(from: path1, size: nil, downloadStatus: .iCloudDrive, status: .tagged)
        let document2 = archive.update(from: path2, size: nil, downloadStatus: .iCloudDrive, status: .untagged)

        // assert
        XCTAssertEqual(archive.get(scope: .all, searchterms: ["eee"], status: .tagged).first?.downloadStatus, .iCloudDrive)
        XCTAssertEqual(archive.get(scope: .all, searchterms: ["fff"], status: .untagged).first?.downloadStatus, .iCloudDrive)
        XCTAssertEqual(document1.downloadStatus, .iCloudDrive)
        XCTAssertEqual(document2.downloadStatus, .iCloudDrive)
    }

    func testArchiveDocument() {

        // setup
        archive.add(from: URL(fileURLWithPath: "~/Downloads/2009/2009-05-12--aaa-example-description__tag1_tag2.pdf"), size: nil, downloadStatus: .local, status: .tagged)
        archive.add(from: URL(fileURLWithPath: "~/Downloads/2010/2010-05-12--bbb-example-description__tag1_tag2.pdf"), size: nil, downloadStatus: .local, status: .tagged)
        archive.add(from: URL(fileURLWithPath: "~/Downloads/2011/2011-05-12--ccc-example-description__tag1_tag2.pdf"), size: nil, downloadStatus: .local, status: .tagged)
        archive.add(from: URL(fileURLWithPath: "~/Downloads/2010/2010-02-11--ddd-example-description__tag1_tag2.pdf"), size: nil, downloadStatus: .local, status: .untagged)
        XCTAssertEqual(archive.get(scope: .all, searchterms: [], status: .tagged).count, 3)
        XCTAssertEqual(archive.get(scope: .all, searchterms: [], status: .untagged).count, 1)

        // calculate
        guard let untaggedDocument = archive.get(scope: .all, searchterms: ["ddd"], status: .untagged).first else { XCTFail("No document found!"); return }
        archive.archive(untaggedDocument)

        // assert
        XCTAssertNil(archive.get(scope: .all, searchterms: [], status: .untagged).first)
    }

    // MARK: - tag handling

    func testAddTag() {

        // setup

        // calculate
        let tag1 = archive.add("tagTest1")
        let tag2 = archive.add("tagTest2", count: 2)

        // assert
        XCTAssertEqual(tag1.name, "tagTest1")
        XCTAssertEqual(tag1.count, 1)
        XCTAssertEqual(tag2.name, "tagTest2")
        XCTAssertEqual(tag2.count, 2)
    }

    func testGetAvailableTags() {

        // setup
        _ = archive.add("tagTest1")
        _ = archive.add("tagTest2", count: 2)
        _ = archive.add("tagTest3", count: 3)

        // calculate & assert
        XCTAssertEqual(archive.getAvailableTags(with: []).count, 3)
        XCTAssertEqual(archive.getAvailableTags(with: ["tagTest"]).count, 3)
        XCTAssertEqual(archive.getAvailableTags(with: ["tag", "Test"]).count, 3)
        XCTAssertEqual(archive.getAvailableTags(with: ["tagTest3"]).count, 1)
        XCTAssertEqual(archive.getAvailableTags(with: ["tagTest", "3"]).count, 1)
    }

    func testRemoveTag() {

        // setup
        _ = archive.add("tagTest1")
        _ = archive.add("tagTest2", count: 2)
        _ = archive.add("tagTest3", count: 3)

        // calculate
        archive.removeTag("tagTest1")
        archive.removeTag("tagTest3")

        // assert
        XCTAssertEqual(archive.getAvailableTags(with: []).count, 2)
        XCTAssertEqual(archive.getAvailableTags(with: ["tagTest2"]).first?.count, 2)
        XCTAssertEqual(archive.getAvailableTags(with: ["tagTest3"]).first?.count, 2)
    }

    func testAddTagToDocument() {

        // setup
        archive.add(from: URL(fileURLWithPath: "~/Downloads/2009/2009-05-12--aaa-example-description__tag1_tag2.pdf"), size: nil, downloadStatus: .local, status: .tagged)
        archive.add(from: URL(fileURLWithPath: "~/Downloads/2010/2010-05-12--bbb-example-description__tag1_tag2.pdf"), size: nil, downloadStatus: .local, status: .tagged)
        archive.add(from: URL(fileURLWithPath: "~/Downloads/2011/2011-05-12--ccc-example-description__tag1_tag2.pdf"), size: nil, downloadStatus: .local, status: .tagged)
        archive.add(from: URL(fileURLWithPath: "~/Downloads/2010/2010-02-11--ddd-example-description__tag1_tag2.pdf"), size: nil, downloadStatus: .local, status: .untagged)

        let tagName = "tagTest2"
        let tag = archive.add(tagName, count: 2)
        guard let taggedDocument = archive.get(scope: .all, searchterms: ["aaa"], status: .tagged).first else { XCTFail("No document found!"); return }
        guard let untaggedDocument = archive.get(scope: .all, searchterms: ["ddd"], status: .untagged).first else { XCTFail("No document found!"); return }

        // calculate
        archive.add(tag: tagName, to: taggedDocument)
        archive.add(tag: tagName, to: untaggedDocument)

        // assert
        XCTAssertEqual(archive.getAvailableTags(with: []).count, 3)
        XCTAssertTrue(archive.get(scope: .all, searchterms: ["aaa"], status: .tagged).first!.tags.contains(tag))
        XCTAssertTrue(archive.get(scope: .all, searchterms: ["ddd"], status: .untagged).first!.tags.contains(tag))
    }
}
