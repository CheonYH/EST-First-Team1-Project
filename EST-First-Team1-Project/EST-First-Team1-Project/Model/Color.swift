//
//  Color.swift
//  EST-First-Team1-Project
//
//  Created by Cheon on 10/15/25.
//

import Foundation
import SwiftData

/// 카테고리 탭에 적용되는 색
@Model
final class CategoryColor {
    var r: Int
    var g: Int
    var b: Int
    
    init(r: Int, g: Int, b: Int) {
        self.r = r
        self.g = g
        self.b = b
    }
}
