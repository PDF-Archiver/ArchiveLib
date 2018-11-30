//
//  DateParser.swift
//  ArchiveLib
//
//  Created by Julian Kahnert on 20.11.18.
//

import Foundation

/// Parse several kinds of dates in a String.
public enum DateParser {
    private static var formats = [
        "yyyy-MM-dd": "\\d{4}-\\d{2}-\\d{2}",
        "yyyy_MM_dd": "\\d{4}_\\d{2}_\\d{2}",
        "yyyyMMdd": "\\d{8}"
    ]
    private static let dateFormatter = DateFormatter()

    /// Get the first date from a raw string.
    ///
    /// - Parameter raw: Raw string which might contain a date.
    /// - Returns: The found date or nil if no date was found.
    public static func parse(_ raw: String) -> (date: Date, rawDate: String)? {
        for format in formats {
            if var rawDates = raw.capturedGroups(withRegex: ".*(\(format.value)).*") {
                self.dateFormatter.dateFormat = format.key
                if let date = self.dateFormatter.date(from: String(rawDates[0])) {
                    return (date, String(rawDates[0]))
                }
            }
        }
        return nil
    }
}
