//
//  TextField.swift
//  EST-First-Team1-Project
//
//  Created by 김대현 on 10/16/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var text = ""
    @State private var textColor = Color(.sRGB, red: 0.98, green: 0.9, blue: 0.2)
    
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    Text("여행")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(.largeTitle)
                        .bold()
                }
                .padding()
                DateHeaderAndEditor(dateString: "2025.10.14")
            }
            .toolbar {
                ToolbarItemGroup(placement: .topBarLeading) {
                    Button {
                    } label: {
                        Label("dismiss", systemImage: "chevron.left")
                    }
                }
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button {
                    } label: {
                        Label("Search", systemImage: "magnifyingglass")
                    }
                }
            }
        }
    }
}

// 텍스트 박스 구역
struct DateHeaderAndEditor: View {
    let dateString: String
    @State private var attributedText: AttributedString = ""
    @State private var textSelection = AttributedTextSelection()
    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                Rectangle()
                    .fill(.gray.opacity(0.25))
                    .clipShape(TopRoundedRectangle(cornerRadius: 30))
                Text(dateString)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.black.opacity(0.8))
            }
            .frame(height: 40)

            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 0, style: .continuous)
                    .fill(.gray.opacity(0.15))
                if attributedText.characters.isEmpty {
                    Text("Text")
                        .foregroundStyle(.gray.opacity(0.6))
                        .padding(.top, 15)
                        .padding(.horizontal, 15)
                }
                EditorView(text: $attributedText, selection: $textSelection)
                    .font(.system(size: 17))
                    .padding(.top, 15 - 4)
                    .padding(.horizontal, 15 - 2)
                    .scrollContentBackground(.hidden)
                    .background(Color.clear)
                    .foregroundStyle(.black)
            }
            .mask(RoundedRectangle(cornerRadius: 0, style: .continuous))
            .frame(maxHeight: .infinity, alignment: .top)
            .ignoresSafeArea(.container, edges: .bottom)
        }
        .compositingGroup()
        .shadow(color: .black.opacity(0.03), radius: 2, y: 1)
    }
}

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
                    ColorPicker(selection: $textColor) {
                        Text("Select a color")
                    }
                    .labelsHidden()
                    
                    Spacer()
                    Button {
                    } label: {
                        Label("function 8", systemImage: "square.and.pencil")
                    }
                }
            }
        }
    }
}

extension EditorView {
    init(text: Binding<AttributedString>) {
        self._text = text
        self._selection = .constant(AttributedTextSelection())
    }
}

#Preview {
    ContentView()
}
