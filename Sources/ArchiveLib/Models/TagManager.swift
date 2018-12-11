//
//  TagManager.swift
//  PDFArchiver
//
//  Created by Julian Kahnert on 02.12.18.
//  Copyright © 2018 Julian Kahnert. All rights reserved.
//

import Foundation

protocol TagManagerHandling {
    func getAvailableTags(with searchterms: [String]) -> Set<Tag>
    func remove(_ name: String)
    func add(_ name: String) -> Tag
}

class TagManager {

    var availableTags = Set<Tag>()

    func getAvailableTags(with searchterms: [String]) -> Set<Tag> {
        // TODO: add search implementation here
        return availableTags
    }

    func remove(_ name: String) {
        if let availableTag = availableTags.first(where: { $0.name == name }) {
            availableTag.count -= 1
            availableTags.update(with: availableTag)
        }
    }

    func add(_ name: String) -> Tag {
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
