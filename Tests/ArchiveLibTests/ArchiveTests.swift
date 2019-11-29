//
//  ArchiveTests.swift
//  ArchiveLib
//
//  Created by Julian Kahnert on 26.12.18.
//

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

    func testTagSearch1() {

        // setup
        archive.add(from: URL(fileURLWithPath: "~/Downloads/2009/2009-05-12--aaa-example-description__tag1_tag2.pdf"), size: nil, downloadStatus: .local, status: .tagged)
        archive.add(from: URL(fileURLWithPath: "~/Downloads/2010/2010-05-12--bbb-example-description__tag1_tag2.pdf"), size: nil, downloadStatus: .local, status: .tagged)
        archive.add(from: URL(fileURLWithPath: "~/Downloads/2011/2011-05-12--ccc-example-description__tag1_tag2.pdf"), size: nil, downloadStatus: .local, status: .tagged)
        archive.add(from: URL(fileURLWithPath: "~/Downloads/2010/2010-02-11--ddd-example-description__tag11_tag22.pdf"), size: nil, downloadStatus: .local, status: .untagged)
        XCTAssertEqual(archive.get(scope: .all, searchterms: [], status: .tagged).count, 3)
        XCTAssertEqual(archive.get(scope: .all, searchterms: [], status: .untagged).count, 1)

        // calculate
        let tags = archive.getAvailableTags(with: [])

        // assert
        XCTAssertEqual(tags.count, 4)
        XCTAssertTrue(tags.contains("tag1"))
        XCTAssertTrue(tags.contains("tag2"))
        XCTAssertTrue(tags.contains("tag11"))
        XCTAssertTrue(tags.contains("tag22"))
    }

    func testTagSearch2() {

        // setup
        archive.add(from: URL(fileURLWithPath: "~/Downloads/2009/2009-05-12--aaa-example-description__tag1_tag2.pdf"), size: nil, downloadStatus: .local, status: .tagged)
        archive.add(from: URL(fileURLWithPath: "~/Downloads/2010/2010-05-12--bbb-example-description__tag1_tag2.pdf"), size: nil, downloadStatus: .local, status: .tagged)
        archive.add(from: URL(fileURLWithPath: "~/Downloads/2011/2011-05-12--ccc-example-description__tag1_tag2.pdf"), size: nil, downloadStatus: .local, status: .tagged)
        archive.add(from: URL(fileURLWithPath: "~/Downloads/2010/2010-02-11--ddd-example-description__tag11_tag22.pdf"), size: nil, downloadStatus: .local, status: .untagged)
        XCTAssertEqual(archive.get(scope: .all, searchterms: [], status: .tagged).count, 3)
        XCTAssertEqual(archive.get(scope: .all, searchterms: [], status: .untagged).count, 1)

        // calculate
        let tags = archive.getAvailableTags(with: ["2"])

        // assert
        XCTAssertEqual(tags.count, 2)
        XCTAssertFalse(tags.contains("tag1"))
        XCTAssertTrue(tags.contains("tag2"))
        XCTAssertFalse(tags.contains("tag11"))
        XCTAssertTrue(tags.contains("tag22"))
    }
}
