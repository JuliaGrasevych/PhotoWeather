//
//  Bool+IntCodable.swift
//  Core
//
//  Created by Julia Grasevych on 08.02.2024.
//

import Foundation

@propertyWrapper
public struct BoolIntDecodable: Codable {
    public let wrappedValue: Bool
    
    public init(wrappedValue: Bool) {
        self.wrappedValue = wrappedValue
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let intValue = try container.decode(Int.self)
        wrappedValue = intValue == 1
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        let intValue = wrappedValue ? 1 : 0
        try container.encode(intValue)
    }
}
