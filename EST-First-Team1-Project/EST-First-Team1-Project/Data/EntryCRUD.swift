//
//  EntryCRUD.swift
//  EST-First-Team1-Project
//
//  Created by Cheon on 10/15/25.
//

import Foundation
import SwiftData

/// # Overview
/// 회고(EntryModel)를 만들고, 고치고, 지우는 유틸리티입니다.
/// View에서 modelContext를 넣어 호출해서 씁니다.
///
/// - Note: EntryCRUD 에 있는 메서드를 호출하면 자동으로 `context.save()`를 호출합니다.
///         저장 중 오류가 발생하면 `throws`로 전달되므로 `do-catch`로 처리해야 합니다.

enum EntryCRUD {
    
    // MARK: - Create (평문 String)
    /// 새 회고를 만듭니다. (본문은 평문 String)
    ///
    /// - Parameters:
    ///   - context: SwiftData ModelContext
    ///   - title: 제목
    ///   - createdAt: 생성 시각
    ///   - content: 본문(평문)
    ///   - category: 선택 카테고리(없으면 nil)
    /// - Throws: 저장에 실패하면 throw 됩니다.
    static func create(
        context: ModelContext,
        title: String,
        createdAt: Date,
        content: String,
        category: CategoryModel? = nil
    ) throws {
        let ent = EntryModel(title: title, createdAt: createdAt, content: content, category: category)
        context.insert(ent)
        try context.save()
    }
    
    // MARK: - Create (서식 있는 AttributedString)
    /// 새 회고를 만듭니다. (본문은 AttributedString)
    ///
    /// - Parameters:
    ///   - context: SwiftData ModelContext
    ///   - title: 제목
    ///   - createdAt: 생성 시각
    ///   - body: 본문(서식 가능)
    ///   - category: 선택 카테고리(없으면 nil)
    /// - Throws: 저장에 실패하면 throw 됩니다.
    static func create(
        context: ModelContext,
        title: String,
        createdAt: Date,
        body: AttributedString,
        category: CategoryModel? = nil
    ) throws {
        let ent = EntryModel(title: title, createdAt: createdAt, attributedContent: body, category: category)
        context.insert(ent)
        try context.save()
    }
    
    // MARK: - Update (평문 String)
    /// 기존 회고의 제목/본문(평문)을 수정합니다.
    ///
    /// - Parameters:
    ///   - context: SwiftData ModelContext
    ///   - entry: 수정할 엔트리
    ///   - editTitle: 새 제목
    ///   - editContent: 새 본문(평문)
    /// - Throws: 저장에 실패하면 throw 됩니다.
    static func update(
        context: ModelContext,
        _ entry: EntryModel,
        editTitle: String,
        editContent: String
    ) throws {
        entry.title = editTitle
        entry.attributedContent = AttributedString(editContent)
        try context.save()
    }
    
    // MARK: - Update (서식 있는 AttributedString)
    /// 기존 회고의 제목/본문(서식 가능)을 수정합니다.
    ///
    /// - Parameters:
    ///   - context: SwiftData ModelContext
    ///   - entry: 수정할 엔트리
    ///   - editTitle: 새 제목
    ///   - editBody: 새 본문(서식 가능)
    /// - Throws: 저장에 실패하면 throw 됩니다.
    static func update(
        context: ModelContext,
        _ entry: EntryModel,
        editTitle: String,
        editBody: AttributedString
    ) throws {
        entry.title = editTitle
        entry.attributedContent = editBody
        try context.save()
    }
    
    // MARK: - Delete
    /// 회고를 삭제합니다.
    ///
    /// - Parameters:
    ///   - context: SwiftData ModelContext
    ///   - entry: 삭제할 엔트리
    /// - Throws: 저장에 실패하면 throw 됩니다.
    static func delete(
        context: ModelContext,
        _ entry: EntryModel
    ) throws {
        context.delete(entry)
        try context.save()
    }
}

