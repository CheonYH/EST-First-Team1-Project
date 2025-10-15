//
//  EntryCRUD.swift
//  EST-First-Team1-Project
//
//  Created by Cheon on 10/15/25.
//

import Foundation
import SwiftData

enum EntryCRUD {
    
    static func create(context: ModelContext, title: String,
                            createdAt: Date, content: String) throws -> Entry{
        let ent = Entry(title: title, createdAt: createdAt, content: content)
        context.insert(ent)
        try context.save()
        
        return ent
    }
    
    static func update(context: ModelContext, _ entry: Entry, editTitle:String
                          , editContent: String) throws {
        entry.title = editTitle
        entry.content = editContent
        
        try context.save()
    }
    
    
    static func delete(context: ModelContext ,_ entry: Entry) throws {
        context.delete(entry)
        
        try context.save()
    }
}
