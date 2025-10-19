//
//  MainPage.swift
//  EST-First-Team1-Project
//
//  Created by 이찬희 on 10/16/25.
//

import SwiftUI
import SwiftData

// MARK: - MainPage

/// # Overview
/// BoxUp의 **메인 리스트 화면**입니다.
/// 오늘 날짜 헤더, 카테고리 필터, 검색, 항목 목록, 그리고 새 기록/카테고리/통계로 이동하는
/// 네비게이션 진입점을 제공합니다.
///
/// # Discussion
/// - 데이터는 SwiftData의 ``EntryModel``/``CategoryModel``을 `@Query`로 구독합니다.
/// - 상단 툴바의 **카테고리 필터**는 선택된 카테고리에 맞춰 목록을 즉시 필터링합니다.
/// - **검색창**은 조건부로 표시되며(돋보기 버튼), 제목과 본문(AttributedString → String)을 대상으로 합니다.
/// - 셀을 탭하면 `ContentView(editTarget:)`로 진입하여 **수정 모드**로 이동합니다.
/// - 라이트/다크에 따라 카드 · 배경 · 텍스트 대비를 조정합니다.
///
/// # SeeAlso
/// - ``StatusView`` : 통계 화면
/// - ``Category``   : 카테고리 관리 화면
/// - ``ContentView``: 에디터(신규/수정)
struct MainPage: View {
    
    // MARK: Environment
    
    /// SwiftData 저장/조회 컨텍스트.
    @Environment(\.modelContext) private var ctx
    
    /// 시스템 색상 모드(라이트/다크).
    @Environment(\.colorScheme) private var scheme
    
    // MARK: Data Sources
    
    /// 최신 작성순으로 정렬된 회고 엔트리 목록.
    @Query(sort: [SortDescriptor(\EntryModel.createdAt, order: .reverse)])
    private var entries: [EntryModel]
    
    /// 이름 오름차순 정렬된 카테고리 목록(필터 메뉴용).
    @Query(sort: [SortDescriptor(\CategoryModel.name, order: .forward)])
    private var categories: [CategoryModel]
    
    // MARK: UI States
    
    /// 검색 텍스트.
    @State private var searchText = ""
    
    /// 작업 상태 메시지(필요 시 알림 등에 사용).
    @State private var statusMessage: String = ""
    
    /// 검색창 표시 여부.
    @State private var isSearchVisible: Bool = false
    
    /// 선택된 카테고리(없으면 전체).
    @State private var selectedCategory: CategoryModel? = nil
    
    /// 카테고리 화면 네비게이션 트리거.
    @State private var navigateToCategory: Bool = false
    
    /// 텍스트 에디터 화면 네비게이션 트리거.
    @State private var navigateToTextEditor: Bool = false
    
    /// 통계(StatusView) 화면 네비게이션 트리거.
    @State private var navigateToStatusView: Bool = false
    
    // MARK: Color Palette (Adaptive)
    
    /// 앱 헤더/배경 색상(다크/라이트 대응).
    private var appBackground: Color {
        scheme == .dark
        ? Color(red: 28/255, green: 28/255, blue: 30/255) // system-like dark
        : Color(red: 53/255, green: 53/255, blue: 53/255)
    }
    
    /// 리스트 영역 배경.
    private var listBackground: Color {
        scheme == .dark ? Color.black.opacity(0.05) : Color.white
    }
    
    /// 카드 배경.
    private var cardBackground: Color {
        scheme == .dark
        ? Color(red: 44/255, green: 44/255, blue: 46/255) // secondary dark
        : appBackground
    }
    
    /// 기본 텍스트 컬러.
    private var primaryText: Color {
        scheme == .dark ? .white : .black
    }
    
    /// 보조 텍스트 컬러.
    private var secondaryText: Color {
        scheme == .dark ? Color.white.opacity(0.7) : Color.black.opacity(0.6)
    }
    
    /// 카드 위 텍스트(가독을 위해 현재는 항상 흰색).
    private var inverseOnCard: Color {
        // Text color to be used on cardBackground
        scheme == .dark ? .white : .white
    }
    
    
    // MARK: Filtering
    
    /// # Overview
    /// 현재 **선택된 카테고리 + 검색어**를 적용한 결과 목록입니다.
    ///
    /// # Discussion
    /// - 카테고리: 선택된 경우에만 필터링합니다.
    /// - 검색: 공백이 아니면 제목과 본문(AttributedString → String 변환)에 대해 `contains` 매칭을 수행합니다.
    private var filtered: [EntryModel] {
        var base = entries
        
        // 1) 카테고리 필터 (선택된 경우에만)
        if let current = selectedCategory {
            base = base.filter { $0.category?.id == current.id }
        }
        
        // 2) 텍스트 검색 (비어있지 않은 경우에만)
        let trimmed = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return base }
        
        let needle = trimmed.lowercased()
        return base.filter { e in
            let title = e.title.lowercased()
            let body = String(e.attributedContent.characters).lowercased()
            return title.contains(needle) || body.contains(needle)
        }
    }
    
   
    // MARK: Body
    
    /// # Overview
    /// 메인 리스트 UI를 구성합니다.
    /// 상단 헤더, 목록, 툴바(카테고리 필터/검색/메뉴)로 이루어집니다.
    var body: some View {
        
        
        NavigationStack {
            VStack(spacing: 0) {
                // 숨겨진 네비게이션 링크: 상태로 Category 화면으로 푸시
                NavigationLink(isActive: $navigateToCategory) {
                    Category()
                        .navigationBarTitleDisplayMode(.inline)
                } label: {
                    EmptyView()
                }
                .hidden()
                
                // 숨겨진 네비게이션 링크: 상태로 텍스트 에디터(ContentView) 화면으로 푸시
                NavigationLink(isActive: $navigateToTextEditor) {
                    ContentView()
                        .navigationBarTitleDisplayMode(.inline)
                } label: {
                    EmptyView()
                }
                .hidden()
                
                
                NavigationLink(isActive: $navigateToStatusView) {
                    StatusView()
                        .navigationBarTitleDisplayMode(.inline)
                } label: {
                    EmptyView()
                }
                .hidden()
                
                // 상단 헤더 영역
                VStack(spacing: 12) {
                    HStack(alignment: .center) {
                        // 날짜 text
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Today")
                                .font(.system(size: 34, weight: .bold))
                                .foregroundStyle(.white)
                            Text(Date.now, format: .dateTime.year().month().day())
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(.white.opacity(0.6))
                        }
                        Spacer()
                        // 새 기록 버튼
                        Button {
                            // 텍스트필드 페이지로 이동
                            navigateToTextEditor = true
                        } label: {
                            Text("새 기록")
                                .font(.system(size: 16, weight: .semibold))
                                .padding(.horizontal, 16)
                                .padding(.vertical, 10)
                                .background(Capsule().fill(Color.indigo))
                                .foregroundStyle(.white)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical)
                    .background(appBackground)
                    
                    // "My Work" 라벨 + 둥근 사각형 배경
                    HStack {
                        Text("My Memory")
                            .font(.headline)
                            .foregroundStyle(primaryText)
                            .padding(.horizontal, -2)
                            .padding(.vertical, 6)
                        
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 6)
                    .background(listBackground)
                }
                
                // 리스트 영역
                ZStack {
                    listBackground
                    
                    List {
                        if filtered.isEmpty {
                            ContentUnavailableView("저장된 기록이 없습니다",
                                                   systemImage: "note.text",
                                                   description: Text("새로 추가 버튼으로 새로운 경험을 기록해보세요"))
                            .listRowBackground(Color.clear)
                        } else {
                            ForEach(filtered, id: \.persistentModelID) { e in
                                
                                VStack {
                                    Spacer()
                                    Text(e.createdAt, format: .dateTime.year().month().day())
                                        .font(.footnote.weight(.semibold))
                                        .foregroundStyle(primaryText)
                                        .frame(maxWidth: .infinity, alignment: .trailing)
                                        .padding(.trailing, 12)   // 우측 여백 미세조정
                                        
                                    
                                    
                                    ZStack {
                                        
                                        VStack(alignment: .leading, spacing: 8) {
                                            VStack(alignment: .leading, spacing: 4) {
                                                Text(e.title.isEmpty ? "제목 없음" : e.title)
                                                    .font(.headline)
                                                    .foregroundStyle(inverseOnCard)
                                                
                                                let plain = String(e.attributedContent.characters)
                                                if !plain.isEmpty {
                                                    Text(plain)
                                                        .font(.subheadline)
                                                        .foregroundStyle(inverseOnCard.opacity(0.8))
                                                        .lineLimit(2)
                                                }
                                            }
                                            HStack {
                                                if let cat = e.category {
                                                    let fg = Color.from255(r: cat.r, g: cat.g, b: cat.b)
                                                    
                                                    HStack(spacing: 6) {
                                                        Image(systemName: cat.icon)
                                                            .font(.caption)
                                                            .foregroundStyle(fg)
                                                        Text(cat.name)
                                                            .font(.caption)
                                                            .foregroundStyle(inverseOnCard.opacity(0.9))
                                                    }
                                                    .padding(.horizontal, 8)
                                                    .padding(.vertical, 4)
                                                    .background(
                                                        RoundedRectangle(cornerRadius: 6, style: .continuous)
                                                            .fill(cardBackground.opacity(0.6))
                                                    )
                                                }
                                                
                                                else {
                                                    Text("Uncategorized")
                                                        .font(.caption)
                                                        .foregroundStyle(inverseOnCard.opacity(0.8))
                                                }
                                                
                                                Spacer()
                                                
                                            }
                                        }
                                        .padding(12)
                                        .background(
                                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                                .fill(cardBackground)
                                        )
                                        
                                        // 투명 링크: 카드 어디를 눌러도 수정 화면으로
                                        NavigationLink {
                                            ContentView(editTarget: e)
                                                .navigationBarTitleDisplayMode(.inline)
                                        } label: {
                                            Rectangle().fill(.clear)
                                        }
                                       
                                        .buttonStyle(.plain)
                                    }
                                    .listRowBackground(Color.clear)
                                    .listRowSeparator(.hidden)
                                    .padding(.vertical, 4)
                                }
                            }
                            .onDelete { idx in
                                let snapshot = filtered
                                for i in idx.sorted(by: >) {
                                    if snapshot.indices.contains(i) {
                                        let entry = snapshot[i]
                                        ctx.delete(entry)
                                    }
                                }
                                do {
                                    try ctx.save()
                                } catch {
                                    print("삭제 저장 실패: \(error)")
                                    statusMessage = "삭제 저장에 실패했습니다."
                                }
                            }
                        }
                    }
                    
                    .scrollContentBackground(.hidden)
                    .listStyle(.plain)
                    .environment(\.defaultMinListRowHeight, 0)
                }
            }
            .toolbar {
                // 왼쪽: 햄버거 -> 카테고리 목록 보기(표시만)
                ToolbarItem(placement: .navigationBarLeading) {
                    Menu {
                        Button("새 기록", systemImage: "plus.app") {
                            // 텍스트필드 페이지로 이동
                            navigateToTextEditor = true
                        }
                        Button("통계", systemImage: "chart.bar") {
                            navigateToStatusView = true
                        }
                        Button("카테고리 생성", systemImage: "rectangle.stack.badge.plus") {
                            // Category 화면으로 네비게이션
                            navigateToCategory = true
                        }
                        
                    } label: {
                        Image("Hamburger")
                            .renderingMode(.template)
                            .foregroundStyle(.white)
                            .imageScale(.large)
                    }
                }
                
                // 중앙: 카테고리 필터 드롭다운
                ToolbarItem(placement: .principal) {
                    Menu {
                        Button {
                            selectedCategory = nil
                        } label: {
                            HStack {
                                Image(systemName: "line.3.horizontal.decrease.circle")
                                    .renderingMode(.original)
                                    .foregroundStyle(.white)
                                Text("전체")
                            }
                        }
                        ForEach(categories) { category in
                            
                            let fg = Color.from255(r: category.r, g: category.g, b: category.b)
                            
                            Button {
                                if let current = selectedCategory,
                                   current.persistentModelID == category.persistentModelID {
                                    selectedCategory = nil
                                } else {
                                    selectedCategory = category
                                }
                            } label: {
                                HStack {
                                    // 카테고리 아이콘 + 색상
                                    Image(systemName: category.icon)
                                        .renderingMode(.original)
                                        .symbolRenderingMode(.monochrome)
                                        .foregroundStyle(fg)
                                    Text(category.name)
                                    if let current = selectedCategory,
                                       current.persistentModelID == category.persistentModelID {
                                        Spacer()
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                            .tint(fg)
                        }
                    } label: {
                        HStack(spacing: 6) {
                            if let current = selectedCategory {
                                let fg = Color.from255(r: current.r, g: current.g, b: current.b)
                                Image(systemName: current.icon)
                                    .foregroundStyle(fg) // 툴바는 어두운 배경, 흰색 유지
                                Text(current.name)
                                    .foregroundStyle(.white) // on header background
                            } else {
                                Text("전체")
                                    .foregroundStyle(.white)
                            }
                            Image(systemName: "chevron.down")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundStyle(.white)
                        }
                        .lineLimit(1)
                        .truncationMode(.tail)
                        .frame(width: 180, height: 30, alignment: .center)
                        
                    }
                }
                
                // 우측: 검색
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        isSearchVisible.toggle()
                        if isSearchVisible == false {
                            searchText = ""
                        }
                    } label: {
                        // Use template + tint to ensure contrast on dark header
                        Image("glasses_white")
                            .renderingMode(.template)
                            .foregroundStyle(.white)
                    }
                    .accessibilityLabel("검색")
                }
            }
            .modifier(ConditionalSearchModifier(isVisible: isSearchVisible, text: $searchText))
        }
        .background(appBackground.ignoresSafeArea())
        // .alert(statusMessage, isPresented: .constant(!statusMessage.isEmpty)) { ... }
    }
}

// MARK: - ConditionalSearchModifier

/// # Overview
/// `.searchable`를 **조건부로** 적용하기 위한 뷰 수정자입니다.
/// 검색창을 토글할 때 뷰 계층을 단순하게 유지합니다.
///
/// # Parameters
/// - isVisible: 검색창 표시 여부
/// - text: 검색어 바인딩
private struct ConditionalSearchModifier: ViewModifier {
    let isVisible: Bool
    @Binding var text: String
    
    func body(content: Content) -> some View {
        if isVisible {
            content.searchable(text: $text, prompt: "제목/내용 검색")
        } else {
            content
        }
    }
}

// MARK: - DateFormatter Helpers

/// 점으로 구분된 연월일(예: `2025.10.17`) 포맷터.
private extension DateFormatter {
    static let dottedYMD: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "ko_KR") 
        f.dateFormat = "yyyy.MM.dd"
        return f
    }()
}

// MARK: - Preview
#Preview {
    MainPage()
        .modelContainer(for: [EntryModel.self, CategoryModel.self], inMemory: true)
}
