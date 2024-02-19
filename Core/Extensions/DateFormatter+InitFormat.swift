//
//  DateFormatter+InitFormat.swift
//  Core
//
//  Created by Julia Grasevych on 07.02.2024.
//

import Foundation

public extension DateFormatter {
    convenience init(dateFormat: String) {
        self.init()
        self.dateFormat = dateFormat
    }
}
