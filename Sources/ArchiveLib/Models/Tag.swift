//
//  Tag.swift
//  ArchiveLib
//
//  Created by Julian Kahnert on 13.11.18.
//

import Foundation

/// Class which represents a Tag.
public class Tag {

    /// Name of the tag.
    public let name: String

    /// Count of how many tags with this name exist.
    public var count: Int

    /// Create a new tag.
    /// New tags should only be created by the TagManager in this package.
    ///
    /// - Parameters:
    ///   - name: Name of the Tag.
    ///   - count: Number which indicates how many times this tag is used.
    init(name: String, count: Int) {
        self.name = name
        self.count = count
    }
}

extension Tag: Hashable, Comparable, CustomStringConvertible {
    public static func < (lhs: Tag, rhs: Tag) -> Bool {
        return lhs.name < rhs.name
    }

    public static func == (lhs: Tag, rhs: Tag) -> Bool {
        return lhs.name == rhs.name
    }
    public var hashValue: Int { return name.hashValue }
    public var description: String { return "\(name) (\(count))" }
}

extension Tag: Searchable {
    public var searchTerm: String {
        return name
    }
}

extension Tag: CustomComparable {
    public func isBefore(_ other: Tag, _ sort: NSSortDescriptor) -> Bool {
        if sort.key == "name" {
            return sort.ascending ? name < other.name : name > other.name
        } else if sort.key == "count" {
            return sort.ascending ? count < other.count : count > other.count
        }
        return false
    }
}
