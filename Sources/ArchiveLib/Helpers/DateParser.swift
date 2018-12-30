//
//  DateParser.swift
//  ArchiveLib
//
//  Created by Julian Kahnert on 20.11.18.
//

import Foundation

/// Parse several kinds of dates in a String.
public enum DateParser {

    private enum Regex: String {
        case year = "((19|20)\\d{2})"
        case month = "(0[1-9]{1}|10|11|12)"
        case day = "(0[1-9]{1}|[12]{1}\\d|3[01]{1})"
    }
    private typealias FormatMapping = (format: String, regex: String)

    private static let dateFormatter = DateFormatter()

    // TODO: this might be refactored
    private static var mappings: [FormatMapping] = [
        (format: "dd.MM.yyyy", regex: "\(Regex.day.rawValue)\\.\(Regex.month.rawValue)\\.\(Regex.year.rawValue)"),
        (format: "dd-MM-yyyy", regex: "\(Regex.day.rawValue)-\(Regex.month.rawValue)-\(Regex.year.rawValue)"),
        (format: "dd/MM/yyyy", regex: "\(Regex.day.rawValue)/\(Regex.month.rawValue)/\(Regex.year.rawValue)"),
        (format: "dd MM yyyy", regex: "\(Regex.day.rawValue)\\s\(Regex.month.rawValue)\\s\(Regex.year.rawValue)"),
        (format: "ddMMyyyy", regex: "\(Regex.day.rawValue)\(Regex.day.rawValue)\(Regex.year.rawValue)"),
        (format: "yyyy-MM-dd", regex: "\(Regex.year.rawValue)-\(Regex.month.rawValue)-\(Regex.day.rawValue)"),
        (format: "yyyy_MM_dd", regex: "\(Regex.year.rawValue)_\(Regex.month.rawValue)_\(Regex.day.rawValue)"),
        (format: "yyyyMMdd", regex: "\(Regex.year.rawValue)\(Regex.month.rawValue)\(Regex.day.rawValue)")
    ]

    /// Get the first date from a raw string.
    ///
    /// - Parameter raw: Raw string which might contain a date.
    /// - Returns: The found date or nil if no date was found.
    public static func parse(_ raw: String) -> (date: Date, rawDate: String)? {
        for mapping in mappings {
            if var rawDates = raw.capturedGroups(withRegex: "[\\D]*(\(mapping.regex))([\\D]+|$)") {
                dateFormatter.dateFormat = mapping.format
                if let date = dateFormatter.date(from: String(rawDates[0])) {
                    return (date, String(rawDates[0]))
                }
            }
        }
        return nil
    }
}
