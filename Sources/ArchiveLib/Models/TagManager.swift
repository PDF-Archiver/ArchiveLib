//
//  TagManager.swift
//  PDFArchiver
//
//  Created by Julian Kahnert on 02.12.18.
//  Copyright © 2019 Julian Kahnert. All rights reserved.
//

import Foundation

public protocol TagManagerHandling: AnyObject {
    func getAvailableTags(with searchterms: [String]) -> Set<Tag>
    func removeTag(_ name: String)
    func add(_ name: String, count: Int) -> Tag
}

class TagManager {

    private var availableTags = Atomic(Set<Tag>())

    func getAvailableTags(with searchterms: [String]) -> Set<Tag> {
        if searchterms.joined().isEmpty {
            return availableTags.value
        } else {
            return filterBy(searchterms)
        }
    }

    func remove(_ name: String) {
        if let availableTag = availableTags.value.first(where: { $0.name == name }) {
            if availableTag.count <= 1 {
                availableTags.mutate { $0.subtract(Set([availableTag])) }
            } else {
                availableTag.count -= 1
                availableTags.mutate { $0.update(with: availableTag) }
            }
        }
    }

    func add(_ name: String, count: Int = 1) -> Tag {
        if let availableTag = availableTags.value.first(where: { $0.name == name }) {
            availableTag.count += count
            availableTags.mutate { $0.update(with: availableTag) }
            return availableTag
        } else {
            let newTag = Tag(name: name, count: count)
            availableTags.mutate { $0.insert(newTag) }
            return newTag
        }
    }
}

extension TagManager: Searcher {

    typealias Element = Tag

    var allSearchElements: Set<Tag> {
        return availableTags.value
    }
}
