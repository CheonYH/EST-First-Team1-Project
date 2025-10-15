import SwiftUI

struct CategoryModels: Identifiable, Hashable {
    var id: UUID = UUID()
    var name: String
    var color: Color
    var icon: String
    var parentID: UUID?
}

struct Category: View {
    @State private var categories: [CategoryModels] = [
        CategoryModels(name: "Food", color: .red, icon: "cart", parentID: nil),
        CategoryModels(name: "Tea", color: .green, icon: "leaf", parentID: nil)
    ]
    @State private var isShowingAddSheet = false
    @State private var editingCategory: CategoryModels? = nil

    var body: some View {
        NavigationView {
            ZStack {
                // ✅ 전체 배경 검정색
                Color.black.ignoresSafeArea()

                List {
                    ForEach(categories) { category in
                        Button {
                            editingCategory = category
                        } label: {
                            HStack(spacing: 12) {
                                Image(systemName: category.icon)
                                    .foregroundColor(category.color)
                                    .font(.title2)
                                    .frame(width: 36, height: 36)
                                    .background(category.color.opacity(0.15))
                                    .clipShape(RoundedRectangle(cornerRadius: 8))

                                VStack(alignment: .leading, spacing: 4) {
                                    Text(category.name)
                                        .font(.headline)
                                        .foregroundColor(.white)
                                    if let parent = parentCategory(for: category) {
                                        Text("Parent: \(parent.name)")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                }
                            }
                            .padding(.vertical, 6)
                        }
                    }
                    .onDelete(perform: delete)
                    .listRowBackground(Color.black)
                }
                .scrollContentBackground(.hidden)
                .background(Color.black)
            }
            .navigationTitle("카테고리")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { isShowingAddSheet = true }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundColor(.white)
                    }
                }
            }
            .fullScreenCover(isPresented: $isShowingAddSheet) {
                CategoryEditorView(
                    title: "카테고리 만들기",
                    initialCategory: nil
                ) { newCategory in
                    categories.append(newCategory)
                }
            }
            .fullScreenCover(item: $editingCategory) { category in
                CategoryEditorView(
                    title: "카테고리 수정",
                    initialCategory: category
                ) { updated in
                    if let index = categories.firstIndex(where: { $0.id == category.id }) {
                        categories[index] = updated
                    }
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }

    private func parentCategory(for category: CategoryModels) -> CategoryModels? {
        guard let pid = category.parentID else { return nil }
        return categories.first(where: { $0.id == pid })
    }

    private func delete(at offsets: IndexSet) {
        categories.remove(atOffsets: offsets)
    }
}

// MARK: - 카테고리 편집 뷰
struct CategoryEditorView: View {
    @Environment(\.presentationMode) private var presentationMode
    let title: String
    let initialCategory: CategoryModels?
    let onSave: (CategoryModels) -> Void

    @State private var name: String = ""
    @State private var color: Color = .blue
    @State private var icon: String = "folder"

    // ✅ SF Symbols <-> 한글 매핑
    private let iconOptions: [(label: String, systemName: String)] = [
        ("운동", "figure.walk"),
        ("음식", "cart"),
        ("사랑", "heart"),
        ("여행", "figure.walk.suitcase.rolling"),
        ("책", "book"),
        ("선물", "gift"),
        ("가방", "bag"),
        ("찻잔", "cup.and.saucer"),
        ("발자국", "pawprint")
    ]

    init(title: String, initialCategory: CategoryModels?, onSave: @escaping (CategoryModels) -> Void) {
        self.title = title
        self.initialCategory = initialCategory
        self.onSave = onSave
        _name = State(initialValue: initialCategory?.name ?? "")
        _color = State(initialValue: initialCategory?.color ?? .blue)
        _icon = State(initialValue: initialCategory?.icon ?? "folder")
    }

    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()

                Form {
                    Section(header: Text("기본 정보").foregroundColor(.white)) {
                        TextField("카테고리 명", text: $name)
                            .foregroundColor(.white)
                            .accentColor(.blue)

                        ColorPicker("색상", selection: $color)
                            .foregroundColor(.white)

                        Picker("아이콘", selection: $icon) {
                            ForEach(iconOptions, id: \.systemName) { item in
                                HStack {
                                    Image(systemName: item.systemName)
                                    Text(item.label) // 한글 표시
                                }
                                .tag(item.systemName)
                            }
                        }
                        .foregroundColor(.white)
                    }

                    Section {
                        Button(action: save) {
                            HStack {
                                Spacer()
                                Text("저장")
                                    .bold()
                                Spacer()
                            }
                        }
                        .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                        .tint(.blue)

                        Button {
                            presentationMode.wrappedValue.dismiss()
                        } label: {
                            HStack {
                                Spacer()
                                Text("취소")
                                    .bold()
                                Spacer()
                            }
                        }
                        .foregroundColor(.red)
                    }
                }
                .scrollContentBackground(.hidden)
                .background(Color.black)
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(Color.black, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }

    private func save() {
        let trimmed = name.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        let category = CategoryModels(
            id: initialCategory?.id ?? UUID(),
            name: trimmed,
            color: color,
            icon: icon,
            parentID: initialCategory?.parentID
        )
        onSave(category)
        presentationMode.wrappedValue.dismiss()
    }
}

struct CategoryListView_Previews: PreviewProvider {
    static var previews: some View {
        Category()
            .preferredColorScheme(.dark)
    }
}
