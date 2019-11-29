//
//  File.swift
//  
//
//  Created by Julian Kahnert on 29.11.19.
//

import Foundation

func generatedTempFileURL(ext: String? = nil) -> URL {

    let fileName = generatedFileName(ext: ext)
    let fileURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(fileName)

    return fileURL
}

func generatedFileName(ext: String? = nil) -> String {

    let fileExtension: String
    if let ext = ext {
        fileExtension = ".\(ext)"
    } else {
        fileExtension = ""
    }

    return "ArchiveLib.\(UUID().uuidString)\(fileExtension)"
}

func touch(url: URL) {
    try! "".write(to: url, atomically: false, encoding: .utf8)
}
