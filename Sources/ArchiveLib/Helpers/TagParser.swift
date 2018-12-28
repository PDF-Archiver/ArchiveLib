//
//  TagParser.swift
//  ArchiveLib
//
//  Created by Julian Kahnert on 28.12.18.
//
// Example from: https://developer.apple.com/documentation/naturallanguage/identifying_people_places_and_organizations

import Foundation
import NaturalLanguage

/// Parse tags from a String.
@available(iOSApplicationExtension 12.0, *)
@available(OSXApplicationExtension 10.14, *)
public enum TagParser {

    /// Get tag names from a string.
    ///
    /// - Parameter raw: Raw string which might contain some tags.
    /// - Returns: Found tag names.
    public static func parse(_ text: String) -> Set<String> {
        var documentTags = Set<String>()

        let tagger = NLTagger(tagSchemes: [.nameType])
        tagger.string = text
//        let options: NLTagger.Options = [.omitWords, .omitPunctuation, .omitWhitespace, .omitOther, .joinNames, .joinContractions]
        let options: NLTagger.Options = [.omitPunctuation, .omitWhitespace, .omitOther, .joinNames, .joinContractions]

        let tags: [NLTag] = [.organizationName]
        tagger.enumerateTags(in: text.startIndex..<text.endIndex, unit: .word, scheme: .nameType, options: options) { tag, tokenRange in
            if let tag = tag,
                tags.contains(tag) {

                // append the found tag
                documentTags.insert(String(text[tokenRange]))
            }
            return true
        }

        return documentTags
    }
}
