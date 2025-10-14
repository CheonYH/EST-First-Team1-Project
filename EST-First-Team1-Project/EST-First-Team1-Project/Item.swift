//
//  Item.swift
//  EST-First-Team1-Project
//
//  Created by Cheon on 10/14/25.
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
