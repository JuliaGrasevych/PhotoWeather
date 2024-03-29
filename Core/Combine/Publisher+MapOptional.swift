//
//  Publisher+MapOptional.swift
//  Core
//
//  Created by Julia Grasevych on 29.03.2024.
//

import Foundation
import Combine

public extension Publisher {
    func mapOptional() -> Publishers.Map<Self, Self.Output?> {
        Publishers.Map(upstream: self, transform: { Optional($0) })
    }
}
