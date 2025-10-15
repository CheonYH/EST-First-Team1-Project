//
//  Item.swift
//  EST-First-Team1-Project
//
//  Created by Cheon on 10/14/25.
//

import Foundation
import SwiftData

/// 사용자가 작성한 **회고 항목**을 저장하는 SwiftData 모델.
///
/// 제목, 본문, 작성 날짜를 함께 보관합니다.
/// SwiftData를 이용해 앱 안에서 회고 내용을 저장하고 불러올 때 사용됩니다.
///
/// - Note: 이 모델은 SwiftData에서 자동으로 관리됩니다.
///   새로운 항목을 추가할 때는 `ModelContext`에 `insert` 해주면 됩니다.
///


@Model
final class EntryModel {
    
    /// 회고의 ** 제목 ** 입니다.
    /// 목록에 표시되거나 검색할 때 주로 사용됩니다.
    var title: String
    
    /// 회고를 ** 작성한 날짜 ** 입니다.
    /// 저장 했을 때의 시간이 들어갑니다.
    var createdAt: Date
    
    /// 회고의 ** 본문 내용 **입니다.
    /// 간단한 텍스트나 긴 글 모두 저장할 수 있습니다.
    var content: String
    
    /// 회고 작성 시 선택한 카테고리 입니다.
    /// 선택한 카테고리가 삭제되어도 글이 남아있도록 하기 위해 카테고리를 Optional로 설정합니다.
    @Relationship var category: Category?
    
    init(title: String, createdAt: Date = .now, content: String, category: Category? = nil) {
        self.title = title
        self.createdAt = createdAt
        self.content = content
        self.category = category
        
    }
}
