//
//  File.swift
//  
//
//  Created by Julian Kahnert on 29.11.19.
//

import Foundation

// Source Code from: https://github.com/amyspark/xattr
extension URL {

    private static let itemUserTagsName = "com.apple.metadata:_kMDItemUserTags"

    public var fileTags: [String] {
        get {
            // prefer native tagNames and 
            #if os(OSX)
            // https://stackoverflow.com/a/47340666
            let resourceValues = try? self.resourceValues(forKeys: [.tagNamesKey])
            return resourceValues?.tagNames ?? []
            #else
            return getFileTags()
            #endif
        }
        set {
            #if os(OSX)
            // https://stackoverflow.com/a/47340666
            try? (self as NSURL).setResourceValue(newValue, forKey: URLResourceKey.tagNamesKey)
            #else
            setFileTags(newValue)
            #endif
        }
    }

    private func getFileTags() -> [String] {
        guard let data = try? self.getExtendedAttribute(forName: URL.itemUserTagsName),
            let tagPlist = try? PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? [String] else { return [] }

        return tagPlist.map { tag -> String in
            var newTag = tag
            newTag.removeLast(2)
            return newTag
        }
    }

    private func setFileTags(_ fileTags: [String]) {
        guard let data = try? PropertyListEncoder().encode(fileTags) else { return }
        try? setExtendedAttribute(data: data, forName: URL.itemUserTagsName)
    }

    /// Get extended attribute.
    private func getExtendedAttribute(forName name: String, follow: Bool = false) throws -> Data {
        var options: Int32 = 0
        if (!follow) {
            options = options | XATTR_NOFOLLOW
        }
        let data = try self.withUnsafeFileSystemRepresentation { fileSystemPath -> Data in
            // Determine attribute size:
            let length = getxattr(fileSystemPath, name, nil, 0, 0, options)
            guard length >= 0 else { throw URL.posixError(errno) }

            // Create buffer with required size:
            var data = Data(count: length)

            // Retrieve attribute:
            let result =  data.withUnsafeMutableBytes { [count = data.count] in
                getxattr(fileSystemPath, name, $0.baseAddress, count, 0, 0)
            }
            guard result >= 0 else { throw URL.posixError(errno) }
            return data
        }
        return data
    }

    /// Set extended attribute.
    func setExtendedAttribute(data: Data, forName name: String, follow: Bool = false) throws {
        var options: Int32 = 0
        if (!follow) {
            options = options | XATTR_NOFOLLOW
        }
        try self.withUnsafeFileSystemRepresentation { fileSystemPath in
            let result = data.withUnsafeBytes {
                setxattr(fileSystemPath, name, $0.baseAddress, data.count, 0, options)
            }
            guard result >= 0 else { throw URL.posixError(errno) }
        }
    }

    /// Helper function to create an NSError from a Unix errno.
    private static func posixError(_ err: Int32) -> NSError {
        return NSError(domain: NSPOSIXErrorDomain, code: Int(err),
                       userInfo: [NSLocalizedDescriptionKey: String(cString: strerror(err))])
    }
}
