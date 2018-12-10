//
//  TagManager.swift
//  PDFArchiver
//
//  Created by Julian Kahnert on 02.12.18.
//  Copyright © 2018 Julian Kahnert. All rights reserved.
//

import Foundation

public protocol TagManagerDelegate {
    func getAvailableTags(with searchterms: [String]) -> Set<Tag>
    func add(_ newTags: Set<Tag>)
    func remove(_ removableTags: Set<Tag>)
    func add(_ name: String) -> Tag
}

public class TagManager {

    private var availableTags = Set<Tag>()

    // - MARK: tags
    public func getAvailableTags(with searchterms: [String]) -> Set<Tag> {
        // TODO: add search implementation here
        return availableTags
    }

    public func add(_ newTags: Set<Tag>) {
        availableTags.formIntersection(newTags)
    }

    public func remove(_ removableTags: Set<Tag>) {
        availableTags.subtract(removableTags)
    }

    public func add(_ name: String) -> Tag {
        if let availableTag = availableTags.first(where: { $0.name == name }) {
            availableTag.count += 1
            availableTags.update(with: availableTag)
            return availableTag
        } else {
            let newTag = Tag(name: name, count: 1)
            availableTags.insert(newTag)
            return newTag
        }
    }
}
