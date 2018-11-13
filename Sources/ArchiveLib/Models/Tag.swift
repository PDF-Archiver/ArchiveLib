//
//  Tag.swift
//  ArchiveLib
//
//  Created by Julian Kahnert on 13.11.18.
//

import Foundation

struct Tag {
    
    let name: String
    var count: Int
}

extension Tag: Hashable, CustomStringConvertible {
    static func == (lhs: Tag, rhs: Tag) -> Bool {
        return lhs.name == rhs.name
    }
    var description: String { return "\(name) (\(count))" }
    var hashValue: Int { return name.hashValue }
}
