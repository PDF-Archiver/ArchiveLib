//
//  Logging.swift
//  ArchiveLib
//
//  Created by Julian Kahnert on 13.11.18.
//

import Foundation
import os.log

protocol Logging {
    var log: OSLog { get }
}

extension Logging {
    internal var log: OSLog {
        return OSLog(subsystem: Bundle.main.bundleIdentifier ?? "ArchiveLib",
                     category: String(describing: type(of: self)))
    }
}
