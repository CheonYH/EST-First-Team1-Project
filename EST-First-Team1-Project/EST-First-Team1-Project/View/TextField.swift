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

    @State private var selectedCategoryName: String? = nil
    private let categories = ["여행", "메모", "할 일", "운동"]

    @State private var showSaveAlert = false
    @State private var alertMessage = ""

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
        scheme == .dark ? Color.white/*.opacity(0.95)*/ : Color.white/*.opacity(0.95)*/
    }
    private var dateBackground: Color {
        scheme == .dark
        ? Color(red: 163/255, green: 163/255, blue: 163/255)
        : Color(red: 163/255, green: 163/255, blue: 163/255)
    }
    private var cardBackground: Color {
        scheme == .dark
        ? Color(red: 44/255, green: 44/255, blue: 46/255)
        : appBackground
    }
    private var primaryText: Color {
        scheme == .dark ? .black : .black
    }
    private var secondaryText: Color {
        scheme == .dark ? Color.black.opacity(0.6) : Color.black.opacity(0.6)
    }
    private var inverseOnCard: Color {
        scheme == .dark ? .white : .white
    }

    var body: some View {
        NavigationView {
            ZStack {
                appBackground.ignoresSafeArea()

                VStack(spacing: 0) {
                    // MARK: 상단 헤더
                    VStack(spacing: 12) {
                        Text("메모")
                            .font(.headline).fontWeight(.semibold)
                            .foregroundStyle(.white)
                            .padding(.bottom, 30)
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
                    .padding(10) // 카테고리 타이틀-Date메뉴 사이 패딩

                    // MARK: 본문 영역
                    DateHeaderAndEditor(
                        dateString: "2025.10.14", // 시그니처 유지용(표시는 DatePicker가 담당)
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
//            .toolbar {
//                ToolbarItemGroup(placement: .topBarLeading) {
//                    Button { } label: {
//                        Label("dismiss", systemImage: "chevron.left")
//                            .foregroundStyle(.white)
//                    }
//                }
//                ToolbarItem(placement: .principal) {
//                    Text("메모")
//                        .font(.headline).fontWeight(.semibold)
//                        .foregroundStyle(.white)
//                }
//            }
            .alert("저장할 수 없어요", isPresented: $showSaveAlert) {
                Button("확인", role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
        }
    }

    // MARK: - 저장 로직
    private func handleSave(title: String, body: AttributedString, date: Date) {
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

        let note = Note(title: title, category: category, body: body, createdAt: date)
        context.insert(note)
        do {
            try context.save()
        } catch {
            alertMessage = "저장 중 오류가 발생했어요. 다시 시도해 주세요."
            showSaveAlert = true
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
    let dateString: String
    let colors: EditorColors

    @State private var attributedText: AttributedString = ""
    @State private var textSelection = AttributedTextSelection()
    @State private var title: String = ""
    @State private var date: Date = .now

    var onSave: (_ title: String, _ body: AttributedString, _ date: Date) -> Void

    var body: some View {
        VStack(spacing: 0) {
            // 날짜 헤더 & DatePicker(기본 today)
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

            // Title Field (커스텀 플레이스홀더)
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

            // Rich Text Editor (커스텀 플레이스홀더 동일 색상)
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
                .padding(.top, 15 - 8)
                .padding(.horizontal, 15 - 5)
                .scrollContentBackground(.hidden)
                .background(Color.clear)
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
