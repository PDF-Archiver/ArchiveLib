//
//  Document.swift
//  ArchiveLib
//
//  Created by Julian Kahnert on 13.11.18.
//

import Foundation
import os.log

enum DownloadStatus: Equatable {
    case iCloudDrive
    case downloading(percentDownloaded: Float)
    case local
}

struct Document: Logging {

    // data from filename
    private(set) var date: Date
    private(set) var specification: String
    private(set) var specificationCapitalized: String
    private(set) var tags = Set<Tag>()

    private(set) var folder: String
    private(set) var filename: String
    private(set) var path: URL

    private(set) var size: String?
    var downloadStatus: DownloadStatus?

    init(path documentPath: URL, availableTags: inout Set<Tag>, size byteSize: Int64?, downloadStatus documentDownloadStatus: DownloadStatus?) {

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
        date = parsedFilename.date ?? Date()

        // get the available tags of the archive
        for documentTagName in parsedFilename.tagNames ?? [] {
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
        specification = parsedFilename.specification ?? ""
        specificationCapitalized = specification
            .split(separator: "-")
            .map { String($0).capitalizingFirstLetter() }
            .joined(separator: " ")
    }

    mutating func download() {
        do {
            try FileManager.default.startDownloadingUbiquitousItem(at: path)
            downloadStatus = .downloading(percentDownloaded: 0)
        } catch {
            os_log("%s", log: log, type: .debug, error.localizedDescription)
        }
    }

    static func parseFilename(_ path: URL) -> (date: Date?, specification: String?, tagNames: [String]?) {

        // try to parse the current filename
        let parser = DateParser()
        var date: Date?
        var rawDate = ""
        if let parsed = parser.parse(path.lastPathComponent) {
            date = parsed.date
            rawDate = parsed.rawDate
        }

        // save a first "raw" specification
        var specification = path.lastPathComponent
            // drop the already parsed date
            .dropFirst(rawDate.count)
            // drop the extension and the last .
            .dropLast(path.pathExtension.count + 1)
            // exclude tags, if they exist
            .components(separatedBy: "__")[0]
            // clean up all "_" - they are for tag use only!
            .replacingOccurrences(of: "_", with: "-")
            // remove a pre or suffix from the string
            .slugifyPreSuffix()

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

        return (date, specification, tagNames)
    }
}

// MARK: - Extensions -

extension Document: Hashable, Comparable, CustomStringConvertible {
    static func < (lhs: Document, rhs: Document) -> Bool {

        // first: sort by date
        // second: sort by filename
        if lhs.date != rhs.date {
            return lhs.date < rhs.date
        } else {
            return lhs.filename > rhs.filename
        }
    }
    static func == (lhs: Document, rhs: Document) -> Bool {
        // "==" and hashValue must only compare the path to avoid duplicates in sets
        return lhs.path == rhs.path
    }
    // "==" and hashValue must only compare the path to avoid duplicates in sets
    var hashValue: Int { return path.hashValue }

    var description: String { return filename }
}

extension Document: Searchable {

    // Searchable stubs
    internal var searchTerm: String { return filename }
}
