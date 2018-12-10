//
//  Archive.swift
//  ArchiveLib
//
//  Created by Julian Kahnert on 09.12.18.
//

import Foundation

public protocol DocumentManagerDelegate {
    func getUntaggedDocuments() -> Set<Document>
    func createAndAddUntaggedDocuments(from path: URL, downloadStatus: DownloadStatus)
    func addUntaggedDocuments(_ newDocuments: Set<Document>)
    func removeUntaggedDocuments(_ removableDocuments: Set<Document>)
    func getArchivedDocuments(with searchterms: [String]) -> Set<Document>
    func createAndAddArchivedDocuments(from path: URL, downloadStatus: DownloadStatus)
    func addArchivedDocuments(_ newDocuments: Set<Document>)
    func removeArchivedDocuments(_ removableDocuments: Set<Document>)
}

public class DocumentManager: Logging {

    private var untaggedDocuments = Set<Document>()
    private var archivedDocuments = Set<Document>()

    private var tagManager = TagManager()

    init(manager: TagManager) {
        tagManager = manager
    }

    // - MARK: untagged document changes

    public func getUntaggedDocuments() -> Set<Document> {
        return untaggedDocuments
    }

    public func createAndAddUntaggedDocuments(from path: URL, downloadStatus: DownloadStatus = .local) {
        // TODO: get the real size of the document here
        let newDocument = Document(path: path, tagManager: tagManager, size: nil, downloadStatus: downloadStatus)
        untaggedDocuments.insert(newDocument)
    }

    public func addUntaggedDocuments(_ newDocuments: Set<Document>) {
        untaggedDocuments.formIntersection(newDocuments)
    }

    public func removeUntaggedDocuments(_ removableDocuments: Set<Document>) {
        untaggedDocuments.subtract(removableDocuments)
    }

    // - MARK: untagged document changes

    public func getArchivedDocuments(with searchterms: [String]) -> Set<Document> {
        return archivedDocuments
    }

    public func createAndAddArchivedDocuments(from path: URL, downloadStatus: DownloadStatus = .local) {
        let newDocument = Document(path: path, tagManager: tagManager, size: nil, downloadStatus: downloadStatus)
        archivedDocuments.insert(newDocument)
    }

    public func addArchivedDocuments(_ newDocuments: Set<Document>) {
        archivedDocuments.formIntersection(newDocuments)
    }

    public func removeArchivedDocuments(_ removableDocuments: Set<Document>) {
        archivedDocuments.subtract(removableDocuments)
        for document in removableDocuments {
            tagManager.remove(document.tags)
        }
    }
}
