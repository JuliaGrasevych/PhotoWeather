//
//  URLQueryItem+KeyInit.swift
//  Core
//
//  Created by Julia Grasevych on 14.02.2024.
//

import Foundation

public extension URLQueryItem {
    init(key: any RawRepresentable<String>, value: String) {
        self.init(name: key.rawValue, value: value)
    }
}
