//
//  Category.swift
//  EST-First-Team1-Project
//
//  Created by Cheon on 10/15/25.
//

import Foundation
import SwiftData

/// 사용자가 생성한 **카테고리 항목**을 저장하는 SwiftData 모델.
///
/// 카테고리 **이름**과 **사용 횟수**를 보관합니다.
/// 회고를 카테고리별로 분류/검색하거나, 통계 화면에서 사용 횟수를 표시할 때 활용됩니다.
///
/// - Note: 이 모델은 SwiftData에서 자동으로 관리됩니다.
///   새로운 항목을 추가할 때는 `ModelContext`에 `insert` 해주면 됩니다.
///

@Model
final class CategoryModel {
    
    /// 카테고리의 ** 이름 **입니다.
    /// 동일 이름이 중복 저장되지 않도록 고유(unique) 제약을 둡니다.
    @Attribute(.unique) var name: String
   
    
    /// 카테고리가 지워져도 지워진 카테고리를 가지고 있는 글이 삭제 안되도록 설정할 때 사용됩니다.
    /// 카테고리가 삭제되면 해당 카테고리를 가진 회고들의 카테고리가 nil(미분류)로 바뀝니다.
    @Relationship(deleteRule: .nullify, inverse: \EntryModel.category)
    var entries: [EntryModel] = []
    
    /// 카테고리의 ** 사용 횟수 **입니다.
    /// 카테고리가 얼마나 쓰였는지 통계를 낼 때 사용됩니다.
    /// **계산 프로퍼티**로, 항상 최신 상태(entries.count)를 반영합니다.
    var usageCount: Int {
        entries.count
    }
    
    
    init(name: String) {
        self.name = name
        
    }
    
}

