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
    private(set) var size: String

    var downloadStatus: DownloadStatus

    init(path documentPath: URL, size byteSize: Int64, downloadStatus documentDownloadStatus: DownloadStatus, availableTags: inout Set<Tag>) {

        path = documentPath
        size = ByteCountFormatter.string(fromByteCount: byteSize, countStyle: .file)
        downloadStatus = documentDownloadStatus
        filename = documentPath.lastPathComponent
        folder = documentPath.deletingLastPathComponent().lastPathComponent

        guard let parts = Document.parseFilename(filename) else { fatalError("Could not parse document filename!") }

        // parse the document date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        guard let documentDate = dateFormatter.date(from: parts[0]) else { fatalError("Could not parse the document date!") }
        date = documentDate

        // parse the document specification
        specification = parts[1]
        specificationCapitalized = specification
            .split(separator: "-")
            .map { String($0).capitalizingFirstLetter() }
            .joined(separator: " ")

        // parse the document tags
        for tagname in parts[2].split(separator: "_") {

            if var availableTag = availableTags.first(where: { $0.name == String(tagname) }) {
                availableTag.count += 1
                tags.insert(availableTag)
            } else {
                let newTag = Tag(name: String(tagname), count: 1)
                availableTags.insert(newTag)
                tags.insert(newTag)
            }
        }
    }

    mutating func download() {
        do {
            try FileManager.default.startDownloadingUbiquitousItem(at: path)
            downloadStatus = .downloading(percentDownloaded: 0)
        } catch {
            os_log("%s", log: log, type: .debug, error.localizedDescription)
        }
    }

    static func parseFilename(_ filename: String) -> [String]? {
        return filename.capturedGroups(withRegex: "(\\d{4}-\\d{2}-\\d{2})--(.+)__([\\w\\d_]+)\\.[pdfPDF]{3}$")
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
