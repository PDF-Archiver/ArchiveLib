//
//  DocumentTests.swift
//  ArchiveLib-iOS Tests
//
//  Created by Julian Kahnert on 30.11.18.
//

import ArchiveLib
import XCTest

class DocumentTests: XCTestCase {

    var tag1 = Tag(name: "tag1", count: 1)
    var tag2 = Tag(name: "tag2", count: 2)
    var tag3 = Tag(name: "tag3", count: 3)
    lazy var tags = Set([tag1, tag2, tag3])

    let defaultDownloadStatus = DownloadStatus.local
    let defaaultSize = Int64(1024)

    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }

    override func setUp() {
        super.setUp()

        // reset the tags
        self.tag1 = Tag(name: "tag1", count: 1)
        self.tag2 = Tag(name: "tag2", count: 2)
        self.tag3 = Tag(name: "tag3", count: 3)
        self.tags = Set([self.tag1, self.tag2, self.tag3])
    }

    // MARK: - Test Document.parseFilename

    func testFilenameParsing1() {

        // setup
        let path = URL(fileURLWithPath: "~/Downloads/2010-05-12--example-description__tag1_tag2_tag4.pdf")

        // calculate
        let parsingOutput = Document.parseFilename(path)

        // assert
        XCTAssertEqual(parsingOutput.date, dateFormatter.date(from: "2010-05-12"))
        XCTAssertEqual(parsingOutput.specification, "example-description")
        XCTAssertEqual(parsingOutput.tagNames, ["tag1", "tag2", "tag4"])
    }

    func testFilenameParsing2() {

        // setup
        let path = URL(fileURLWithPath: "~/Downloads/2010-05-12__tag1_tag2_tag4.pdf")

        // calculate
        let parsingOutput = Document.parseFilename(path)

        // assert
        XCTAssertEqual(parsingOutput.date, dateFormatter.date(from: "2010-05-12"))
        XCTAssertNil(parsingOutput.specification)
        XCTAssertEqual(parsingOutput.tagNames, ["tag1", "tag2", "tag4"])
    }

    func testFilenameParsing3() {

        // setup
        let path = URL(fileURLWithPath: "~/Downloads/scan 1.pdf")

        // calculate
        let parsingOutput = Document.parseFilename(path)

        // assert
        XCTAssertNil(parsingOutput.date)
        XCTAssertEqual(parsingOutput.specification, "scan 1")
        XCTAssertNil(parsingOutput.tagNames)
    }

    // MARK: - Test Document.getRenamingPath

    func testDocumentRenaming() {

        // setup
        let path = URL(fileURLWithPath: "~/Downloads/scan1.pdf")
        var document = Document(path: path, availableTags: &tags, size: defaaultSize, downloadStatus: defaultDownloadStatus)

        document.date = dateFormatter.date(from: "2010-05-12") ?? Date()
        document.specification = "example-description"
        document.tags = Set([tag1, tag2])

        // calculate
        let renameOutput = try? document.getRenamingPath()

        // assert
        XCTAssertNoThrow(try document.getRenamingPath())
        XCTAssertEqual(renameOutput?.foldername, "2010")
        XCTAssertEqual(renameOutput?.filename, "2010-05-12--example-description__tag1_tag2.pdf")
    }

    func testDocumentRenamingWithSpaceInDescriptionSlugify() {

        // setup
        let path = URL(fileURLWithPath: "~/Downloads/Testscan 1.pdf")

        var document = Document(path: path, availableTags: &tags, size: defaaultSize, downloadStatus: defaultDownloadStatus)
        document.specification = "this-is-a-test"
        document.tags = Set([tag1])
        document.date = dateFormatter.date(from: "2010-05-12") ?? Date()

        let renameOutput = try? document.getRenamingPath()

        // assert
        XCTAssertNoThrow(try document.getRenamingPath())
        XCTAssertEqual(renameOutput?.foldername, "2010")
        XCTAssertEqual(renameOutput?.filename, "2010-05-12--this-is-a-test__tag1.pdf")
    }

    func testDocumentRenamingWithFullFilename() {

        // setup
        let path = URL(fileURLWithPath: "~/Downloads/2010-05-12--example-description__tag1_tag2.pdf")
        let document = Document(path: path, availableTags: &tags, size: defaaultSize, downloadStatus: defaultDownloadStatus)

        // calculate
        let renameOutput = try? document.getRenamingPath()

        // assert
        XCTAssertNoThrow(try document.getRenamingPath())
        XCTAssertEqual(renameOutput?.foldername, "2010")
        XCTAssertEqual(renameOutput?.filename, "2010-05-12--example-description__tag1_tag2.pdf")
    }

    func testDocumentRenamingWithNoTags() {

        // setup
        let path = URL(fileURLWithPath: "~/Downloads/scan1.pdf")

        // calculate
        let document = Document(path: path, availableTags: &tags, size: defaaultSize, downloadStatus: defaultDownloadStatus)

        // assert
        XCTAssertEqual(document.tags.count, 0)
        XCTAssertEqual(document.specification, "scan1")
        XCTAssertThrowsError(try document.getRenamingPath())
    }

    func testDocumentRenamingWithNoSpecification() {

        // setup
        let path = URL(fileURLWithPath: "~/Downloads/scan1__tag1_tag2.pdf")

        // calculate
        var document = Document(path: path, availableTags: &tags, size: defaaultSize, downloadStatus: defaultDownloadStatus)
        document.specification = ""

        // assert
        XCTAssertEqual(document.tags.count, 2)
        XCTAssertEqual(document.specification, "")
        XCTAssertThrowsError(try document.getRenamingPath())
    }

    // MARK: - Test Hashable, Comparable, CustomStringConvertible

    func testHashable() {

        // setup
        let document1 = Document(path: URL(fileURLWithPath: "~/Downloads/2018-05-12--aaa-example-description__tag1_tag2.pdf"), availableTags: &tags, size: defaaultSize, downloadStatus: defaultDownloadStatus)
        let document2 = Document(path: URL(fileURLWithPath: "~/Downloads/2018-05-12--bbb-example-description__tag1_tag2.pdf"), availableTags: &tags, size: defaaultSize, downloadStatus: defaultDownloadStatus)
        let document3 = Document(path: URL(fileURLWithPath: "~/Downloads/2010-05-12--aaa-example-description__tag1_tag2.pdf"), availableTags: &tags, size: defaaultSize, downloadStatus: defaultDownloadStatus)

        // assert
        // sort by date
        XCTAssertTrue(document3 < document1)
        // sort by filename
        XCTAssertTrue(document2 < document1)

    }

    func testComparable() {

        // setup
        let document1 = Document(path: URL(fileURLWithPath: "~/Downloads/2018-05-12--example-description__tag1_tag2.pdf"), availableTags: &tags, size: defaaultSize, downloadStatus: defaultDownloadStatus)
        var document2 = Document(path: URL(fileURLWithPath: "~/Downloads/2018-05-12--example-description__tag1_tag2.pdf"), availableTags: &tags, size: defaaultSize, downloadStatus: defaultDownloadStatus)

        document2.specification = "this is a test"

        // assert
        XCTAssertEqual(document1, document2)
        XCTAssertEqual(document1.hashValue, document1.path.hashValue)
        XCTAssertEqual(document1.hashValue, document2.hashValue)
    }

    func testCustomStringConvertible() {

        // setup
        let path = URL(fileURLWithPath: "~/Downloads/2018-05-12--example-description__tag1_tag2.pdf")
        let document = Document(path: path, availableTags: &tags, size: defaaultSize, downloadStatus: defaultDownloadStatus)

        // assert
        XCTAssertEqual(document.description, path.lastPathComponent)
    }

    func testSearchable() {

        // setup
        let path = URL(fileURLWithPath: "~/Downloads/2018-05-12--example-description__tag1_tag2.pdf")
        let document = Document(path: path, availableTags: &tags, size: defaaultSize, downloadStatus: defaultDownloadStatus)

        // assert
        XCTAssertEqual(document.searchTerm, path.lastPathComponent)
    }

    // MARK: - Test the whole workflow

    func testDocumentNameParsing() {

        // setup some of the testing variables
        let path = URL(fileURLWithPath: "~/Downloads/2010-05-12--example-description__tag1_tag2_tag4.pdf")

        // create a basic document
        let document = Document(path: path, availableTags: &tags, size: defaaultSize, downloadStatus: defaultDownloadStatus)

        // assert
        XCTAssertEqual(document.specification, "example-description")

        XCTAssertEqual(document.tags.count, 3)
        XCTAssertTrue(document.tags.contains(tag1))
        XCTAssertTrue(document.tags.contains(tag2))
        XCTAssertTrue(tags.contains { $0.name == "tag1" && $0.count == 2 }, "The count of 'tag1' should be incremented, but actually wasn't.")
        XCTAssertTrue(tags.contains { $0.name == "tag2" && $0.count == 3 }, "The count of 'tag2' should be incremented, but actually wasn't.")
        XCTAssertTrue(tags.contains { $0.name == "tag4" && $0.count == 1 }, "The count of 'tag4' should be incremented, but actually wasn't.")

        XCTAssertEqual(document.date, dateFormatter.date(from: "2010-05-12"))
    }

    func testDocumentWithEmptyName() {

        // setup
        let path = URL(fileURLWithPath: "~/Downloads/scan1.pdf")

        // calculate
        let document = Document(path: path, availableTags: &tags, size: defaaultSize, downloadStatus: defaultDownloadStatus)

        // assert
        XCTAssertEqual(Calendar.current.compare(document.date, to: Date(), toGranularity: .day), .orderedSame)
    }

    func testDocumentDateParsingFormat1() {

        // setup
        let path = URL(fileURLWithPath: "~/Downloads/2010-05-12 example filename.pdf")

        // calculate
        let document = Document(path: path, availableTags: &tags, size: defaaultSize, downloadStatus: defaultDownloadStatus)

        // assert
        XCTAssertEqual(document.date, dateFormatter.date(from: "2010-05-12"))
        XCTAssertEqual(document.specification, "example filename")
        XCTAssertEqual(document.specificationCapitalized, "Example Filename")
        XCTAssertEqual(document.tags, Set())
    }

    func testDocumentDateParsingFormat2() {

        // setup
        let path = URL(fileURLWithPath: "~/Downloads/2010_05_12 example filename.pdf")

        // calculate
        let document = Document(path: path, availableTags: &tags, size: defaaultSize, downloadStatus: defaultDownloadStatus)

        // assert
        XCTAssertEqual(document.date, dateFormatter.date(from: "2010-05-12"))
        XCTAssertEqual(document.specification, "example filename")
        XCTAssertEqual(document.specificationCapitalized, "Example Filename")
        XCTAssertEqual(document.tags, Set())
    }

    func testDocumentDateParsingFormat3() {

        // setup
        let path = URL(fileURLWithPath: "~/Downloads/20100512 example filename.pdf")

        // calculate
        let document = Document(path: path, availableTags: &tags, size: defaaultSize, downloadStatus: defaultDownloadStatus)

        // assert
        XCTAssertEqual(document.date, dateFormatter.date(from: "2010-05-12"))
        XCTAssertEqual(document.specification, "example filename")
        XCTAssertEqual(document.specificationCapitalized, "Example Filename")
        XCTAssertEqual(document.tags, Set())
    }

    func testDocumentDateParsingFormat4() {

        // setup
        let path = URL(fileURLWithPath: "~/Downloads/2010_05_12__15_17.pdf")

        // calculate
        let document = Document(path: path, availableTags: &tags, size: defaaultSize, downloadStatus: defaultDownloadStatus)

        // assert
        XCTAssertEqual(document.date, dateFormatter.date(from: "2010-05-12"))
        XCTAssertEqual(document.specification, "")
        XCTAssertTrue(document.tags.contains { $0.name == "15" })
        XCTAssertTrue(document.tags.contains { $0.name == "17" })
    }

    func testDocumentDateParsingScanSnapFormat() {

        // setup
        let path = URL(fileURLWithPath: "~/Downloads/2010_05_12_15_17.pdf")

        // calculate
        let document = Document(path: path, availableTags: &tags, size: defaaultSize, downloadStatus: defaultDownloadStatus)

        // assert
        XCTAssertEqual(document.date, dateFormatter.date(from: "2010-05-12"))
        XCTAssertEqual(document.specification, "15-17")
        XCTAssertEqual(document.specificationCapitalized, "15 17")
        XCTAssertEqual(document.tags, Set())
    }
}
