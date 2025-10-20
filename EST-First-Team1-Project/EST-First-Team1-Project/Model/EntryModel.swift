//
//  Item.swift
//  EST-First-Team1-Project
//
//  Created by Cheon on 10/14/25.
//

import Foundation
import SwiftData

///   사용자가 작성한 **회고** 를 저장하는 SwiftData 모델.
/// - 회고의 **제목, 작성일, 서식 있는 본문** 과, 회고 작성시 설정한 **카테고리**를 저장합니다.
///
///  - Note: 이 모델은 SwiftData에서 자동으로 관리됩니다.
///
@Model
final class EntryModel {
    
    /// 엔트리 제목
    var title: String
    
    /// 작성(생성) 시각
    var createdAt: Date
    
    /// 본문을 보관하는 원본 데이터
    /// - 설명: `AttributedString`을 그대로 저장하기 어려우므로
    ///   JSON으로 바꿔(Data) 저장합니다.
    var attributedData: Data
    
    /// 선택한 카테고리 (없으면 nil = 미분류)
    @Relationship var category: CategoryModel?
    
    // MARK: - 서식 있는 본문(계산 프로퍼티)
    /// 사람이 바로 쓰는 본문.
    /// - get: 저장된 `attributedData`를 `AttributedString`으로 복원
    /// - set: 새 `AttributedString`을 JSON Data로 바꿔 저장
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
    
    // MARK: - 초기화 (서식 있는 본문)
    /// 서식 있는 본문으로 새 엔트리 만들기
    ///
    /// - Parameters:
    ///   - title: 제목
    ///   - createdAt: 작성 시각(기본값: 지금)
    ///   - attributedContent: 서식 있는 본문(굵게/기울임/링크 등)
    ///   - category: 카테고리(없으면 nil)
    init(
        title: String,
        createdAt: Date = .now,
        attributedContent: AttributedString,
        category: CategoryModel? = nil
    ) {
        self.title = title
        self.createdAt = createdAt
        self.category = category
        self.attributedData = (try? JSONEncoder().encode(attributedContent)) ?? Data()
    }
    
    // MARK: - 초기화 (평문 본문)
    /// 평문(String)으로 새 엔트리 만들기
    /// - 설명: 내부에서 서식 없는 `AttributedString`으로 변환해 저장합니다.
    ///
    /// - Parameters:
    ///   - title: 제목
    ///   - createdAt: 작성 시각(기본값: 지금)
    ///   - content: 평문 본문
    ///   - category: 카테고리(없으면 nil)
    init(
        title: String,
        createdAt: Date = .now,
        content: String,
        category: CategoryModel? = nil
    ) {
        self.title = title
        self.createdAt = createdAt
        self.category = category
        let plain = AttributedString(content)
        self.attributedData = (try? JSONEncoder().encode(plain)) ?? Data()
    }
}
