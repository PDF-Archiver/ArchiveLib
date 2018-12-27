//
//  TagManager.swift
//  PDFArchiver
//
//  Created by Julian Kahnert on 02.12.18.
//  Copyright © 2018 Julian Kahnert. All rights reserved.
//

import Foundation

public protocol TagManagerHandling: AnyObject {
    func getAvailableTags(with searchterms: [String]) -> Set<Tag>
    func remove(_ name: String)
    func add(_ name: String, count: Int) -> Tag
}

class TagManager {

    var availableTags = Set<Tag>()

    func getAvailableTags(with searchterms: [String]) -> Set<Tag> {
        if searchterms.joined().isEmpty {
            return availableTags
        } else {
            return filterBy(searchterms)
        }
    }

    func remove(_ name: String) {
        if let availableTag = availableTags.first(where: { $0.name == name }) {
            if availableTag.count <= 1 {
                availableTags.subtract(Set([availableTag]))
            } else {
                availableTag.count -= 1
                availableTags.update(with: availableTag)
            }
        }
    }

    func add(_ name: String, count: Int = 1) -> Tag {
        if let availableTag = availableTags.first(where: { $0.name == name }) {
            availableTag.count += count
            availableTags.update(with: availableTag)
            return availableTag
        } else {
            let newTag = Tag(name: name, count: count)
            availableTags.insert(newTag)
            return newTag
        }
    }
}

extension TagManager: Searcher {

    typealias Element = Tag

    var allSearchElements: Set<Tag> {
        return availableTags
    }
}
