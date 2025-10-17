import SwiftUI
import SwiftData



// MARK: Color → (r, g, b, a)
/// Color를 0~255 범위의 정수 RGBA로 바꿉니다.
///
/// - 하는 일:
///   1) `Color`를 `CGColor`로 바꿉니다.
///   2) sRGB 색공간으로 맞춘 뒤(RGB가 아닌 회색조도 포함) 컴포넌트를 읽습니다.
///   3) 0.0~1.0 값을 0~255 정수로 반올림합니다.
///
/// - 반환값: `(r, g, b, a)` 또는 변환이 안 되면 `nil`
///
/// - 메모:
///   - 회색조(그레이)도 자동으로 R=G=B로 처리됩니다.
///   - 알파가 없으면 255(불투명)으로 계산합니다.
///

extension Color {
    
  
    func rgba255() -> (r: Int, g: Int, b: Int, a: Int)? {
        
        guard let cg = self.cgColor else {
            return nil
        }
        
        
        let rgbSpace = CGColorSpaceCreateDeviceRGB()
        let rgb = cg.converted(to: rgbSpace, intent: .defaultIntent, options: nil) ?? cg
        
        
        guard let c = rgb.components else { return nil }
        
        
        let r, g, b, a: CGFloat
        switch c.count {
            case 1:
                r = c[0]; g = c[0]; b = c[0]; a = 1
            case 2:
                r = c[0]; g = c[0]; b = c[0]; a = c[1]
            default:
                r = c[0]; g = c[1]; b = c[2]; a = (c.count > 3 ? c[3] : 1)
        }
        
        
        return (
            Int(round(r * 255)),
            Int(round(g * 255)),
            Int(round(b * 255)),
            Int(round(a * 255))
        )
    }
    
    // MARK: - (r,g,b,a) Int(0...255) → Color
    
    // MARK: (r, g, b, a) → Color
    
    /// 0~255 정수 RGBA로 Color를 만듭니다.
    ///
    /// - 파라미터:
    ///   - r, g, b: 색상(0~255)
    ///   - a: 불투명도(0~255), 기본 255
    ///
    /// - 반환: sRGB Color
    static func from255(r: Int, g: Int, b: Int, a: Int = 255) -> Color {
        Color(.sRGB,
              red:   Double(r)/255.0,
              green: Double(g)/255.0,
              blue:  Double(b)/255.0,
              opacity: Double(a)/255.0)
    }
}

// MARK: - 카테고리 목록 뷰
/// 카테고리 목록 화면.
///
/// - Discussion:
///   SwiftData의 ``CategoryModel``을 쿼리해 리스트로 보여줍니다.
///   셀을 탭하면 편집 시트가 열리고, 우상단 + 버튼으로 새 항목을 생성합니다.
///   삭제 스와이프 시 ``deleteRows(_:)``로 영구 삭제합니다.
///   전체 화면은 다크 테마(검정 배경)로 고정 스타일링됩니다.
///
/// - DataSource: `@Query` 정렬: 이름 내림차순.
/// - Navigation: 편집/생성은 `fullScreenCover`로 표시됩니다.
struct Category: View {
    
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @Query(sort: [SortDescriptor(\CategoryModel.name, order:.reverse)])
    var cate: [CategoryModel]
    
    @State private var isShowingAddSheet = false
    @State private var editingCategory: CategoryModel? = nil

    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 53/255, green: 53/255, blue: 53/255).ignoresSafeArea()

                if cate.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "folder.badge.plus")
                            .font(.system(size: 48))
                            .foregroundColor(.white)
                        Text("카테고리를 추가해 주세요")
                            .foregroundColor(.white)
                            .font(.headline)
                    }
                    .multilineTextAlignment(.center)
                } else {
                    List {
                        ForEach(cate, id: \.persistentModelID) { category in
                            Button {
                                editingCategory = category
                            } label: {
                                HStack(spacing: 12) {
                                    Image(systemName: category.icon)
                                        .foregroundColor(Color.from255(r: category.r, g: category.g, b: category.b, a: category.a))
                                        .font(.title2)
                                        .frame(width: 36, height: 36)
                                        .background(Color.from255(r: category.r, g: category.g, b: category.b, a: category.a).opacity(0.15))
                                        .clipShape(RoundedRectangle(cornerRadius: 8))

                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(category.name)
                                            .font(.headline)
                                            .foregroundColor(.white)
                                    }
                                }
                                .padding(.vertical, 6)
                            }
                        }
                        .onDelete(perform: deleteRows)
                        .listRowBackground(Color.black)
                    }
                    .scrollContentBackground(.hidden)
                    .background(Color.black)
                }
            }

            .navigationTitle("카테고리")
            .navigationBarTitleDisplayMode(.inline)
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
                    target: nil
                )
            }
            .fullScreenCover(item: $editingCategory) { target in
                CategoryEditorView(
                    title: "카테고리 수정",
                    target: target
                )
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    /// 선택한 인덱스의 카테고리를 **영구 삭제**합니다.
    ///
    /// - Parameter offsets: `List`의 onDelete가 전달하는 인덱스 셋.
    /// - SideEffects:
    ///   - SwiftData `ModelContext`에 delete/save를 수행합니다.
    ///   - 실패 시 콘솔에 에러를 출력합니다.
    /// - Complexity: O(n) (선택된 인덱스 수에 비례)
    private func deleteRows(_ offsets: IndexSet) {
        for i in offsets {
            do {
                try CategoryCRUD.delete(context: modelContext, category: cate[i])
            } catch {
                print("Delete error:", error)
            }
        }
    }
}

// MARK: - 카테고리 편집 뷰
/// 카테고리 생성/편집 화면.
///
/// - Parameters:
///   - title: 네비게이션 타이틀(예: "카테고리 만들기" / "카테고리 수정").
///   - target: 편집 대상. `nil`이면 새로 만들기 모드, 값이 있으면 수정 모드.
/// - Discussion:
///   이름/색상/아이콘을 입력받아 저장합니다. `onAppear`에서 편집 모드일 경우 기존 값을 채웁니다.
/// - Persistence:
///   저장 시 ``save()``가 ``CategoryCRUD``의 `create`/`update`를 호출합니다.
/// - Validation:
///   이름이 공백이면 저장 버튼이 비활성화/무효 처리됩니다.
/// - SideEffects:
///   저장 성공 후 `dismiss()`로 시트를 닫습니다.
/// - SeeAlso: ``CategoryCRUD``, ``Color/rgba255()``, ``Color/from255(r:g:b:a:)``

struct CategoryEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    let title: String
    let target: CategoryModel?
    
    @State private var name: String = ""
    @State private var color: Color = .blue
    @State private var icon: String = "folder"
    
    
    /// 피커에 표시할 **SF Symbols 아이콘 프리셋** 목록.
    /// - Note: `systemName`을 `Picker`의 `selection` 값으로 사용합니다.
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
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                Form {
                    Section(header: Text("기본 정보").foregroundColor(.white)) {
                        TextField("카테고리 명", text: $name)
                            .foregroundColor(.gray)
                            .accentColor(.blue)
                        
                        ColorPicker("색상", selection: $color)
                            .foregroundColor(.gray)
                        
                        Picker("아이콘", selection: $icon) {
                            ForEach(iconOptions, id: \.systemName) { item in
                                HStack {
                                    Image(systemName: item.systemName)
                                    Text(item.label)
                                }
                                .tag(item.systemName)
                            }
                        }
                        .foregroundColor(.gray)
                    }
                    
                    Section {
                        Button(action: save) {
                            HStack { Spacer(); Text("저장").bold(); Spacer() }
                        }
                        .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                        .tint(.blue)
                        
                        Button { dismiss() } label: {
                            HStack { Spacer(); Text("취소").bold(); Spacer() }
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
        .navigationViewStyle(.stack)
        .onAppear {
            if let t = target {
                name = t.name
                color = Color.from255(r: t.r, g: t.g, b: t.b, a: t.a)
                icon  = t.icon
            }
        }
    }
    
    
    /// 현재 입력값을 저장합니다. (신규 생성 또는 기존 항목 업데이트)
    ///
    /// - Precondition:
    ///   - `name`은 공백이 아니어야 합니다.
    ///   - `color.rgba255()` 변환이 성공해야 합니다.
    /// - Behavior:
    ///   - `target`이 있으면 업데이트, 없으면 생성.
    ///   - 성공하면 화면을 닫습니다(`dismiss()`).
    /// - Failure:
    ///   - SwiftData 저장 실패 시 콘솔에 에러를 출력합니다.
    /// - SeeAlso: ``CategoryCRUD/create(context:name:r:g:b:a:icon:)``, ``CategoryCRUD/update(context:category:name:icon:r:g:b:a:)``
    
    private func save() {
        let trimmed = name.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        
        
        let c = color.rgba255() ?? (r: 59, g: 130, b: 246, a: 255)
        
        do {
            if let t = target {
                
                try CategoryCRUD.update(
                    context: modelContext,
                    category: t,
                    name: trimmed,
                    icon: icon,
                    r: c.r, g: c.g, b: c.b, a: c.a
                )
            } else {
                
                try CategoryCRUD.create(
                    context: modelContext,
                    name: trimmed,
                    r: c.r, g: c.g, b: c.b, a: c.a,
                    icon: icon
                )
            }
            dismiss()
        } catch {
            print("Save error:", error)
        }
    }
}

// MARK: - 미리보기

struct CategoryListView_Previews: PreviewProvider {
    static var previews: some View {
        Category()
            .preferredColorScheme(.dark)
            .modelContainer(for: CategoryModel.self)
    }
}

