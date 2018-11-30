//
//  Document.swift
//  ArchiveLib
//
//  Created by Julian Kahnert on 13.11.18.
//

import Foundation
import os.log

public enum DownloadStatus: Equatable {
    case iCloudDrive
    case downloading(percentDownloaded: Float)
    case local
}

public enum DocumentError: Error {
    case description
    case tags
}

public struct Document: Logging {

    // ArchiveLib essentials
    public var date: Date
    public var specification: String
    public var tags = Set<Tag>()

    // data from filename
    public private(set) var folder: String
    public private(set) var filename: String
    public private(set) var path: URL

    public private(set) var size: String?
    public var downloadStatus: DownloadStatus?

    // helpers
    public var specificationCapitalized: String {
        return specification
            .split(separator: " ")
            .flatMap { String($0).split(separator: "-") }
            .map { String($0).capitalizingFirstLetter() }
            .joined(separator: " ")
    }

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
