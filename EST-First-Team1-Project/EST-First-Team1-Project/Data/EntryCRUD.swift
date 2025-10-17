//
//  EntryCRUD.swift
//  EST-First-Team1-Project
//
//  Created by Cheon on 10/15/25.
//

import Foundation
import SwiftData

enum EntryCRUD {
    
    // 기존 시그니처 유지(String) — 내부에서 서식 없는 AttributedString으로 저장
    static func create(context: ModelContext, title: String,
                       createdAt: Date, content: String) throws {
        let ent = EntryModel(title: title, createdAt: createdAt, content: content)
        context.insert(ent)
        try context.save()
    }
    
 
    static func create(context: ModelContext, title: String,
                       createdAt: Date, body: AttributedString, category: CategoryModel? = nil) throws {
        let ent = EntryModel(title: title, createdAt: createdAt, attributedContent: body, category: category)
        context.insert(ent)
        try context.save()
    }
    
 
    static func update(context: ModelContext, _ entry: EntryModel,
                       editTitle: String, editContent: String) throws {
        entry.title = editTitle
        entry.attributedContent = AttributedString(editContent)
        try context.save()
    }
    

    static func update(context: ModelContext, _ entry: EntryModel,
                       editTitle: String, editBody: AttributedString) throws {
        entry.title = editTitle
        entry.attributedContent = editBody
        try context.save()
    }
    
    static func delete(context: ModelContext ,_ entry: EntryModel) throws {
        context.delete(entry)
        try context.save()
    }
}

