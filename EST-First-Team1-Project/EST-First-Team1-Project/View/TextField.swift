//
//  TextField.swift
//  EST-First-Team1-Project
//
//  Created by 김대현 on 10/16/25.
//

import SwiftUI
import SwiftData

// MARK: - SwiftData Model
@Model
final class Note {
    var title: String
    var category: String
    var body: AttributedString
    var createdAt: Date

    init(title: String, category: String, body: AttributedString, createdAt: Date = .now) {
        self.title = title
        self.category = category
        self.body = body
        self.createdAt = createdAt
    }
}



// MARK: - ContentView
struct ContentView: View {
    
    
    @Environment(\.modelContext) private var context
    @Environment(\.colorScheme) private var scheme
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedCategoryName: String? = nil
    @Query(sort: [SortDescriptor(\CategoryModel.name, order: .forward)])
    private var categories: [CategoryModel]
    
    @State private var showSaveAlert = false
    @State private var alertMessage = ""
    
    let editTarget: EntryModel?
    
    init(editTarget: EntryModel? = nil) {
        self.editTarget = editTarget
    }
    
    
    // MARK: - 저장 로직
    private func handleSave(title: String, body: AttributedString, date: Date) {
        guard let categoryName = selectedCategoryName, !categoryName.isEmpty else {
            alertMessage = "카테고리를 선택하세요."
            showSaveAlert = true
            return
        }
        guard let categoryModel = categories.first(where: { $0.name == categoryName }) else {
            alertMessage = "선택한 카테고리를 찾을 수 없어요."
            showSaveAlert = true
            return
        }
        guard !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            alertMessage = "Title을 입력하세요."
            showSaveAlert = true
            return
        }
        
        do {
            if let target = editTarget {
                // 수정 모드: 카테고리 및 서식 포함 본문 업데이트
                target.category = categoryModel
                try EntryCRUD.update(
                    context: context,
                    target,
                    editTitle: title,
                    editBody: body
                )
            } else {
                // 생성 모드: 서식 포함 본문과 카테고리 함께 저장
                try EntryCRUD.create(
                    context: context,
                    title: title,
                    createdAt: date,
                    body: body,
                    category: categoryModel
                )
            }
            dismiss()
        } catch {
            alertMessage = "저장 중 오류가 발생했어요. 다시 시도해 주세요."
            showSaveAlert = true
        }
    }

    // MARK: - MainPage 색상 팔레트
    private var appBackground: Color {
        scheme == .dark
        ? Color(red: 28/255, green: 28/255, blue: 30/255)
        : Color(red: 53/255, green: 53/255, blue: 53/255)
    }
    private var listBackground: Color {
        scheme == .dark ? Color.black.opacity(0.05) : Color.white
    }
    private var textBackground: Color {
        scheme == .dark ? Color.white : Color.white
    }
    private var dateBackground: Color {
        scheme == .dark
        ? Color(red: 158/255, green: 158/255, blue: 159/255)
        : Color(red: 158/255, green: 158/255, blue: 159/255)
    }
    private var cardBackground: Color {
        scheme == .dark
        ? Color(red: 44/255, green: 44/255, blue: 46/255)
        : appBackground
    }
    private var primaryText: Color {
        .black
    }
    private var secondaryText: Color {
        Color.black.opacity(0.6)
    }
    private var inverseOnCard: Color {
        .white
    }

    var body: some View {
        // 편집 모드일 때 초기값 준비
        let initialTitle: String = editTarget?.title ?? ""
        let initialBody: AttributedString = editTarget?.attributedContent ?? ""
        let initialDate: Date = editTarget?.createdAt ?? .now

        NavigationView {
            ZStack {
                appBackground.ignoresSafeArea()

                VStack(spacing: 0) {
                    Text("메모")
                        .font(.headline).fontWeight(.semibold)
                        .foregroundStyle(.white)
                        .padding(.bottom, 30)
                        .offset(y: -43)
                    // MARK: 상단 헤더
                    VStack(spacing: 12) {
                        HStack {
                            Menu {
                                Button("전체") { selectedCategoryName = nil }
                                ForEach(categories, id: \.self) { cate in
                                    Button {
                                        selectedCategoryName = (selectedCategoryName == cate.name) ? nil : cate.name
                                    } label: {
                                        HStack {
                                            Text(cate.name)
                                            if selectedCategoryName == cate.name {
                                                Spacer()
                                                Image(systemName: "checkmark")
                                            }
                                        }
                                    }
                                }
                            } label: {
                                HStack(spacing: 4) {
                                    Text(selectedCategoryName ?? "카테고리 선택")
                                        .font(.title).bold()
                                    Image(systemName: "chevron.down")
                                        .font(.system(size: 20, weight: .semibold))
                                        .offset(y: 2)
                                }
                                .foregroundStyle(.white)
                                .contentShape(Rectangle())
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding(.horizontal)
                        .padding(.top, 8)
                        .padding(.bottom, 8)
                    }
                    .background(appBackground)
                    .padding(10)

                    // MARK: 본문 영역
                    DateHeaderAndEditor(
                        initialTitle: initialTitle,
                        initialBody: initialBody,
                        initialDate: initialDate,
                        dateString: "2025.10.14",
                        colors: EditorColors(
                            appBackground: appBackground,
                            listBackground: listBackground,
                            textBackground: textBackground,
                            dateBackground: dateBackground,
                            cardBackground: cardBackground,
                            primaryText: primaryText,
                            secondaryText: secondaryText,
                            inverseOnCard: inverseOnCard
                        ),
                        onSave: { title, body, date in
                            handleSave(title: title, body: body, date: date)
                        }
                    )
                }
            }
            .onAppear {
                // 편집 모드면 카테고리 초기 선택값 채우기
                if let c = editTarget?.category?.name {
                    selectedCategoryName = c
                }
            }
            .alert("저장할 수 없어요", isPresented: $showSaveAlert) {
                Button("확인", role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
        }
    }
}

// MARK: - 색상 전달 구조체
struct EditorColors {
    let appBackground: Color
    let listBackground: Color
    let textBackground: Color
    let dateBackground: Color
    let cardBackground: Color
    let primaryText: Color
    let secondaryText: Color
    let inverseOnCard: Color
}

// MARK: - DateHeaderAndEditor
struct DateHeaderAndEditor: View {
    // 초기 주입 값들 (수정 모드일 때 사용)
    let initialTitle: String
    let initialBody: AttributedString
    let initialDate: Date

    let dateString: String
    let colors: EditorColors

    @State private var attributedText: AttributedString = ""
    @State private var textSelection = AttributedTextSelection()
    @State private var title: String = ""
    @State private var date: Date = .now
    @State private var didPrefill = false

    var onSave: (_ title: String, _ body: AttributedString, _ date: Date) -> Void

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                Rectangle()
                    .fill(colors.dateBackground)
                    .clipShape(TopRoundedRectangle(cornerRadius: 30))

                DatePicker(
                    "",
                    selection: $date,
                    displayedComponents: [.date]
                )
                .labelsHidden()
                .datePickerStyle(.compact)
                .tint(colors.primaryText)
                .foregroundStyle(colors.primaryText)
            }
            .frame(height: 40)

            ZStack(alignment: .topLeading) {
                colors.textBackground
                    .frame(height: 50)
                if title.isEmpty {
                    Text("Title")
                        .foregroundStyle(colors.secondaryText)
                        .padding(.top, 15)
                        .padding(.horizontal, 15)
                }
                TextField("", text: $title)
                    .font(.system(size: 17))
                    .padding(.top, 15)
                    .padding(.horizontal, 15)
                    .foregroundStyle(.black)
                    .textInputAutocapitalization(.sentences)
            }

            Divider()
                .frame(height: 1)
                .background(colors.secondaryText.opacity(0.3))

            ZStack(alignment: .topLeading) {
                colors.textBackground

                if attributedText.characters.isEmpty {
                    Text("Text")
                        .foregroundStyle(colors.secondaryText)
                        .padding(.top, 15)
                        .padding(.horizontal, 15)
                }
                EditorView(
                    text: $attributedText,
                    selection: $textSelection,
                    onSave: { onSave(title, attributedText, date) },
                    textColor: colors.primaryText
                )
                .font(.system(size: 17))
                .padding(.top, 7)
                .padding(.horizontal, 10)
                .scrollContentBackground(.hidden)
                .background(Color.clear)
            }
        }
        .onAppear {
            // 최초 1회만 편집 초기값을 채워줌
            if !didPrefill {
                title = initialTitle
                attributedText = initialBody
                date = initialDate
                didPrefill = true
            }
        }
        .mask(RoundedRectangle(cornerRadius: 0, style: .continuous))
        .ignoresSafeArea(.container, edges: .bottom)
        .compositingGroup()
        .shadow(color: .black.opacity(0.03), radius: 2, y: 1)
        .background(colors.appBackground)
        .safeAreaInset(edge: .bottom, spacing: 0) {
            BottomSafeAreaBackground(color: colors.textBackground)
        }
    }
}

private struct BottomSafeAreaBackground: View {
    let color: Color
    var body: some View {
        GeometryReader { geo in
            color
                .frame(height: geo.safeAreaInsets.bottom)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                .ignoresSafeArea()
        }
        .frame(height: 0)
    }
}

// MARK: - Shape
struct TopRoundedRectangle: Shape {
    var cornerRadius: CGFloat = 16
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: cornerRadius))
        path.addArc(center: CGPoint(x: cornerRadius, y: cornerRadius),
                    radius: cornerRadius,
                    startAngle: .degrees(180), endAngle: .degrees(270), clockwise: false)
        path.addLine(to: CGPoint(x: rect.width - cornerRadius, y: 0))
        path.addArc(center: CGPoint(x: rect.width - cornerRadius, y: cornerRadius),
                    radius: cornerRadius,
                    startAngle: .degrees(270), endAngle: .degrees(0), clockwise: false)
        path.addLine(to: CGPoint(x: rect.width, y: rect.height))
        path.addLine(to: CGPoint(x: 0, y: rect.height))
        path.closeSubpath()
        return path
    }
}

// MARK: - RichText Editor
struct EditorView: View {
    @Environment(\.fontResolutionContext) var fontResolutionContext
    @Binding var text: AttributedString
    @Binding var selection: AttributedTextSelection

    var onSave: () -> Void
    let textColor: Color

    var body: some View {
        TextEditor(text: $text, selection: $selection)
            .foregroundStyle(textColor)
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Button("Bold", systemImage: "bold") {
                        text.transformAttributes(in: &selection) { container in
                            let current = container.font ?? .default
                            let resolved = current.resolve(in: fontResolutionContext)
                            container.font = current.bold(!resolved.isBold)
                        }
                    }
                    Button("Italic", systemImage: "italic") {
                        text.transformAttributes(in: &selection) { container in
                            let current = container.font ?? .default
                            let resolved = current.resolve(in: fontResolutionContext)
                            container.font = current.italic(!resolved.isItalic)
                        }
                    }
                    Button("Underline", systemImage: "underline") {
                        text.transformAttributes(in: &selection) { container in
                            container.underlineStyle = (container.underlineStyle == .single) ? .none : .single
                        }
                    }
                    Button("Strikethrough", systemImage: "strikethrough") {
                        text.transformAttributes(in: &selection) { container in
                            container.strikethroughStyle = (container.strikethroughStyle == .single) ? .none : .single
                        }
                    }
                    Spacer()
                    Button {
                        onSave()
                    } label: {
                        Label("Done", systemImage: "square.and.pencil")
                    }
                }
            }
    }
}

#Preview {
    ContentView()
}
