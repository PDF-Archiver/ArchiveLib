//
//  Document.swift
//  ArchiveLib
//
//  Created by Julian Kahnert on 13.11.18.
//

import Foundation
import os.log
#if os(OSX)
import Quartz
#else
import PDFKit
#endif

/// Download status of a file.
///
/// - iCloudDrive: The file is currently only in iCloud Drive available.
/// - downloading: The OS downloads the file currentyl.
/// - local: The file is locally available.
public enum DownloadStatus: Equatable {
    case iCloudDrive
    case downloading(percentDownloaded: Float)
    case local
}

/// Tagging status of a document.
///
/// - tagged: Document is already tagged.
/// - untagged: Document that is not tagged.
public enum TaggingStatus: String, Comparable {
    case tagged
    case untagged

    public static func < (lhs: TaggingStatus, rhs: TaggingStatus) -> Bool {
        return lhs == .untagged && rhs == .tagged
    }
}

/// Errors which can occur while handling a document.
///
/// - description: A error in the description.
/// - tags: A error in the document tags.
/// - renameFailed: Gerneral error while renaming document.
/// - renameFailedFileAlreadyExists: A document with this name already exists in the archive.
public enum DocumentError: Error {
    case description
    case tags
    case renameFailed
    case renameFailedFileAlreadyExists
}

/// Main structure which contains a document.
public class Document: Logging {

    // MARK: ArchiveLib essentials
    /// Date of the document.
    public var date: Date
    /// Details of the document, e.g. "blue pullover".
    public var specification: String {
        didSet {
            specification = specification.replacingOccurrences(of: "_", with: "-").lowercased()
        }
    }

    /// Tags/categories of the document.
    public var tags = Set<Tag>()

    // MARK: data from filename
    /// Name of the folder, e.g. "2018".
    public private(set) var folder: String
    /// Whole filename, e.g. "scan1.pdf".
    public private(set) var filename: String
    /// Path to the file.
    public private(set) var path: URL

    /// Size of the document, e.g. "1,5 MB".
    public private(set) var size: String?
    /// Download status of the document.
    public var downloadStatus: DownloadStatus
    /// Download status of the document.
    public var taggingStatus: TaggingStatus

    /// Details of the document with capitalized first letter, e.g. "Blue Pullover".
    public var specificationCapitalized: String {
        return specification
            .split(separator: " ")
            .flatMap { String($0).split(separator: "-") }
            .map { String($0).capitalizingFirstLetter() }
            .joined(separator: " ")
    }

    // MARK: private properties
    private let tagManager: TagManager

    /// Create a new document, which contains the main information (date, specification, tags) of the ArchiveLib.
    /// New documents should only be created by the DocumentManager in this package.
    ///
    /// - Parameters:
    ///   - documentPath: Path of the file on disk.
    ///   - availableTags: Currently available tags in archive.
    ///   - byteSize: Size of this documen in number of bytes.
    ///   - documentDownloadStatus: Download status of the document.
    init(path documentPath: URL, tagManager documentTagManager: TagManager, size byteSize: Int64?, downloadStatus documentDownloadStatus: DownloadStatus, taggingStatus documentTaggingStatus: TaggingStatus) {

        path = documentPath
        filename = documentPath.lastPathComponent
        folder = documentPath.deletingLastPathComponent().lastPathComponent
        downloadStatus = documentDownloadStatus
        taggingStatus = documentTaggingStatus
        tagManager = documentTagManager

        if let byteSize = byteSize {
            size = ByteCountFormatter.string(fromByteCount: byteSize, countStyle: .file)
        }

        // parse the current filename
        let parsedFilename = Document.parseFilename(documentPath)
        var tmpTags = parsedFilename.tagNames ?? []

        // set the date
        date = parsedFilename.date ?? Date()

        // get file tags https://stackoverflow.com/a/47340666
        #if os(OSX)
        var resource: AnyObject?
        try? (path as NSURL).getResourceValue(&resource, forKey: URLResourceKey.tagNamesKey)

        if let resource = resource,
            let fileTags = resource as? [String] {
            tmpTags.append(contentsOf: fileTags)
        }
        //#else
        // TODO: add iOS implementation here
        #endif

        // get the available tags of the archive
        for documentTagName in Set(tmpTags) {
            tags.insert(tagManager.add(documentTagName))
        }

        // set the specification
        specification = parsedFilename.specification ?? ""
    }

    /// Get the new foldername and filename after applying the PDF Archiver naming scheme.
    ///
    /// ATTENTION: The specification will not be slugified in this step! Keep in mind to do this before/after this method call.
    ///
    /// - Returns: Returns the new foldername and filename after renaming.
    /// - Throws: This method throws an error, if the document contains no tags or specification.
    public func getRenamingPath() throws -> (foldername: String, filename: String) {

        // create a filename and rename the document
        guard !tags.isEmpty else {
            throw DocumentError.tags
        }
        guard !specification.isEmpty else {
            throw DocumentError.description
        }

        let filename = Document.createFilename(date: date, specification: specification, tags: tags)
        let foldername = String(filename.prefix(4))

        return (foldername, filename)
    }

    /// Parse the filename from an URL.
    ///
    /// - Parameter path: Path which should be parsed.
    /// - Returns: Date, specification and tag names which can be parsed from the path.
    public static func parseFilename(_ path: URL) -> (date: Date?, specification: String?, tagNames: [String]?) {

        // try to parse the current filename
        var date: Date?
        var rawDate = ""
        if let parsed = Document.getFilenameDate(path.lastPathComponent) {
            date = parsed.date
            rawDate = parsed.rawDate
        } else if let parsed = DateParser.parse(path.lastPathComponent) {
            date = parsed.date
            rawDate = parsed.rawDate
        }

        // parse the specification
        var specification: String?

        if var raw = path.lastPathComponent.capturedGroups(withRegex: "--([\\w\\d-]+)__") {

            // try to parse the real specification from scheme
            specification = raw[0]

        } else {

            // save a first "raw" specification
            let tempSepcification = path.lastPathComponent
                // drop the already parsed date
                .dropFirst(rawDate.count)
                // drop the extension and the last .
                .dropLast(path.pathExtension.count + 1)
                // exclude tags, if they exist
                .components(separatedBy: "__")[0]
                // clean up all "_" - they are for tag use only!
                .replacingOccurrences(of: "_", with: "-")
                // remove a pre or suffix from the string
                .trimmingCharacters(in: ["-", " "])

            // save the raw specification, if it is not empty
            if !tempSepcification.isEmpty {
                specification = tempSepcification
            }
        }

        // parse the tags
        var tagNames: [String]?
        if var raw = path.lastPathComponent.capturedGroups(withRegex: "__([\\w\\d_]+).[pdfPDF]{3}$") {
            // parse the tags of a document
            tagNames = raw[0].components(separatedBy: "_")
        }

        return (date, specification, tagNames)
    }

    public static func createFilename(date: Date, specification: String, tags: Set<Tag>) -> String {
        // get formatted date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateStr = dateFormatter.string(from: date)

        // get description

        // get tags
        var tagStr = ""
        for tag in Array(tags).sorted(by: { $0.name < $1.name }) {
            tagStr += "\(tag.name)_"
        }
        tagStr = String(tagStr.dropLast(1))

        // create new filepath
        return "\(dateStr)--\(specification)__\(tagStr).pdf"
    }

    /// Parse the OCR content of the pdf document try to fetch a date and some tags.
    /// This overrides the current date and appends the new tags.
    ///
    /// ATTENTION: This method needs security access!
    ///
    /// - Parameter tagManager: TagManager that will be used when adding new tags.
    public func parseContent(_ options: ParsingOptions) {

        // skip the calculations if the OptionSet is empty
        guard !options.isEmpty else { return }

        // get the pdf content of every page
        guard let pdfDocument = PDFDocument(url: path) else { return }
        var text = ""
        for index in 0 ..< pdfDocument.pageCount {
            guard let page = pdfDocument.page(at: index),
                let pageContent = page.string else { return }

            text += pageContent
        }

        // verify that we got some pdf content
        guard !text.isEmpty else { return }

        // parse the date
        if options.contains(.date),
            let parsed = DateParser.parse(text) {
           date = parsed.date
        }

        // parse the tags
        if options.contains(.tags) {

            // get new tags
            let newTags = TagParser.parse(text)

            // get the already available tags
            let availableTags = Set(tagManager.allSearchElements.map { $0.name })

            // add all found tags which are already in the archive
            for newTag in newTags.intersection(availableTags) {
                tags.insert(tagManager.add(newTag))
            }
        }
    }

    /// Rename this document and save in in the archive path.
    ///
    /// - Parameters:
    ///   - archivePath: Path of the archive, where the document should be saved.
    ///   - slugify: Should the document name be slugified?
    /// - Throws: Renaming might fail and throws an error, e.g. because a document with this filename already exists.
    public func rename(archivePath: URL, slugify: Bool) throws {

        if slugify {
            specification = specification.slugified(withSeparator: "-")
        }

        let foldername: String
        let filename: String
        (foldername, filename) = try getRenamingPath()

        // check, if this path already exists ... create it
        let newFilepath = archivePath
            .appendingPathComponent(foldername)
            .appendingPathComponent(filename)
        let fileManager = FileManager.default
        do {
            let folderPath = newFilepath.deletingLastPathComponent()
            if !fileManager.fileExists(atPath: folderPath.path) {
                try fileManager.createDirectory(at: folderPath, withIntermediateDirectories: true, attributes: nil)
            }

            // test if the document name already exists in archive, otherwise move it
            if fileManager.fileExists(atPath: newFilepath.path),
                self.path != newFilepath {
                os_log("File already exists!", log: Document.log, type: .error)
                throw DocumentError.renameFailedFileAlreadyExists
            } else {
                try fileManager.moveItem(at: self.path, to: newFilepath)
            }
        } catch let error as NSError {
            os_log("Error while moving file: %@", log: Document.log, type: .error, error.description)
            throw DocumentError.renameFailed
        }

        // update document properties
        self.filename = String(newFilepath.lastPathComponent)
        self.path = newFilepath
        self.taggingStatus = .tagged

        // save tags
        saveTagsToFilesystem()
    }

    /// Save the tags of this document in the filesystem.
    public func saveTagsToFilesystem() {

        do {
            // get document tags
            let tags = self.tags
                .map { $0.name }
                .sorted()

            // set file tags [https://stackoverflow.com/a/47340666]
            #if os(OSX)
            try (path as NSURL).setResourceValue(tags, forKey: URLResourceKey.tagNamesKey)
            //#else
            // TODO: add iOS implementation here
            #endif

        } catch let error as NSError {
            os_log("Could not set file: %@", log: Document.log, type: .error, error.description)
        }
    }

    private static func getFilenameDate(_ raw: String) -> (date: Date, rawDate: String)? {
        if let groups = raw.capturedGroups(withRegex: "([\\d-]+)--") {
            let rawDate = groups[0]

            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"

            if let date = dateFormatter.date(from: rawDate) {
                return (date, rawDate)
            }
        }
        return nil
    }
}

extension Document: Hashable, Comparable, CustomStringConvertible {

    public static func < (lhs: Document, rhs: Document) -> Bool {

        // first: sort by date
        // second: sort by filename
        if lhs.date != rhs.date {
            return lhs.date < rhs.date
        }
        return lhs.filename > rhs.filename
    }

    public static func == (lhs: Document, rhs: Document) -> Bool {
        // "==" and hashValue must only compare the path to avoid duplicates in sets
        return lhs.path == rhs.path
    }

    // "==" and hashValue must only compare the path to avoid duplicates in sets
    public func hash(into hasher: inout Hasher) {
        hasher.combine(searchTerm)
    }

    public var description: String { return filename }
}

extension Document: Searchable {

    // Searchable stubs
    public var searchTerm: String { return filename }
}

extension Document: CustomComparable {
    public func isBefore(_ other: Document, _ sort: NSSortDescriptor) throws -> Bool {
        if sort.key == "filename" {
            return sort.ascending ? filename < other.filename : filename > other.filename
        } else if sort.key == "taggingStatus" {
            return sort.ascending ? taggingStatus < other.taggingStatus : taggingStatus > other.taggingStatus
        }
        throw SortDescriptorError.invalidKey
    }
}
