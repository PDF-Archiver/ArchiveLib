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
    var documentManager = DocumentManager()

    lazy var document1 = Document(id: UUID(), path: URL(fileURLWithPath: "~/Downloads/2018-05-12--aaa-example-description__tag1_tag2.pdf"), size: defaaultSize, downloadStatus: defaultDownloadStatus, taggingStatus: .tagged)
    lazy var document2 = Document(id: UUID(), path: URL(fileURLWithPath: "~/Downloads/2018-05-12--bbb-example-description__tag1_tag2.pdf"), size: defaaultSize, downloadStatus: defaultDownloadStatus, taggingStatus: .tagged)
    lazy var document3 = Document(id: UUID(), path: URL(fileURLWithPath: "~/Downloads/2018-05-12--ccc-example-description__tag1_tag2.pdf"), size: defaaultSize, downloadStatus: defaultDownloadStatus, taggingStatus: .tagged)

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
        XCTAssertEqual(documentManager.documents.value.count, 1)
        XCTAssertEqual(documentManager.documents.value, Set([document1]))
    }

    func testDocumentAdd2() {

        // setup
        let documents = Set([document1, document2, document3])

        // calculate
        documentManager.add(documents)

        // assert
        XCTAssertEqual(documentManager.documents.value.count, 3)
        XCTAssertEqual(documentManager.allSearchElements.count, 3)
        XCTAssertEqual(documentManager.documents.value, documents)
    }

    func testDocumentRemove() {

        // setup
        let documents = Set([document1, document2, document3])
        documentManager.add(documents)

        // calculate
        documentManager.remove(document1)

        // assert
        XCTAssertEqual(documentManager.documents.value.count, 2)
        XCTAssertEqual(documentManager.documents.value, documents.subtracting(Set([document1])))
    }

    func testDocumentRemoveAll() {

        // setup
        let documents = Set([document1, document2, document3])
        documentManager.add(documents)

        // calculate
        documentManager.removeAll()

        // assert
        XCTAssertEqual(documentManager.documents.value.count, 0)
    }

    func testDocumentUpdate() {

        // setup
        let newTaggingStatus = TaggingStatus.untagged
        let documents = Set([document1, document2, document3])
        documentManager.add(documents)
        document1.taggingStatus = newTaggingStatus

        // calculate
        documentManager.update(document1)
        guard let updatedDocument = documentManager.documents.value.first(where: { $0.filename == document1.filename }) else { XCTFail("No document found!"); return }

        // assert
        XCTAssertEqual(documentManager.documents.value.count, 3)
        XCTAssertEqual(updatedDocument.filename, document1.filename)
        XCTAssertEqual(updatedDocument.taggingStatus, newTaggingStatus)
    }
}
