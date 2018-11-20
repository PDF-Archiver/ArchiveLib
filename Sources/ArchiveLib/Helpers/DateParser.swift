//
//  DateParser.swift
//  ArchiveLib
//
//  Created by Julian Kahnert on 20.11.18.
//

import Foundation

struct DateParser {
    var formats = [
        "yyyy-MM-dd": "\\d{4}-\\d{2}-\\d{2}",
        "yyyy_MM_dd": "\\d{4}_\\d{2}_\\d{2}",
        "yyyyMMdd": "\\d{8}"
    ]
    let dateFormatter = DateFormatter()

    func parse(_ dateIn: String) -> (date: Date, rawDate: String)? {
        for format in formats {
            if var dateRaw = dateIn.capturedGroups(withRegex: "(\(format.value))") {
                self.dateFormatter.dateFormat = format.key
                if let date = self.dateFormatter.date(from: String(dateRaw[0])) {
                    return (date, String(dateRaw[0]))
                }
            }
        }

        return nil
    }
}
