//
//  DocumentManagerTests.swift
//  ArchiveLib
//
//  Created by Julian Kahnert on 26.12.18.
//

@testable import ArchiveLib
import Foundation
import XCTest

class DocumentManagerTests: XCTestCase {

    let defaultDownloadStatus = DownloadStatus.local
    let defaaultSize = Int64(1024)
    let tagManager = TagManager()
    var documentManager = DocumentManager()

    lazy var document1 = Document(path: URL(fileURLWithPath: "~/Downloads/2018-05-12--aaa-example-description__tag1_tag2.pdf"), tagManager: tagManager, size: defaaultSize, downloadStatus: defaultDownloadStatus, taggingStatus: .tagged)
    lazy var document2 = Document(path: URL(fileURLWithPath: "~/Downloads/2018-05-12--bbb-example-description__tag1_tag2.pdf"), tagManager: tagManager, size: defaaultSize, downloadStatus: defaultDownloadStatus, taggingStatus: .tagged)
    lazy var document3 = Document(path: URL(fileURLWithPath: "~/Downloads/2018-05-12--ccc-example-description__tag1_tag2.pdf"), tagManager: tagManager, size: defaaultSize, downloadStatus: defaultDownloadStatus, taggingStatus: .tagged)

    override func setUp() {
        super.setUp()

        // reset the document manager
        documentManager = DocumentManager()
    }

    func testDocumentAdd1() {

        // setup
        documentManager.add(document1)

        // calculate

        // assert
        XCTAssertEqual(documentManager.documents.count, 1)
        XCTAssertEqual(documentManager.documents, Set([document1]))
    }

    func testDocumentAdd2() {

        // setup
        let documents = Set([document1, document2, document3])

        // calculate
        documentManager.add(documents)

        // assert
        XCTAssertEqual(documentManager.documents.count, 3)
        XCTAssertEqual(documentManager.allSearchElements.count, 3)
        XCTAssertEqual(documentManager.documents, documents)
    }

    func testDocumentRemove() {

        // setup
        let documents = Set([document1, document2, document3])
        documentManager.add(documents)

        // calculate
        documentManager.remove(document1)

        // assert
        XCTAssertEqual(documentManager.documents.count, 2)
        XCTAssertEqual(documentManager.documents, documents.subtracting(Set([document1])))
    }

    func testDocumentRemoveAll() {

        // setup
        let documents = Set([document1, document2, document3])
        documentManager.add(documents)

        // calculate
        documentManager.removeAll()

        // assert
        XCTAssertEqual(documentManager.documents.count, 0)
    }

    func testDocumentUpdate() {

        // setup
        let newTaggingStatus = TaggingStatus.untagged
        let documents = Set([document1, document2, document3])
        documentManager.add(documents)
        document1.taggingStatus = newTaggingStatus

        // calculate
        documentManager.update(document1)
        guard let updatedDocument = documentManager.documents.first(where: { $0.filename == document1.filename }) else { XCTFail("No document found!"); return }

        // assert
        XCTAssertEqual(documentManager.documents.count, 3)
        XCTAssertEqual(updatedDocument.filename, document1.filename)
        XCTAssertEqual(updatedDocument.taggingStatus, newTaggingStatus)
    }
}
