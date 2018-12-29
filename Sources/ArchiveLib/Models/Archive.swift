//
//  Archive.swift
//  ArchiveLib
//
//  Created by Julian Kahnert on 09.12.18.
//

import Foundation
import os.log

public class Archive: TagManagerHandling, DocumentManagerHandling, Logging {

    private let taggedDocumentManager = DocumentManager()
    private let untaggedDocumentManager = DocumentManager()
    private let tagManager = TagManager()

    public init() {}

    // MARK: - TagManagerHandling implementation
    public func getAvailableTags(with searchterms: [String]) -> Set<Tag> {
        return tagManager.getAvailableTags(with: searchterms)
    }

    public func removeTag(_ name: String) {
        tagManager.remove(name)
    }

    public func add(_ name: String, count: Int = 1) -> Tag {
        return tagManager.add(name, count: count)
    }

    // MARK: - DocumentHandling implementation
    public var years: Set<String> {
        var years = Set<String>()
        for document in taggedDocumentManager.documents {
            years.insert(document.folder)
        }
        return years
    }

    public func get(scope: SearchScope, searchterms: [String], status: TaggingStatus) -> Set<Document> {

        let documentManager: DocumentManager
        switch status {
        case .tagged:
            documentManager = taggedDocumentManager
        case .untagged:
            documentManager = untaggedDocumentManager
        }

        // filter by scope
        let scopeFilteredDocuments: Set<Document>
        switch scope {
        case .all:
            scopeFilteredDocuments = documentManager.allSearchElements
        case .year(let year):
            scopeFilteredDocuments = documentManager.allSearchElements.filter { $0.folder == year }
        }

        // filter by search terms
        let termFilteredDocuments = documentManager.filterBy(searchterms)

        return scopeFilteredDocuments.intersection(termFilteredDocuments)
    }

    public func add(from path: URL, size: Int64?, downloadStatus: DownloadStatus, status: TaggingStatus, parse parsingOptions: ParsingOptions = []) {
        let newDocument = Document(path: path, tagManager: tagManager, size: size, downloadStatus: downloadStatus, taggingStatus: status)
        switch status {
        case .tagged:
            taggedDocumentManager.add(newDocument)
        case .untagged:

            if !parsingOptions.isEmpty {

                // parse the document content, which might updates the date and tags
                if parsingOptions.contains(.mainThread) {
                    newDocument.parseContent(parsingOptions)
                } else {
                    DispatchQueue.global(qos: .userInitiated).async {
                        newDocument.parseContent(parsingOptions)
                    }
                }
            }

            // add the document to the untagged documents
            untaggedDocumentManager.add(newDocument)
        }
    }

    public func remove(_ removableDocuments: Set<Document>) {

        // remove tags
        for document in removableDocuments {
            for tag in document.tags {
                tagManager.remove(tag.name)
            }
        }

        // remove documents
        for document in removableDocuments {
            switch document.taggingStatus {
            case .tagged:
                taggedDocumentManager.remove(document)
            case .untagged:
                untaggedDocumentManager.remove(document)
            }
        }
    }

    public func removeAll(_ status: TaggingStatus) {

        // get the right document manager
        let documentManager: DocumentManager
        switch status {
        case .tagged:
            documentManager = taggedDocumentManager
        case .untagged:
            documentManager = untaggedDocumentManager
        }

        // remove the documents
        let allRemovableDocuments = documentManager.documents
        remove(allRemovableDocuments)
    }

    public func update(_ document: Document) {
        switch document.taggingStatus {
        case .tagged:
            taggedDocumentManager.update(document)
        case .untagged:
            untaggedDocumentManager.update(document)
        }
    }

    public func archive(_ document: Document) {
        untaggedDocumentManager.remove(document)
        taggedDocumentManager.add(document)
    }

    public func update(from path: URL, size: Int64?, downloadStatus: DownloadStatus, status: TaggingStatus, parse parsingOptions: ParsingOptions = []) -> Document {
        let updatedDocument = Document(path: path, tagManager: tagManager, size: size, downloadStatus: downloadStatus, taggingStatus: status)
        switch status {
        case .tagged:
            taggedDocumentManager.update(updatedDocument)
        case .untagged:

            if !parsingOptions.isEmpty {
                // parse the document content, which might updates the date and tags
                DispatchQueue.global(qos: .userInitiated).async {
                    updatedDocument.parseContent(parsingOptions)
                }
            }

            // add the document to the untagged documents
            untaggedDocumentManager.update(updatedDocument)
        }
        return updatedDocument
    }

    // MARK: - DocumentTagHandling implementation
    public func add(tag: String, to document: Document) {

        // test if tag already exists in document tags
        if document.tags.filter({ $0.name == tag }).isEmpty {

            // tag count update
            let newTag = add(tag)

            // add the new tag
            document.tags.insert(newTag)

            switch document.taggingStatus {
            case .tagged:
                taggedDocumentManager.update(document)
            case .untagged:
                untaggedDocumentManager.update(document)
            }
        }
    }
}

public enum ContentType: Equatable {
    case tags
    case untaggedDocuments
    case archivedDocuments(updatedDocuments: Set<Document>)
}

public struct ParsingOptions: OptionSet {
    public let rawValue: Int

    public static let date = ParsingOptions(rawValue: 1 << 0)
    public static let tags = ParsingOptions(rawValue: 1 << 1)

    public static let mainThread = ParsingOptions(rawValue: 1 << 2)

    public static let all: ParsingOptions = [.date, .tags]

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
}
