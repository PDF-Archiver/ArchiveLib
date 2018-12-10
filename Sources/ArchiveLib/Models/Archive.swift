//
//  Archive.swift
//  ArchiveLib
//
//  Created by Julian Kahnert on 09.12.18.
//

import Foundation

public enum Content: Equatable {
    case tags
    case untaggedDocuments
    case archivedDocuments
}

protocol ArchiveDelegate: class {
    func update(_ document: Document, at: URL)
}

public class Archive {

    public let documentManager: DocumentManager
    public let tagManager: TagManager

    public init() {
        tagManager = TagManager()
        documentManager = DocumentManager(manager: tagManager)
    }

}
