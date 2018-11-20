//
//  Tag.swift
//  ArchiveLib
//
//  Created by Julian Kahnert on 13.11.18.
//

import Foundation

/// Structure which represents a Tag.
public struct Tag {

    /// Name of the tag.
    public let name: String

    /// Count of how many tags with this name exist.
    public var count: Int
}

extension Tag: Hashable, CustomStringConvertible {
    public static func == (lhs: Tag, rhs: Tag) -> Bool {
        return lhs.name == rhs.name
    }
    public var description: String { return "\(name) (\(count))" }
    public var hashValue: Int { return name.hashValue }
}
