//
//  CategoryCRUD.swift
//  EST-First-Team1-Project
//
//  Created by Cheon on 10/15/25.
//

import Foundation
import SwiftData

enum CategoryCRUD {
    
    static func create(context: ModelContext, name: String,
                       r:Int, g:Int, b: Int, a:Int, icon: String) throws {
        
        let cat = CategoryModel(name: name, icon: icon, r: r, g: g, b: b, a:a)
        
        context.insert(cat)
        try context.save()
    }
    
    static func update(context:ModelContext, category:CategoryModel, name: String,
                    icon: String, r:Int, g:Int, b: Int,a:Int ) throws {
        
        category.name = name
        category.r = r
        category.g = g
        category.b = b
        category.a = a
        category.icon = icon
        
        try context.save()
    }
    
    static func delete (context:ModelContext, category:CategoryModel ) throws {
        context.delete(category)
        try context.save()
    }
}
