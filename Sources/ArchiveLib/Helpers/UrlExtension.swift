//
//  UrlExtension.swift
//  ArchiveLib
//
//  Created by Julian Kahnert on 02.12.18.
//

import Foundation

public extension URL {

    public func hasParent(_ parent: URL?) -> Bool {
        if let parent = parent {
            return self.path.hasPrefix(parent.path)
        } else {
            return false
        }
    }
}
