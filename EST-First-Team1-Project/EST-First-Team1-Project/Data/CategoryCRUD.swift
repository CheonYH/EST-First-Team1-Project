//
//  CategoryCRUD.swift
//  EST-First-Team1-Project
//
//  Created by Cheon on 10/15/25.
//

import Foundation
import SwiftData


/// # Overview
/// 카테고리 모델에 대한 **생성·수정·삭제(CRUD)** 유틸리티.
///
/// 이 정적 메서드들을 호출하면 카테고리를 추가/갱신/삭제 기능을 구현할 수 있습니다.
///
/// - Note: CategoryCRUD 에 있는 메서드를 호출하면 자동으로 `context.save()`를 호출합니다.
///         저장 중 오류가 발생하면 `throws`로 전달되므로 `do-catch`로 처리해야 합니다.
///
///
enum CategoryCRUD {
    
    
    /// 새 **카테고리**를 생성하는 메서드 입니다.
    ///
    /// - Parameters:
    ///   - context: SwiftData `ModelContext`.
    ///   - name: 카테고리 이름(고유).
    ///   - r: 빨강(0~255).
    ///   - g: 초록(0~255).
    ///   - b: 파랑(0~255).
    ///   - a: 알파(0~255).
    ///   - icon: SF Symbol 또는 앱 리소스 아이콘 이름.
    /// - Throws: 저장 중 SwiftData 에러.
    /// - Example:
    ///   ```swift
    ///   try CategoryCRUD.create(context: ctx,
    ///                           name: "운동",
    ///                           r: 86, g: 95, b: 233, a: 255,
    ///                           icon: "dumbbell")
    ///   ```
    static func create(context: ModelContext, name: String,
                       r:Int, g:Int, b: Int, a:Int, icon: String) throws {
        
        let cat = CategoryModel(name: name, icon: icon, r: r, g: g, b: b, a:a)
        
        context.insert(cat)
        try context.save()
    }
    
    
    /// 기존에 생성된 **카테고리**를 업데이트하는 메서드입니다..
    ///
    /// - Parameters:
    ///   - context: SwiftData `ModelContext`.
    ///   - category: 수정 대상 `CategoryModel` 인스턴스.
    ///   - name: 새 이름.
    ///   - icon: 새 아이콘 이름.
    ///   - r: 빨강(0~255).
    ///   - g: 초록(0~255).
    ///   - b: 파랑(0~255).
    ///   - a: 알파(0~255).
    /// - Throws: 저장 중 SwiftData 에러.
    /// - Important: 이름에 **고유 제약**(예: `@Attribute(.unique)`)이 걸려 있어
    ///   중복된 카테고리를 등록하지 못하도록 설정되어있습니다.
    /// - Example:
    ///   ```swift
    ///   try CategoryCRUD.update(context: ctx,
    ///                           category: target,
    ///                           name: "건강",
    ///                           icon: "heart.fill",
    ///                           r: 52, g: 199, b: 89, a: 255)
    ///   ```
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
    
    /// **카테고리**를 삭제하는 메서드입니다..
    ///
    /// - Parameters:
    ///   - context: SwiftData `ModelContext`.
    ///   - category: 삭제할 `CategoryModel`.
    /// - Throws: 저장 중 SwiftData 에러.
    /// - Note: `@Relationship(deleteRule:)`)이 `.nullify`으로 설정되어,
    ///   카테고리가 사라져도 회고록의  데이터는 유지됩니다.
    /// - Example:
    ///   ```swift
    ///   try CategoryCRUD.delete(context: ctx, category: cat)
    ///   ```
    ///
    static func delete (context:ModelContext, category:CategoryModel ) throws {
        context.delete(category)
        try context.save()
    }
}
