//
//  TextField.swift
//  EST-First-Team1-Project
//
//  Created by 김대현 on 10/16/25.
//

import SwiftUI
import SwiftData

// MARK: - TextField

/// # Overview
/// BoxUp의 **회고(메모) 작성 및 편집 화면**입니다.
/// 카테고리 선택, 제목/본문 입력, 날짜 지정, 서식 편집, 저장 기능을 제공합니다.
///
/// # Discussion
/// - 본문은 ``AttributedString`` 기반으로 저장되어 Bold, Italic 등 텍스트 서식이 유지됩니다.
/// - **카테고리 메뉴**는 SwiftData의 카테고리 목록을 반영합니다.
/// - **저장 버튼**을 통해 SwiftData에 저장됩니다.
/// - 키보드 상단 툴바는 Bold, Italic, Underline, Strikethrough, Done 기능을 제공합니다.
/// - UI 및 Color Scheme은 Main Page에 맞춰져 있습니다.

// MARK: - 색상 전달 구조체

/// 에디터 화면 전반에서 사용하는 색상 팔레트
///
/// - Note: 라이트/다크 전환은 상위에서 값을 주입해 처리합니다
/// - SeeAlso: ``ContentView/colors`` (계산 프로퍼티 예시)
struct EditorColors {
    /// 본문/제목 영역의 배경 색상
    let textBackground: Color
    /// 상단 날짜 선택 영역의 배경 색상
    let dateBackground: Color
    /// 일반 텍스트(전경) 색상
    let primaryText: Color
    /// Placeholder/부가 텍스트 색상
    let secondaryText: Color
}


// MARK: - ContentView

/// 회고(엔트리) 생성/수정 화면
/// - Features:
///   - 카테고리 선택, 제목/AttributedString 본문, 날짜 선택
///   - `EntryCRUD`를 통한 생성/수정
///   - 저장 실패/검증 실패에 대한 Alert 표시
/// - Dependencies:
///   - `EntryModel`, `CategoryModel`, `EntryCRUD`, `Color.from255(r:g:b:)`
/// - Threading: SwiftUI 메인 스레드에서 동작
struct ContentView: View {
    // MARK: Environment

    /// SwiftData를 위한 모델 컨텍스트
    @Environment(\.modelContext) private var context
    /// 라이트/다크 모드 감지용 컬러 스킴
    @Environment(\.colorScheme) private var scheme
    /// 저장 성공 시 화면을 닫기 위해 사용합니다
    @Environment(\.dismiss) private var dismiss
    
    // MARK: Data Source
    
    /// 사전 생성된 카테고리 목록(이름 오름차순)
    @Query(sort: [SortDescriptor(\CategoryModel.name, order: .forward)])
    private var categories: [CategoryModel]
    
    // MARK: UI State
    
    /// 선택된 카테고리 이름. `nil`이면 선택 안 됨
    @State private var selectedCategoryName: String? = nil
    /// Alert 표시 여부
    @State private var showSaveAlert = false
    /// Alert 본문 메시지
    @State private var alertMessage = ""
    
    // MARK: Editing Target
    
    /// 수정 모드인 경우 주입되는 엔트리. `nil`이면 생성 모드.
    let editTarget: EntryModel?
    
    /// - Parameter editTarget: 수정할 엔트리. 기본값 `nil`(신규 생성 모드)
    init(editTarget: EntryModel? = nil) {
        self.editTarget = editTarget
    }
    
    
    // MARK: - 저장 로직
    
    /// Alert을 표시합니다.
    /// - Parameter message: 사용자에게 보여줄 메시지
    private func showAlert(_ message: String) {
        alertMessage = message
        showSaveAlert = true
    }
    
    /// 입력값을 검증하고 엔트리를 생성/수정합니다.
    ///
    /// - Parameters:
    ///   - title: 제목(공백 제거 후 비어 있지 않아야 함)
    ///   - body: 서식 포함 본문(`AttributedString`)
    ///   - date: 생성일(신규 생성 시 사용)
    ///
    /// - Behavior:
    ///   - 카테고리를 선택하지 않았거나 제목이 비어 있으면 Alert 표시 후 반환
    ///   - `editTarget`이 있으면 업데이트, 없으면 생성
    ///   - 성공 시 `dismiss()` 호출로 화면을 종료
    ///
    /// - Errors:
    ///   - `EntryCRUD` 내부에서 throw 시 Alert로 에러 안내
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

    
    // MARK: - 색상 팔레트

    /// 화면 배경(라이트/다크 대응), Main Page와 동일한 톤 유지
    private var appBackground: Color {
        scheme == .dark
        ? Color(red: 28/255, green: 28/255, blue: 30/255)
        : Color(red: 53/255, green: 53/255, blue: 53/255)
    }
    /// 텍스트 입력 영역 배경
    private var textBackground: Color { .white }
    /// 날짜 선택 영역 배경.
    private var dateBackground: Color {
        Color(red: 158/255, green: 158/255, blue: 159/255)
    }
    /// 기본 전경 텍스트 색상
    private var primaryText: Color { .black }
    /// 보조 전경 텍스트 색상(placeholder 등)
    private var secondaryText: Color { Color.black.opacity(0.6) }
    
    var body: some View {
        // 편집 모드 초기값 구성
        let initialTitle: String = editTarget?.title ?? ""
        let initialBody: AttributedString = editTarget?.attributedContent ?? ""
        let initialDate: Date = editTarget?.createdAt ?? .now

        NavigationStack {
            ZStack {
                appBackground.ignoresSafeArea()

                VStack(spacing: 0) {
                    // MARK: 카테고리 선택 메뉴
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
                                            // 같은 항목을 다시 선택하면 선택 해제
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

                    // MARK: 본문/제목/날짜 영역
                    DateHeaderAndEditor(
                        initialTitle: initialTitle,
                        initialBody: initialBody,
                        initialDate: initialDate,
                        colors: EditorColors(
                            textBackground: textBackground,
                            dateBackground: dateBackground,
                            primaryText: primaryText,
                            secondaryText: secondaryText
                        ),
                        onSave: { title, body, date in
                            handleSave(title: title, body: body, date: date)
                        }
                    )
                }
                // 상단 여백 보정(내비 타이틀 높이만큼)
                .safeAreaInset(edge: .top) {
                    Color.clear.frame(height: 30)
                }
            }
            .onAppear {
                // 편집 모드면 선택된 카테고리를 초기 표시
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

/// 날짜 선택 + 제목(TextField) + 본문(TextEditor)로 구성된 에디팅 섹션.
///
/// - Initialization:
///   `initialTitle`, `initialBody`, `initialDate`를 State 초기값으로 바인딩합니다
/// - Saving:
///   툴바의 "Done" 또는 외부에서 전달된 저장 트리거에서 `onSave` 콜백을 호출합니다
struct DateHeaderAndEditor: View {

    /// 서식 포함 본문 상태.
    @State private var attributedText: AttributedString
    /// 본문 선택 영역(서식 토글 시 사용).
    @State private var textSelection = AttributedTextSelection()
    /// 제목 상태.
    @State private var title: String = ""
    /// 날짜 상태.
    @State private var date: Date = .now

    /// 색상 팔레트.
    let colors: EditorColors
    /// 저장 콜백. 상위 뷰에서 CRUD를 수행합니다
    var onSave: (_ title: String, _ body: AttributedString, _ date: Date) -> Void
    
    /// - Parameters:
    ///   - initialTitle: 초기 제목
    ///   - initialBody: 초기 본문(AttributedString)
    ///   - initialDate: 초기 날짜
    ///   - colors: 에디터 색상 팔레트
    ///   - onSave: 저장 시 호출되는 콜백
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
            // 날짜 선택기
            DatePicker("", selection: $date, displayedComponents: [.date])
                .labelsHidden()
                .environment(\.colorScheme, .light) // iOS 기본 DatePicker 외관 고정(디자인 선택)
                .tint(colors.primaryText)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 5)
                .background(colors.dateBackground)
                .clipShape(
                    UnevenRoundedRectangle(topLeadingRadius: 30, topTrailingRadius: 30)
                )
            
            // 제목 입력
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

            // 본문 입력(Attributed)
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
        // 하단 홈 인디케이터 영역과 시각적으로 맞추기 위한 보정
        .ignoresSafeArea(.container, edges: .bottom)
        .safeAreaInset(edge: .bottom, spacing: 0) {
            BottomSafeAreaBackground(color: colors.textBackground)
        }
    }
}

private struct BottomSafeAreaBackground: View {
    /// 하단(홈 인디케이터) 여백을 채울 배경 색상.
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

/// `AttributedString` 기반의 리치 텍스트 에디터.
///
/// - Features:
///   - Bold/Italic/Underline/Strikethrough 토글
///   - 키보드 상단 툴바에 "Done" 버튼 제공
/// - Parameters:
///   - text: 편집할 `AttributedString` 바인딩
///   - selection: 현재 텍스트 선택 범위 바인딩(서식 적용 대상)
///   - onSave: 저장 트리거 콜백
///   - textColor: 에디터 전경 텍스트 색상 - textColor 변경 미구현
struct EditorView: View {
    @Environment(\.fontResolutionContext) var fontResolutionContext
    /// 편집 중 본문(서식 포함).
    @Binding var text: AttributedString
    /// 현재 선택 범위.
    @Binding var selection: AttributedTextSelection

    /// 저장 트리거 콜백
    var onSave: () -> Void
    /// 전경 텍스트 색상 - 미구현
    let textColor: Color

    var body: some View {
        TextEditor(text: $text, selection: $selection)
            .foregroundStyle(textColor)
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    // 굵게 토글
                    Button("Bold", systemImage: "bold") {
                        text.transformAttributes(in: &selection) { container in
                            let current = container.font ?? .default
                            let resolved = current.resolve(in: fontResolutionContext)
                            container.font = current.bold(!resolved.isBold)
                        }
                    }
                    // 기울임 토글
                    Button("Italic", systemImage: "italic") {
                        text.transformAttributes(in: &selection) { container in
                            let current = container.font ?? .default
                            let resolved = current.resolve(in: fontResolutionContext)
                            container.font = current.italic(!resolved.isItalic)
                        }
                    }
                    // 밑줄 토글
                    Button("Underline", systemImage: "underline") {
                        text.transformAttributes(in: &selection) { container in
                            container.underlineStyle = (container.underlineStyle == .single) ? .none : .single
                        }
                    }
                    // 취소선 토글
                    Button("Strikethrough", systemImage: "strikethrough") {
                        text.transformAttributes(in: &selection) { container in
                            container.strikethroughStyle = (container.strikethroughStyle == .single) ? .none : .single
                        }
                    }
                    Spacer()
                    // 저장
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
