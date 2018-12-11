//
//  UntaggedDocumentManager.swift
//  ArchiveLib-iOS
//
//  Created by Julian Kahnert on 11.12.18.
//

import Foundation

public enum ArchiveStatus: Equatable {
    case tagged
    case untagged
}

protocol DocumentManagerHandling {
    var years: Set<String> { get }

    func get(scope: SearchScope, searchterms: [String], status: ArchiveStatus) -> Set<Document>
    func add(from path: URL, size: Int64?, downloadStatus: DownloadStatus, status: ArchiveStatus)
    func remove(_ removableDocuments: Set<Document>, status: ArchiveStatus)
    func update(_ document: Document, status: ArchiveStatus)
    func update(from path: URL, size: Int64?, downloadStatus: DownloadStatus, status: ArchiveStatus) -> Document
    func archive(_ document: Document)
}

class DocumentManager: Logging {

    var documents = Set<Document>()

    func add(_ addedDocuments: Set<Document>) {
        documents.formUnion(addedDocuments)
    }

    func remove(_ removableDocuments: Set<Document>) {
        documents.subtract(removableDocuments)
    }

    func update(_ updatedDocument: Document) {
        documents.update(with: updatedDocument)
    }
}

extension DocumentManager: Searcher {
    typealias Element = Document

    var allSearchElements: Set<Document> {
        return documents
    }
}

enum DocumentManagerError: Error {
    case archivableDocumentNotFound
}
