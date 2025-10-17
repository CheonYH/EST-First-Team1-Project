//
//  StatusView.swift
//  EST-First-Team1-Project
//
//  Created by 김두열 on 10/17/25.
//


import SwiftUI

struct StatusView: View {
    @State private var selectedRange: RangeFilter = .week
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    
                    // 상단 로고 + 메뉴
                    HStack {
                        HStack(spacing: 10) {
                            // 심플 로고 플레이스홀더
                            Circle()
                                .fill(LinearGradient(colors: [Color.purple.opacity(0.9), Color.blue.opacity(0.7)],
                                                     startPoint: .topLeading, endPoint: .bottomTrailing))
                                .frame(width: 28, height: 28)
                            Text("back")
                                .font(.headline)
                                .foregroundStyle(.gray.opacity(0.8))
                        }
                        Spacer()
                        // 햄버거 버튼
                        Button {
                            // TODO: 메뉴 액션
                        } label: {
                            VStack(spacing: 6) {
                                Capsule().fill(.white.opacity(0.9)).frame(width: 24, height: 3)
                                Capsule().fill(.white.opacity(0.9)).frame(width: 24, height: 3)
                                Capsule().fill(.white.opacity(0.9)).frame(width: 24, height: 3)
                            }
                            .accessibilityLabel("메뉴")
                        }
                    }
                    .padding(.horizontal, 4)
                    .padding(.top, 8)
                    
                    // 타이틀
                    Text("Walk")
                        .font(.system(size: 32, weight: .heavy))
                        .foregroundStyle(.white)
                        .padding(.top, 8)
                    
                    // 기간 세그먼트
                    RangeSegmentedControl(selected: $selectedRange)
                    
                    // 카드: Net Value
                    NetValueCard(title: "calorie expenditure",
                                 currency: "Total",
                                 amount: 200,
                                 subLabel: "Steps")
                    
                    // 카드: Gain & Lose
                    GainLoseCard(selectedRange: selectedRange,
                                 points: DemoData.points(for: selectedRange))
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 32)
            }
            .background(Color.black.ignoresSafeArea())
            .navigationBarHidden(true)
        }
        .preferredColorScheme(.dark)
    }
}

// MARK: - Segmented Control

enum RangeFilter: String, CaseIterable, Identifiable {
    case day = "24h"
    case week = "7d"
    case month = "30d"
    var id: String { rawValue }
}

struct RangeSegmentedControl: View {
    @Binding var selected: RangeFilter
    
    var body: some View {
        HStack(spacing: 12) {
            ForEach(RangeFilter.allCases) { item in
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selected = item
                    }
                } label: {
                    Text(item.rawValue)
                        .font(.headline)
                        .foregroundStyle(item == selected ? .white : .white.opacity(0.7))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(item == selected ? Color.white.opacity(0.12)
                                      : Color.white.opacity(0.06))
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.white.opacity(0.06))
        )
    }
}

// MARK: - Card Base

struct Card<Content: View>: View {
    @ViewBuilder var content: Content
    
    var body: some View {
        content
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(Color(red: 0.10, green: 0.11, blue: 0.13)) // 짙은 회색
                    .shadow(color: .black.opacity(0.4), radius: 20, x: 0, y: 10)
            )
    }
}

// MARK: - Net Value Card

struct NetValueCard: View {
    var title: String
    var currency: String
    var amount: Double
    var subLabel: String
    
    var body: some View {
        Card {
            VStack(alignment: .leading, spacing: 24) {
                Text(title)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(.white)
                
                // 가벼운 그래프 자리 표시
                PlaceholderSparkline()
                    .frame(height: 80)
                    .opacity(0.6)
                
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 6) {
                            Text(currency)
                                .foregroundStyle(.white.opacity(0.7))
                            Image(systemName: "dollarsign")
                                .foregroundStyle(.white.opacity(0.5))
                        }
                        .font(.headline)
                        
                        Text(amount.formatted(.number.precision(.fractionLength(0))))
                            .font(.system(size: 56, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                        
                        Text(subLabel)
                            .foregroundStyle(.white.opacity(0.6))
                            .font(.headline)
                    }
                    Spacer()
                }
            }
        }
    }
}

// MARK: - Gain & Lose Card

struct GainLoseCard: View {
    var selectedRange: RangeFilter
    var points: [Double]
    
    var body: some View {
        Card {
            VStack(alignment: .leading, spacing: 16) {
                Text("Gain&Lose")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(.white)
                
                LineChartView(values: points,
                              lineColor: Color.green.opacity(0.9),
                              baseline: .centeredZero)
                .frame(height: 120)
                .padding(.top, 8)
                
                // X축 라벨 (예시 날짜)
                HStack {
                    ForEach(DemoData.labels(for: selectedRange), id: \.self) { label in
                        Text(label)
                            .foregroundStyle(.white.opacity(0.7))
                            .font(.subheadline)
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                }
                .padding(.top, 4)
                
                // 기간/금액 요약
                HStack(alignment: .firstTextBaseline) {
                    Text(selectedRange == .day ? "24Hours ▼" :
                            selectedRange == .week ? "7Days ▼" : "30Days ▼")
                    .foregroundStyle(.white.opacity(0.7))
                    .font(.headline)
                    Spacer()
                }
                .padding(.top, 8)
                
                Text("0.00$")
                    .font(.system(size: 40, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.green)
            }
        }
    }
}

// MARK: - Simple Line Chart (Path-based)

enum BaselineMode {
    case zeroAtBottom
    case centeredZero
}

struct LineChartView: View {
    var values: [Double]
    var lineColor: Color = .green
    var baseline: BaselineMode = .zeroAtBottom
    
    var body: some View {
        GeometryReader { proxy in
            let size = proxy.size
            let (minV, maxV) = (values.min() ?? 0, values.max() ?? 0)
            let span = max(maxV - minV, 0.0001)
            
            let mappedY: (Double) -> CGFloat = {
                switch baseline {
                    case .zeroAtBottom:
                        return { value in
                            let y = (value - minV) / span
                            return size.height * (1 - y)
                        }
                    case .centeredZero:
                        let absMax = max(abs(minV), abs(maxV), 1.0)
                        return { value in
                            // 0을 중앙으로 두고 -absMax~+absMax를 매핑
                            let y = (value / (2 * absMax)) + 0.5
                            return size.height * (1 - y)
                        }
                }
            }()
            
            let stepX = values.count > 1 ? size.width / CGFloat(values.count - 1) : 0
            
            ZStack {
                // 기준선
                Path { p in
                    let midY: CGFloat
                    switch baseline {
                        case .zeroAtBottom:
                            midY = size.height - 1
                        case .centeredZero:
                            midY = size.height / 2
                    }
                    p.move(to: .init(x: 0, y: midY))
                    p.addLine(to: .init(x: size.width, y: midY))
                }
                .stroke(lineColor.opacity(0.6), style: StrokeStyle(lineWidth: 2, lineCap: .round))
                
                // 라인
                Path { path in
                    guard !values.isEmpty else { return }
                    path.move(to: CGPoint(x: 0, y: mappedY(values[0])))
                    for i in 1..<values.count {
                        let x = CGFloat(i) * stepX
                        let y = mappedY(values[i])
                        path.addLine(to: CGPoint(x: x, y: y))
                    }
                }
                .stroke(lineColor, style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))
            }
        }
    }
}

// MARK: - Sparkline Placeholder

struct PlaceholderSparkline: View {
    var body: some View {
        GeometryReader { proxy in
            let w = proxy.size.width
            let h = proxy.size.height
            Path { p in
                p.move(to: CGPoint(x: 0, y: h * 0.7))
                p.addCurve(to: CGPoint(x: w * 0.33, y: h * 0.4),
                           control1: CGPoint(x: w * 0.12, y: h * 0.8),
                           control2: CGPoint(x: w * 0.22, y: h * 0.2))
                p.addCurve(to: CGPoint(x: w * 0.66, y: h * 0.6),
                           control1: CGPoint(x: w * 0.45, y: h * 0.7),
                           control2: CGPoint(x: w * 0.55, y: h * 0.8))
                p.addCurve(to: CGPoint(x: w, y: h * 0.5),
                           control1: CGPoint(x: w * 0.78, y: h * 0.4),
                           control2: CGPoint(x: w * 0.9, y: h * 0.6))
            }
            .stroke(Color.white.opacity(0.25), lineWidth: 2)
        }
    }
}

// MARK: - Demo Data

enum DemoData {
    static func points(for range: RangeFilter) -> [Double] {
        switch range {
            case .day:
                return [0, 0.2, -0.1, 0.3, 0.1, -0.05, 0.0, 0.25]
            case .week:
                return [0, 0, 0, 0, 0, 0, 0] // 이미지처럼 평평한 라인
            case .month:
                return [0.1, -0.2, 0.15, 0.05, -0.1, 0.2, -0.05, 0.1, 0.0, 0.05]
        }
    }
    
    static func labels(for range: RangeFilter) -> [String] {
        switch range {
            case .day:
                return ["02:00", "06:00", "10:00", "14:00", "18:00", "22:00"]
            case .week:
                return ["10.10", "10.11", "10.12", "10.13", "10.14", "10.15"]
            case .month:
                return ["W1", "W2", "W3", "W4"]
        }
    }
}

#Preview {
    StatusView()
}

