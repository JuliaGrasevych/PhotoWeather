//
//  Item.swift
//  PhotoWeather
//
//  Created by Julia Grasevych on 05.02.2024.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
