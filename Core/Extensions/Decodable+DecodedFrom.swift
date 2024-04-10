//
//  Decodable+DecodedFrom.swift
//  Core
//
//  Created by Julia Grasevych on 10.04.2024.
//

import Foundation

public extension Decodable {
    static func decoded(from data: Data) throws -> Self {
        let decoder = JSONDecoder()
        return try decoder.decode(Self.self, from: data)
    }
}
