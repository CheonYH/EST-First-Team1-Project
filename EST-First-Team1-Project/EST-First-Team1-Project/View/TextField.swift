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

    @State private var selectedCategoryName: String? = nil
    private let categories = ["여행", "메모", "할 일", "운동"]

    @State private var showSaveAlert = false
    @State private var alertMessage = ""

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // 상단 타이틀 + 드롭다운 버튼
                HStack {
                    Menu {
                        Button("전체") { selectedCategoryName = nil }

                        ForEach(categories, id: \.self) { name in
                            Button {
                                selectedCategoryName = (selectedCategoryName == name) ? nil : name
                            } label: {
                                HStack {
                                    Text(name)
                                    if selectedCategoryName == name {
                                        Spacer()
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Text(selectedCategoryName ?? "카테고리를 선택하세요")
                                .font(.title)
                                .bold()
                            Image(systemName: "chevron.down")
                                .font(.system(size: 20, weight: .semibold))
                                .offset(y: 2)
                        }
                        .foregroundStyle(.black)
                        .contentShape(Rectangle()) // 터치 영역 향상
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.horizontal)
                .padding(.top, 8)

                // 본문
                DateHeaderAndEditor(
                    dateString: "2025.10.14",
                    onSave: { title, body in
                        handleSave(title: title, body: body)
                    }
                )
            }
            .padding(.top, 60) // 상단 안전영역과 간격
            .toolbar {
                ToolbarItemGroup(placement: .topBarLeading) {
                    Button { } label: {
                        Label("dismiss", systemImage: "chevron.left")
                    }
                }
            }
            .alert("저장할 수 없어요", isPresented: $showSaveAlert) {
                Button("확인", role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
        }
    }

    // MARK: 저장 로직 (검증 포함)
    private func handleSave(title: String, body: AttributedString) {
        // 1) 검증
        guard let category = selectedCategoryName, !category.isEmpty else {
            alertMessage = "카테고리를 선택하세요."
            showSaveAlert = true
            return
        }
        guard !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            alertMessage = "Title을 입력하세요."
            showSaveAlert = true
            return
        }

        // 2) 저장
        let note = Note(title: title, category: category, body: body)
        context.insert(note)
        do {
            try context.save()
        } catch {
            alertMessage = "저장 중 오류가 발생했어요. 다시 시도해 주세요."
            showSaveAlert = true
        }
    }
}

// MARK: - DateHeaderAndEditor
struct DateHeaderAndEditor: View {
    let dateString: String

    @State private var attributedText: AttributedString = ""
    @State private var textSelection = AttributedTextSelection()
    @State private var title: String = ""

    var onSave: (_ title: String, _ body: AttributedString) -> Void

    var body: some View {
        VStack(spacing: 0) {

            // Header
            ZStack {
                Rectangle()
                    .fill(.gray.opacity(0.25))
                    .clipShape(TopRoundedRectangle(cornerRadius: 30))
                Text(dateString)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.black.opacity(0.8))
            }
            .frame(height: 40)

            // Title Field
            ZStack(alignment: .topLeading) {
                Rectangle()
                    .fill(Color.gray.opacity(0.15))
                    .frame(height: 50)

                TextField("Title", text: $title)
                    .font(.system(size: 17))
                    .padding(.top, 15)
                    .padding(.horizontal, 15)
                    .foregroundStyle(.black)
                    .textInputAutocapitalization(.sentences)
            }

            Divider()
                .frame(height: 1)
                .background(Color.gray.opacity(0.3))

            // Rich Text Editor
            ZStack(alignment: .topLeading) {
                Rectangle()
                    .fill(Color.gray.opacity(0.15))

                if attributedText.characters.isEmpty {
                    Text("Text")
                        .foregroundStyle(.gray.opacity(0.6))
                        .padding(.top, 15)
                        .padding(.horizontal, 15)
                }

                EditorView(
                    text: $attributedText,
                    selection: $textSelection,
                    onSave: { onSave(title, attributedText) }
                )
                .font(.system(size: 17))
                .padding(.top, 15)
                .padding(.horizontal, 15)
                .scrollContentBackground(.hidden)
                .background(Color.clear)
                .foregroundStyle(.black)
            }
        }
        .mask(RoundedRectangle(cornerRadius: 0, style: .continuous))
        .ignoresSafeArea(.container, edges: .bottom)
        .compositingGroup()
        .shadow(color: .black.opacity(0.03), radius: 2, y: 1)
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
                    startAngle: .degrees(180),
                    endAngle: .degrees(270),
                    clockwise: false)
        path.addLine(to: CGPoint(x: rect.width - cornerRadius, y: 0))
        path.addArc(center: CGPoint(x: rect.width - cornerRadius, y: cornerRadius),
                    radius: cornerRadius,
                    startAngle: .degrees(270),
                    endAngle: .degrees(0),
                    clockwise: false)
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

    var body: some View {
        TextEditor(text: $text, selection: $selection)
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
