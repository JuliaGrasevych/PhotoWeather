//
//  JSONDecoder+AnyDateFormatter.swift
//  Core
//
//  Created by Julia Grasevych on 07.02.2024.
//

import Foundation

public extension JSONDecoder.DateDecodingStrategy {
    static func anyFormatter(in formatters: [DateFormatter]) -> Self {
        return .custom { decoder in
            guard !formatters.isEmpty else {
                throw DecodingError.dataCorrupted(
                    DecodingError.Context(
                        codingPath: decoder.codingPath,
                        debugDescription: "No date formatters"
                    )
                )
            }
            
            let container = try decoder.singleValueContainer()
            let dateString = try container.decode(String.self)
            let formattedDates = formatters.lazy
                .compactMap { $0.date(from: dateString) }
            guard let date = formattedDates.first else {
                let formattersString = formatters.compactMap(\.dateFormat)
                    .joined(separator: " or ")
                throw DecodingError.dataCorrupted(
                    DecodingError.Context(
                        codingPath: decoder.codingPath,
                        debugDescription: "Date string \"\(dateString)\" doesn't match any of the expected formats (\(formattersString))"
                    )
                )
            }
            return date
        }
    }
}
