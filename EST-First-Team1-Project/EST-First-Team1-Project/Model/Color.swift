//
//  Color.swift
//  EST-First-Team1-Project
//
//  Created by Cheon on 10/15/25.
//

import Foundation
import SwiftData

/// 사용자가 카테고리를 생성 했을 떄 **카테고리에 적용될 색상(RGB)**을 저장하는 SwiftData 모델

/// `r`, `g`, `b`는 각각 0~255의 정수입니다.
/// 카테고리에 적용될 **색상의 RGB값**을 저장합니다.

///   Note: 이 모델은 SwiftData에서 자동으로 관리됩니다.
///   새로운 항목을 추가할 때는 `ModelContext`에 `insert` 해주면 됩니다.
@Model
final class CategoryColor {
    
    
    /// 카테고리에 적용될 색상의 **red** 값입니다.
    var r: Int
    
    /// 카테고리에 적용될 색상의 **green** 값입니다.
    var g: Int
    
    /// 카테고리에 적용될 색상의 **blue** 값입니다.
    var b: Int
    
    /// 중복된 색상이 적용되지 않도록 방지하기 위해 사용되는 고유한 값입니다.
    /// rgbKey는 r-g-b 형식으로 저장합니다.
    /// 예: "86-95-233"
    @Attribute(.unique) private(set) var rgbKey: String
    
    init(r: Int, g: Int, b: Int) {
        self.r = r
        self.g = g
        self.b = b
        
        self.rgbKey = "\(r)-\(g)-\(b)"
    }
}
