//
//  Document.swift
//  ArchiveLib
//
//  Created by Julian Kahnert on 13.11.18.
//

import Foundation
import os.log

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

/// Errors which can occur while handling a document.
///
/// - description: A error in the description.
/// - tags: A error in the document tags.
public enum DocumentError: Error {
    case description
    case tags
}

/// Main structure which contains a document.
public struct Document: Logging {

    // MARK: ArchiveLib essentials
    /// Date of the document.
    public var date: Date
    /// Details of the document, e.g. "blue pullover".
    public var specification: String
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
    public var downloadStatus: DownloadStatus?

    /// Details of the document with capitalized first letter, e.g. "Blue Pullover".
    public var specificationCapitalized: String {
        return specification
            .split(separator: " ")
            .flatMap { String($0).split(separator: "-") }
            .map { String($0).capitalizingFirstLetter() }
            .joined(separator: " ")
    }

    /// Create a new document, which contains the main information (date, specification, tags) of the ArchiveLib.
    ///
    /// - Parameters:
    ///   - documentPath: Path of the file on disk.
    ///   - availableTags: Currently available tags in archive.
    ///   - byteSize: Size of this documen in number of bytes.
    ///   - documentDownloadStatus: Download status of the document.
    public init(path documentPath: URL, availableTags: inout Set<Tag>, size byteSize: Int64?, downloadStatus documentDownloadStatus: DownloadStatus?) {

        path = documentPath
        filename = documentPath.lastPathComponent
        folder = documentPath.deletingLastPathComponent().lastPathComponent
        downloadStatus = documentDownloadStatus

        if let byteSize = byteSize {
            size = ByteCountFormatter.string(fromByteCount: byteSize, countStyle: .file)
        }

        // parse the current filename
        let parsedFilename = Document.parseFilename(documentPath)

        // set the date
        date = parsedFilename.date ?? Date()

        // get the available tags of the archive
        for documentTagName in parsedFilename.tagNames ?? [] {
            if var availableTag = availableTags.first(where: { $0.name == documentTagName }) {
                availableTag.count += 1
                availableTags.update(with: availableTag)
                tags.insert(availableTag)
            } else {
                let newTag = Tag(name: documentTagName, count: 1)
                availableTags.insert(newTag)
                tags.insert(newTag)
            }
        }

        // set the specification
        specification = parsedFilename.specification ?? ""
    }

    /// Get the new foldername and filename after applying the PDF Archiver naming scheme.
    ///
    /// ATTENTION: The specification will not be slugified in this step! Keep in mind to do this before this method call.
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

        // get formatted date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateStr = dateFormatter.string(from: self.date)

        // get description

        // get tags
        var tagStr = ""
        for tag in Array(tags).sorted(by: { $0.name < $1.name }) {
            tagStr += "\(tag.name)_"
        }
        tagStr = String(tagStr.dropLast(1))

        // create new filepath
        let filename = "\(dateStr)--\(specification)__\(tagStr).pdf"
        let foldername = String(dateStr.prefix(4))
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
        if let parsed = DateParser.parse(path.lastPathComponent) {
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
    public var hashValue: Int { return path.hashValue }

    public var description: String { return filename }
}

extension Document: Searchable {

    // Searchable stubs
    public var searchTerm: String { return filename }
}
