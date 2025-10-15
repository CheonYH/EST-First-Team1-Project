//
//  Category.swift
//  EST-First-Team1-Project
//
//  Created by Cheon on 10/15/25.
//

import Foundation
import SwiftData

// 카테고리 정보 모델
@Model
final class Category {
    
    @Attribute(.unique) var name: String
    var usageCount: Int
    
    init(name: String, usageCount: Int) {
        self.name = name
        self.usageCount = usageCount
    }
}
