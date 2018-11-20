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

public struct Document: Logging {

    // data from filename
    public private(set) var date: Date
    public private(set) var specification: String
    public private(set) var specificationCapitalized: String
    public private(set) var tags = Set<Tag>()

    public private(set) var folder: String
    public private(set) var filename: String
    public private(set) var path: URL

    public private(set) var size: String?
    public var downloadStatus: DownloadStatus?

    public init(path documentPath: URL, availableTags: inout Set<Tag>, size byteSize: Int64?, downloadStatus documentDownloadStatus: DownloadStatus?) {

        path = documentPath
        filename = documentPath.lastPathComponent
        folder = documentPath.deletingLastPathComponent().lastPathComponent

        if let byteSize = byteSize {
            size = ByteCountFormatter.string(fromByteCount: byteSize, countStyle: .file)
        }
        if let documentDownloadStatus = documentDownloadStatus {
            downloadStatus = documentDownloadStatus
        }

        // parse the current filename
        let parsedFilename = Document.parseFilename(documentPath)

        // set the date
        date = parsedFilename?.date ?? Date()

        // get the available tags of the archive
        for documentTagName in parsedFilename?.tagNames ?? [] {
            if var availableTag = availableTags.first(where: { $0.name == documentTagName }) {
                availableTag.count += 1
                tags.insert(availableTag)
            } else {
                let newTag = Tag(name: documentTagName, count: 1)
                availableTags.insert(newTag)
                tags.insert(newTag)
            }
        }

        // set the specification
        specification = parsedFilename?.specification ?? ""
        specificationCapitalized = specification
            .split(separator: "-")
            .map { String($0).capitalizingFirstLetter() }
            .joined(separator: " ")
    }

    public static func parseFilename(_ path: URL) -> (date: Date, specification: String, tagNames: [String])? {

        // try to parse the current filename
        let parser = DateParser()
        var date: Date?
        var rawDate = ""
        if let parsed = parser.parse(path.lastPathComponent) {
            date = parsed.date
            rawDate = parsed.rawDate
        }

        // save a first "raw" specification
        var specification: String? = path.lastPathComponent
            // drop the already parsed date
            .dropFirst(rawDate.count)
            // drop the extension and the last .
            .dropLast(path.pathExtension.count + 1)
            // exclude tags, if they exist
            .components(separatedBy: "__")[0]
            // clean up all "_" - they are for tag use only!
            .replacingOccurrences(of: "_", with: "-")
            // remove a pre or suffix from the string
            .trimmingCharacters(in: ["-"])

        // parse the specification and override it, if possible
        if var raw = path.lastPathComponent.capturedGroups(withRegex: "--([\\w\\d-]+)__") {
            specification = raw[0]
        }

        // parse the tags
        var tagNames: [String]?
        if var raw = path.lastPathComponent.capturedGroups(withRegex: "__([\\w\\d_]+).[pdfPDF]{3}$") {
            // parse the tags of a document
            tagNames = raw[0].components(separatedBy: "_")
        }

        if let date = date,
            let specification = specification,
            let tagNames = tagNames {

            return (date, specification, tagNames)
        } else {
            return nil
        }
    }
}

extension Document: Hashable, Comparable, CustomStringConvertible {
    public static func < (lhs: Document, rhs: Document) -> Bool {

        // first: sort by date
        // second: sort by filename
        if lhs.date != rhs.date {
            return lhs.date < rhs.date
        } else {
            return lhs.filename > rhs.filename
        }
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
