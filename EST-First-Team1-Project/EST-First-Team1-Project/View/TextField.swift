//
//  TextField.swift
//  EST-First-Team1-Project
//
//  Created by 김대현 on 10/16/25.
//

import SwiftUI
import SwiftData

// MARK: - 색상 전달 구조체
struct EditorColors {
    let textBackground: Color
    let dateBackground: Color
    let primaryText: Color
    let secondaryText: Color
}


// MARK: - ContentView
struct ContentView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.colorScheme) private var scheme
    @Environment(\.dismiss) private var dismiss
    
    @Query(sort: [SortDescriptor(\CategoryModel.name, order: .forward)])
    private var categories: [CategoryModel]
    
    @State private var selectedCategoryName: String? = nil
    @State private var showSaveAlert = false
    @State private var alertMessage = ""
    
    let editTarget: EntryModel?
    
    init(editTarget: EntryModel? = nil) {
        self.editTarget = editTarget
    }
    
    
    // MARK: - 저장 로직
    private func showAlert(_ message: String) {
        alertMessage = message
        showSaveAlert = true
    }
    
    private func handleSave(title: String, body: AttributedString, date: Date) {
            guard let name = selectedCategoryName, !name.isEmpty else {
                return showAlert("카테고리를 선택하세요.")
            }
            guard let categoryModel = categories.first(where: { $0.name == name }) else {
                return showAlert("선택한 카테고리를 찾을 수 없어요.")
            }
            guard !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                return showAlert("Title을 입력하세요.")
            }

            do {
                if let target = editTarget {
                    target.category = categoryModel
                    try EntryCRUD.update(context: context, target, editTitle: title, editBody: body)
                } else {
                    try EntryCRUD.create(context: context, title: title, createdAt: date, body: body, category: categoryModel)
                }
                dismiss()
            } catch {
                showAlert("저장 중 오류가 발생했어요. 잠시 후에 다시 시도해 주세요.")
            }
        }

    
    // MARK: - MainPage 색상 팔레트
    private var appBackground: Color {
        scheme == .dark
        ? Color(red: 28/255, green: 28/255, blue: 30/255)
        : Color(red: 53/255, green: 53/255, blue: 53/255)
    }
    private var textBackground: Color { .white }
    private var dateBackground: Color {
        Color(red: 158/255, green: 158/255, blue: 159/255)
    }
    private var primaryText: Color { .black }
    private var secondaryText: Color { Color.black.opacity(0.6) }
    var body: some View {
        let initialTitle: String = editTarget?.title ?? ""
        let initialBody: AttributedString = editTarget?.attributedContent ?? ""
        let initialDate: Date = editTarget?.createdAt ?? .now

        NavigationStack {
            ZStack {
                appBackground.ignoresSafeArea()

                VStack(spacing: 0) {
                    // MARK: 카테고리명 드롭다운
                    VStack(spacing: 12) {
                        HStack {
                            Menu {
                                if categories.isEmpty {
                                    Button("카테고리가 없습니다") {
                                        selectedCategoryName = nil
                                    }
                                } else {
                                    ForEach(categories, id: \.persistentModelID) { cate in
                                        let color = Color.from255(r: cate.r, g: cate.g, b: cate.b)
                                        Button {
                                            selectedCategoryName = (selectedCategoryName == cate.name) ? nil : cate.name
                                        } label: {
                                            HStack {
                                                Image(systemName: cate.icon)
                                                    .foregroundStyle(color)
                                                Text(cate.name)
                                                if selectedCategoryName == cate.name {
                                                    Spacer()
                                                    Image(systemName: "checkmark")
                                                        .foregroundStyle(color)
                                                }
                                            }
                                        }
                                    }
                                }
                            } label: {
                                HStack(spacing: 8) {
                                    if let selectedName = selectedCategoryName,
                                       let current = categories.first(where: { $0.name == selectedName }) {
                                        let color = Color.from255(r: current.r, g: current.g, b: current.b)
                                        Image(systemName: current.icon)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 26, height: 26)
                                            .foregroundStyle(color)
                                        Text(current.name)
                                            .font(.title.bold())
                                            .lineLimit(1)
                                            .truncationMode(.tail)
                                    } else {
                                        Image("star")
                                            .renderingMode(.template)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 26, height: 26)
                                            .foregroundStyle(.white.opacity(0.9))
                                        Text("카테고리 선택")
                                            .font(.title.bold())
                                    }
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
                        .padding(.vertical, 8)
                    }
                    .background(appBackground)
                    .padding(10)

                    // MARK: 본문 영역
                    DateHeaderAndEditor(
                        initialTitle: initialTitle,
                        initialBody: initialBody,
                        initialDate: initialDate,
                        colors: EditorColors(
                            textBackground: textBackground,
                            dateBackground: dateBackground,
                            primaryText: primaryText,
                            secondaryText: secondaryText,
                        ),
                        onSave: { title, body, date in
                            handleSave(title: title, body: body, date: date)
                        }
                    )
                }
                .safeAreaInset(edge: .top) {
                    Color.clear.frame(height: 30)
                }
            }
            .onAppear {
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
        .navigationTitle("메모")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarBackground(appBackground, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }
}


// MARK: - DateHeaderAndEditor
struct DateHeaderAndEditor: View {

    @State private var attributedText: AttributedString
    @State private var textSelection = AttributedTextSelection()
    @State private var title: String = ""
    @State private var date: Date = .now

    let colors: EditorColors
    var onSave: (_ title: String, _ body: AttributedString, _ date: Date) -> Void
    
    init(
        initialTitle: String,
        initialBody: AttributedString,
        initialDate: Date,
        colors: EditorColors,
        onSave: @escaping (_ title: String, _ body: AttributedString, _ date: Date) -> Void
    ) {
        _title = State(initialValue: initialTitle)
        _attributedText = State(initialValue: initialBody)
        _date = State(initialValue: initialDate)
        self.colors = colors
        self.onSave = onSave
    }

    var body: some View {
        VStack(spacing: 0) {
            DatePicker("", selection: $date, displayedComponents: [.date])
                .labelsHidden()
                .environment(\.colorScheme, .light)
                .tint(colors.primaryText)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 5)
                .background(colors.dateBackground)
                .clipShape(
                        UnevenRoundedRectangle(topLeadingRadius: 30, topTrailingRadius: 30)
                    )
            

            ZStack(alignment: .topLeading) {
                colors.textBackground.frame(height: 50)
                TextField("",
                          text: $title,
                          prompt: Text("Title").foregroundStyle(colors.secondaryText))
                    .font(.system(size: 17))
                    .padding(.top, 15)
                    .padding(.horizontal, 15)
                    .foregroundStyle(.black)
                    .autocorrectionDisabled(true)
            }

            Divider()

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
        .ignoresSafeArea(.container, edges: .bottom)
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
                .ignoresSafeArea(edges: .bottom)
        }
        .frame(height: 0)
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
