//
//  MainPage.swift
//  EST-First-Team1-Project
//
//  Created by 이찬희 on 10/16/25.
//

import SwiftUI
import SwiftData

struct MainPage: View {
    
   
    
    
    @Environment(\.modelContext) private var ctx
    @Environment(\.colorScheme) private var scheme
    
    // Entry 최신순
    @Query(sort: [SortDescriptor(\EntryModel.createdAt, order: .reverse)])
    private var entries: [EntryModel]
    
    // 카테고리(표시용),
    @Query(sort: [SortDescriptor(\CategoryModel.name, order: .forward)])
    private var categories: [CategoryModel]
    
    @State private var searchText = ""
    // 햄버거 버튼 상태 메시지(비옵셔널로 단순화, 비어있으면 표시 없음으로 취급)
    @State private var statusMessage: String = ""
    // 돋보기 버튼
    @State private var isSearchVisible: Bool = false
    // 선택된 카테고리 (SwiftData Category 사용) — 선택 없음 상태가 필요하므로 옵셔널 유지
    @State private var selectedCategory: CategoryModel? = nil
    // 카테고리 화면 네비게이션 트리거
    @State private var navigateToCategory: Bool = false
    // 텍스트 에디터(텍스트필드 페이지) 네비게이션 트리거
    @State private var navigateToTextEditor: Bool = false
    // 통계 화면 네비게이션 트리거
    @State private var navigateToStatusView: Bool = false
    // 다크/라이트 대응 색상
    private var appBackground: Color {
        scheme == .dark
        ? Color(red: 28/255, green: 28/255, blue: 30/255) // system-like dark
        : Color(red: 53/255, green: 53/255, blue: 53/255)
    }
    private var listBackground: Color {
        scheme == .dark ? Color.black.opacity(0.05) : Color.white
    }
    private var cardBackground: Color {
        scheme == .dark
        ? Color(red: 44/255, green: 44/255, blue: 46/255) // secondary dark
        : appBackground
    }
    private var primaryText: Color {
        scheme == .dark ? .white : .black
    }
    private var secondaryText: Color {
        scheme == .dark ? Color.white.opacity(0.7) : Color.black.opacity(0.6)
    }
    private var inverseOnCard: Color {
        // Text color to be used on cardBackground
        scheme == .dark ? .white : .white
    }
    
    
    // 검색 필터 (제목/본문)
    // EntryModel에는 `content`가 없고 `attributedContent`가 있습니다.
    // 단계적으로 나눠 타입체커 부담을 줄이고, 선택 카테고리와 텍스트 검색을 순차 적용합니다.
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
    
   
    // 바디
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
                                        
                                        // 수정 모드로 바로 진입: ContentView(editTarget:)로 네비게이션
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
                        // If you have separate dark/light assets, Asset Catalog variants will switch automatically.
                        // If not, tint the template image to match scheme.
                        Image("Hamburger")
                            .renderingMode(.template)
                            .foregroundStyle(.white) // Header is dark; keep icon white for contrast
                            .imageScale(.large)
                    }
                }
                
                // 가운데(제목 영역): 카테고리 토글 메뉴
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
                
                // 검색 버튼
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

// 설명용: .searchable를 조건부로 적용하기 위한 뷰 수정자.
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

private extension DateFormatter {
    static let dottedYMD: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "ko_KR") 
        f.dateFormat = "yyyy.MM.dd"
        return f
    }()
}

#Preview {
    MainPage()
        .modelContainer(for: [EntryModel.self, CategoryModel.self], inMemory: true)
}
