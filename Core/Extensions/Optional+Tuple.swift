//
//  Optional+Tuple.swift
//  Core
//
//  Created by Julia Grasevych on 12.02.2024.
//

import Foundation

infix operator &&&: AdditionPrecedence
extension Optional {
    static public func &&&<T>(lhs: Self, rhs: Optional<T>) -> (Wrapped, T)? {
        guard let lhs = lhs, let rhs = rhs else {
            return nil
        }
        return (lhs, rhs)
    }
}
