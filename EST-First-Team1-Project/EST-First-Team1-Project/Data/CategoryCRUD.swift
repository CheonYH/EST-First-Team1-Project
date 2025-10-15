//
//  CategoryCRUD.swift
//  EST-First-Team1-Project
//
//  Created by Cheon on 10/15/25.
//

import Foundation
import SwiftData

enum CategoryCRUD {
    
    static func create(context: ModelContext, entry: Entry, name: String, count: Int) {
        let cat = Category(name: name)
        
        context.insert(cat)
    }
}
