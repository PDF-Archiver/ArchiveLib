//
//  SortDescriptors.swift
//  ArchiveLib
//
//  Created by Julian Kahnert on 17.12.18.
//
// Source from: http://chris.eidhof.nl/post/sort-descriptors-in-swift/
//

import Foundation

public typealias SortDescriptor<Value> = (Value, Value) -> Bool

public func sortDescriptor<Value, Key>(key: @escaping (Value) -> Key, ascending: Bool) -> SortDescriptor<Value> where Key: Comparable {
    return { ascending ? key($0) < key($1) : key($0) > key($1) }
}

public func combine<Value>(sortDescriptors: [SortDescriptor<Value>]) -> SortDescriptor<Value> {
    return { lhs, rhs in
        for isOrderedBefore in sortDescriptors {
            if isOrderedBefore(lhs, rhs) { return true }
            if isOrderedBefore(rhs, lhs) { return false }
        }
        return false
    }
}

// TODO: generalize this
//public func createSortDescriptors<Tag, Key>(sortDescriptors: [NSSortDescriptor], mapping: (String) -> ((Tag) -> Key)) -> SortDescriptor<Tag> where Key: Comparable {
//
//    // create the swifty sort descriptors
//    var swiftySortDescriptors = [SortDescriptor<Tag>]()
//    for tagSortDescriptor in sortDescriptors {
//        guard let key = tagSortDescriptor.key else { continue }
//
//        let map = mapping(key)
//
//        if key == "name" {
//
//            let sortByName: SortDescriptor<Tag> = sortDescriptor(key: map, ascending: tagSortDescriptor.ascending)
//            swiftySortDescriptors.append(sortByName)
//        } else if key == "count" {
//
//            let sortByCount: SortDescriptor<Tag> = sortDescriptor(key: map, ascending: tagSortDescriptor.ascending)
//            swiftySortDescriptors.append(sortByCount)
//        }
//    }
//
//    // combine the swifty sort dscriptors
//    return combine(sortDescriptors: swiftySortDescriptors)
//}
