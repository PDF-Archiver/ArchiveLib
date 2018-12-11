//
//  Archive.swift
//  ArchiveLib
//
//  Created by Julian Kahnert on 09.12.18.
//

import Foundation

public protocol ArchiveDelegate: class {
    func update(_ contentType: ContentType)
}

public class Archive: TagManagerHandling, DocumentManagerHandling {

    public weak var archiveDelegate: ArchiveDelegate?

    private let taggedDocumentManager = DocumentManager()
    private let untaggedDocumentManager = DocumentManager()
    private let tagManager = TagManager()

    public init() {}

    // MARK: - TagManagerHandling implementation
    public func getAvailableTags(with searchterms: [String]) -> Set<Tag> {
        return tagManager.getAvailableTags(with: searchterms)
    }

    public func remove(_ name: String) {
        tagManager.remove(name)
    }

    public func add(_ name: String) -> Tag {
        return tagManager.add(name)
    }

    // MARK: - TagManagerHandling implementation
    public var years: Set<String> {
        var years = Set<String>()
        for document in taggedDocumentManager.documents {
            years.insert(document.folder)
        }
        return years
    }

    public func get(scope: SearchScope, searchterms: [String], status: ArchiveStatus) -> Set<Document> {

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

    public func add(from path: URL, size: Int64?, downloadStatus: DownloadStatus, status: ArchiveStatus) {
        let newDocument = Document(path: path, tagManager: tagManager, size: size, downloadStatus: downloadStatus)
        switch status {
        case .tagged:
            return taggedDocumentManager.add(Set([newDocument]))
        case .untagged:
            return untaggedDocumentManager.add(Set([newDocument]))
        }
    }

    public func remove(_ removableDocuments: Set<Document>, status: ArchiveStatus) {
        switch status {
        case .tagged:
            return taggedDocumentManager.remove(removableDocuments)
        case .untagged:
            return untaggedDocumentManager.remove(removableDocuments)
        }
    }

    public func update(_ document: Document, status: ArchiveStatus) {
        switch status {
        case .tagged:
            return taggedDocumentManager.update(document)
        case .untagged:
            return untaggedDocumentManager.update(document)
        }
    }

    public func archive(_ document: Document) {
        untaggedDocumentManager.remove(Set([document]))
        taggedDocumentManager.add(Set([document]))
    }

    public func update(from path: URL, size: Int64?, downloadStatus: DownloadStatus, status: ArchiveStatus) -> Document {
        let updatedDocument = Document(path: path, tagManager: tagManager, size: size, downloadStatus: downloadStatus)
        switch status {
        case .tagged:
            taggedDocumentManager.update(updatedDocument)
        case .untagged:
            untaggedDocumentManager.update(updatedDocument)
        }
        return updatedDocument
    }
}

public enum ContentType: Equatable {
    case tags
    case untaggedDocuments
    case archivedDocuments(updatedDocuments: Set<Document>)
}
