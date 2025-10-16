//
//  CategoryCRUD.swift
//  EST-First-Team1-Project
//
//  Created by Cheon on 10/15/25.
//

import Foundation
import SwiftData

enum CategoryCRUD {
    
    static func create(context: ModelContext, name: String) throws {
        let cat = CategoryModel(name: name)
        
        context.insert(cat)
        try context.save()
    }
    
    static func update(context:ModelContext, category:CategoryModel, name: String ) throws {
        
        category.name = name
        try context.save()
    }
    
    static func delete (context:ModelContext, category:CategoryModel ) throws {
        context.delete(category)
        try context.save()
    }
}
