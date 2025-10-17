//
//  TextField.swift
//  EST-First-Team1-Project
//
//  Created by 김대현 on 10/16/25.
//

import SwiftUI
import SwiftData

// SwiftData
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

struct ContentView: View {
    // SwiftData 컨텍스트 (저장용)
    @Environment(\.modelContext) private var context

    @State private var selectedCategoryName: String? = nil
    private let categories = ["여행", "메모", "할 일", "운동"]

    // 저장 실패 알림
    @State private var showSaveAlert = false
    @State private var alertMessage = ""

    var body: some View {
        NavigationView {
            VStack {
                // ===== 상단 타이틀 + 드롭다운 버튼 =====
                HStack {
                    Menu {
                        Button("전체") { selectedCategoryName = nil }
                        ForEach(categories, id: \.self) { name in
                            Button {
                                if selectedCategoryName == name {
                                    selectedCategoryName = nil
                                } else {
                                    selectedCategoryName = name
                                }
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
                                .font(.largeTitle)
                                .bold()
                            Image(systemName: "chevron.down")
                                .font(.system(size: 20, weight: .semibold))
                                .offset(y: 2)
                        }
                        .foregroundStyle(.black)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    .padding(.top, 8)
                }

                // ===== 본문 =====
                DateHeaderAndEditor(
                    dateString: "2025.10.14",
                    onSave: { title, body in
                        handleSave(title: title, body: body)
                    }
                )
            }
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

// 저장 로직 (검증 포함)
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

// 2) 실제 저장 (SwiftData)
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

// 텍스트 박스 구역
struct DateHeaderAndEditor: View {
    let dateString: String

    // 내부 상태
    @State private var attributedText: AttributedString = ""
    @State private var textSelection = AttributedTextSelection()
    @State private var title: String = ""

    // 저장 트리거 (부모로 title/body 전달)
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
            VStack {
                ZStack(alignment: .topLeading) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.15))
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)

                    TextField("Title", text: $title)
                        .font(.system(size: 17))
                        .padding(.top, 15)
                        .padding(.horizontal, 15)
                        .foregroundStyle(.black)
                }
            }

            Divider()
                .frame(height: 1)
                .background(Color.gray.opacity(0.3))

            // Rich Text Editor
            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 0, style: .continuous)
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
                    title: $title,
                    onSave: { onSave(title, attributedText) } // ← 여기서 부모로 전달
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
        .frame(maxHeight: .infinity, alignment: .top)
        .ignoresSafeArea(.container, edges: .bottom)
        .compositingGroup()
        .shadow(color: .black.opacity(0.03), radius: 2, y: 1)
    }
}

// 상단 둥근 사각형
struct TopRoundedRectangle: Shape {
    var cornerRadius: CGFloat = 16

    func path(in rect: CGRect) -> Path {
        var path = Path()
        // 상단 좌/우만 둥글게 처리
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

// RichText 에디터
struct EditorView: View {
    @Environment(\.fontResolutionContext) var fontResolutionContext
    @Binding var text: AttributedString
    @Binding var selection: AttributedTextSelection

    // Title도 같이 받아서 저장 시 사용
    @Binding var title: String

    // 저장 트리거
    var onSave: () -> Void

    // (옵션) 색상 피커 복원하려면 사용
    @State private var textColor = Color(.sRGB, red: 0.98, green: 0.9, blue: 0.2)

    var body: some View {
        VStack {
            TextEditor(text: $text, selection: $selection)
                .toolbar {
                    ToolbarItemGroup(placement: .keyboard) {
                        Button("Bold", systemImage: "bold") {
                            text.transformAttributes(in: &selection) { container in
                                let currentFont = container.font ?? .default
                                let resolved = currentFont.resolve(in: fontResolutionContext)
                                container.font = currentFont.bold(!resolved.isBold)
                            }
                        }
                        Button("Italic", systemImage: "italic") {
                            text.transformAttributes(in: &selection) { container in
                                let currentFont = container.font ?? .default
                                let resolved = currentFont.resolve(in: fontResolutionContext)
                                container.font = currentFont.italic(!resolved.isItalic)
                            }
                        }
                        Button("Underline", systemImage: "underline") {
                            text.transformAttributes(in: &selection) { container in
                                if container.underlineStyle == .single {
                                    container.underlineStyle = .none
                                } else {
                                    container.underlineStyle = .single
                                }
                            }
                        }
                        Button("Strikethrough", systemImage: "strikethrough") {
                            text.transformAttributes(in: &selection) { container in
                                if container.strikethroughStyle == .single {
                                    container.strikethroughStyle = .none
                                } else {
                                    container.strikethroughStyle = .single
                                }
                            }
                        }
                        // ColorPicker("Text Color", selection: $textColor).labelsHidden()

                        Spacer()

                        // ✅ 저장 & 완료
                        Button {
                            onSave()
                        } label: {
                            Label("Done", systemImage: "square.and.pencil")
                        }
                    }
                }
        }
    }
}

// 편의 생성자 (selection 불필요)
extension EditorView {
    init(text: Binding<AttributedString>, title: Binding<String>, onSave: @escaping () -> Void) {
        self._text = text
        self._selection = .constant(AttributedTextSelection())
        self._title = title
        self.onSave = onSave
    }
}

#Preview {
    ContentView()
}
