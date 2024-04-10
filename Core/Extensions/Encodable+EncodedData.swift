//
//  Encodable+EncodedData.swift
//  Core
//
//  Created by Julia Grasevych on 10.04.2024.
//

import Foundation

public extension Encodable {
    func encodedData() throws -> Data {
        let encoder = JSONEncoder()
        return try encoder.encode(self)
    }
}
