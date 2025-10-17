//
//  Item.swift
//  EST-First-Team1-Project
//
//  Created by Cheon on 10/14/25.
//

import Foundation
import SwiftData

@Model
final class EntryModel {
    
    var title: String
    var createdAt: Date
    
    // UIKit 없이 서식을 보존하기 위해 AttributedString을 JSON(Data)로 저장
    var attributedData: Data
    
    @Relationship var category: CategoryModel?
    
    // MARK: Computed: 저장된 Data ↔️ AttributedString 변환
    var attributedContent: AttributedString {
        get {
            guard let decoded = try? JSONDecoder().decode(AttributedString.self, from: attributedData) else {
                return AttributedString("")
            }
            return decoded
        }
        set {
            attributedData = (try? JSONEncoder().encode(newValue)) ?? Data()
        }
    }
    
    // MARK: - 초기화(AttributedString)
    init(title: String, createdAt: Date = .now, attributedContent: AttributedString, category: CategoryModel? = nil) {
        self.title = title
        self.createdAt = createdAt
        self.category = category
        self.attributedData = (try? JSONEncoder().encode(attributedContent)) ?? Data()
    }
    
    // MARK: - 호환용 초기화(String) — 순수 텍스트를 서식 없는 AttributedString으로 저장
    init(title: String, createdAt: Date = .now, content: String, category: CategoryModel? = nil) {
        self.title = title
        self.createdAt = createdAt
        self.category = category
        let plain = AttributedString(content)
        self.attributedData = (try? JSONEncoder().encode(plain)) ?? Data()
    }
}

