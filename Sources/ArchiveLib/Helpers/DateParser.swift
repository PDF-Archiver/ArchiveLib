//
//  DateParser.swift
//  ArchiveLib
//
//  Created by Julian Kahnert on 20.11.18.
//

import Foundation

/// Parse several kinds of dates in a String.
public enum DateParser {

    private typealias FormatMapping = (format: String, regex: String, locale: Locale?)
    private typealias DateOrder = (first: Parts, second: Parts, third: Parts)
    private enum Parts {
        case year
        case month
        case day
    }

    private static let dateOrders: [DateOrder] = [
        (first: .day, second: .month, third: .year),
        (first: .year, second: .month, third: .day),
        (first: .year, second: .day, third: .month),
        (first: .month, second: .day, third: .year)
    ]
    private static let separator = "[\\.\\-\\_\\s\\/,]{0,3}"
    private static var mappings: [FormatMapping] {
        return createMappings(for: locales)
    }
    private static let locales = [Locale(identifier: "de_DE"), Locale(identifier: "en_US")]

    // MARK: - public API

    /// Get the first date from a raw string.
    ///
    /// - Parameter raw: Raw string which might contain a date.
    /// - Returns: The found date or nil if no date was found.
    public static func parse(_ raw: String) -> (date: Date, rawDate: String)? {
        return parse(raw, with: mappings)
    }

    /// Get the first date from a raw string for some given locales. This will generate new temporary mappings.
    ///
    /// - Parameters:
    /// - Parameter raw: Raw string which might contain a date.
    ///   - locales: Array which defines the order of locales that should be used for parsing.
    /// - Returns: The found date or nil if no date was found.
    public static func parse(_ raw: String, locales: [Locale]) -> (date: Date, rawDate: String)? {
        let mappings = createMappings(for: locales)
        return parse(raw, with: mappings)
    }

    // MARK: - internal date parser

    private static func parse(_ raw: String, with mappings: [FormatMapping]) -> (date: Date, rawDate: String)? {

        // create a date parser
        let dateFormatter = DateFormatter()

        // only compare lowercased dates
        let lowercasedRaw = raw.lowercased()

        for mapping in mappings {
            if var rawDates = lowercasedRaw.capturedGroups(withRegex: "[\\D]*(\(mapping.regex))([\\D]+|$)") {

                // cleanup all separators from the found string
                let foundString = String(rawDates[0])
                    .replacingOccurrences(of: separator, with: "", options: .regularExpression)
                    .lowercased()

                // setup the right format in the dateFormatter
                dateFormatter.dateFormat = mapping.format
                if let locale = mapping.locale {
                    dateFormatter.locale = locale
                }

                // try to parse the found raw string
                if let date = dateFormatter.date(from: foundString) {
                    return (date, String(rawDates[0]))
                }
            }
        }
        return nil
    }

    // MARK: - helper functions

    private static func createMappings(for locales: [Locale]) -> [FormatMapping] {

        var monthMappings = [FormatMapping]()
        monthMappings.append((regex: "(0[1-9]{1}|10|11|12)", format: "MM", locale: Locale(identifier: "en_US")))

        let dateFormatter = DateFormatter()
        let otherMonthFormats = ["MMM", "MMMM"]
        for locale in locales {

            // use all month formats, e.g. "Jan." and "January"
            for otherMonthFormat in otherMonthFormats {
                var months = [String]()
                for month in 1...12 {
                    dateFormatter.dateFormat = "MM"
                    guard let date = dateFormatter.date(from: "\(month)") else { continue }

                    dateFormatter.locale = locale
                    dateFormatter.dateFormat = otherMonthFormat
                    months.append(dateFormatter.string(from: date).lowercased().replacingOccurrences(of: ".", with: ""))
                }
                monthMappings.append((regex: "(\(months.joined(separator: "|")))", format: otherMonthFormat, locale: locale))
            }
        }

        // real mapping
        var mappings = [(FormatMapping)]()
        for dateOrder in dateOrders {

            // create the cartesian product of all datepart variantes (e.g. yy or yyyy)
            let prod1 = product(part2mapping(dateOrder.first, monthMappings: monthMappings),
                                part2mapping(dateOrder.second, monthMappings: monthMappings))
            let prod2 = product(prod1,
                                part2mapping(dateOrder.third, monthMappings: monthMappings))

            // create the regular expressions and format for all products
            for row in prod2 {
                let element1 = row.0.0
                let element2 = row.0.1
                let element3 = row.1

                let regex = [element1.regex, element2.regex, element3.regex].joined(separator: separator)
                let format = element1.format + element2.format + element3.format
                let locale = [element1.locale, element2.locale, element3.locale].compactMap { $0 } .first

                mappings.append((format: format, regex: regex, locale: locale))
            }
        }

        return mappings
    }

    private static func part2mapping(_ part: Parts, monthMappings: [FormatMapping]) -> [FormatMapping] {
        switch part {
        case .day:
            return [(regex: "(0{0,1}[1-9]{1}|[12]{1}\\d|3[01]{1})", format: "dd", locale: nil)]
        case .month:
            return monthMappings
        case .year:
            return [(regex: "((19|20)\\d{2})", format: "yyyy", locale: nil)]
        }
    }

    // Source: http://www.figure.ink/blog/2017/7/30/lazy-permutations-in-swift
    // swiftlint:disable identifier_name
    private static func product<X, Y>(_ xs: X, _ ys: Y) -> [(X.Element, Y.Element)] where X: Collection, Y: Collection {
        var orderedPairs: [(X.Element, Y.Element)] = []
        for x in xs {
            for y in ys {
                orderedPairs.append((x, y))
            }
        }
        return orderedPairs
    }
}
