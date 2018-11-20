//
//  Logging.swift
//  ArchiveLib
//
//  Created by Julian Kahnert on 13.11.18.
//

import Foundation
import os.log

/// Logging protocel
public protocol Logging {

    /// Property that should be used for generating logs.
    var log: OSLog { get }
}

extension Logging {

    /// Getting an OSLog instance for logging.
    public var log: OSLog {
        return OSLog(subsystem: Bundle.main.bundleIdentifier ?? "ArchiveLib",
                     category: String(describing: type(of: self)))
    }
}
