//
//  StatusView.swift
//  EST-First-Team1-Project
//
//  Created by 김두열 on 10/17/25.
//

import SwiftUI
import SwiftData

// MARK: - Range

enum RangeFilter: String, CaseIterable, Identifiable {
    case day = "24h"
    case week = "7d"
    case month = "30d"
    var id: String { rawValue }
}


// MARK: - Aggregated model

struct CategoryUsage: Identifiable {
    let id: String
    let name: String               // 카테고리 이름
    let color: Color               // 카테고리 색상
    let count: Int
}

// MARK: - StatusView (카테고리 사용량 통계)

struct StatusView: View {
    @Environment(\.modelContext) private var ctx
    @Query(sort: [SortDescriptor(\CategoryModel.name, order: .forward)])
    private var categories: [CategoryModel]
    
    @State private var selectedRange: RangeFilter = .week
    @State private var usages: [CategoryUsage] = []
    @State private var totalCount: Int = 0
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                
                Text("카테고리 사용량 통계")
                    .font(.system(size: 32, weight: .heavy))
                    .foregroundStyle(.white)
                    .padding(.top, 8)
                
                RangeSegmentedControl(selected: $selectedRange)
                    .onChange(of: selectedRange) { _ in reload() }
                    .onAppear { reload() }
                
                // 총계 카드
                TotalsCard(total: totalCount,
                           periodLabel: periodLabel(for: selectedRange),
                           categoryCount: usages.filter { $0.count > 0 }.count)
                
                // 바 차트 카드
                UsageBarChartCard(usages: usages,
                                  subtitle: "\(periodLabel(for: selectedRange)) 동안 카테고리별 사용 횟수")
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 32)
        }
        .background(Color.black.ignoresSafeArea())
        .preferredColorScheme(.dark)
    }
    
    // MARK: - Data loading
    
    private func reload() {
        let interval = dateInterval(for: selectedRange)
        do {
            // 기간 내 Entry 조회 (createdAt 사용)
            let fd = FetchDescriptor<EntryModel>(
                predicate: #Predicate { $0.createdAt >= interval.start && $0.createdAt < interval.end }
            )
            let entries = try ctx.fetch(fd)
            
            // 그룹핑
            var countsByID: [String: (name: String, color: Color, count: Int)] = [:]
            
            for e in entries {
                if let c = e.category {
                    let key = c.id.uuidString
                    let name = c.name
                    let color = Color.from255(r: c.r, g: c.g, b: c.b, a: c.a)
                    let cur = countsByID[key]?.count ?? 0
                    countsByID[key] = (name, color, cur + 1)
                } else {
                    let key = "unclassified"
                    let name = "미분류"
                    let color = Color.white.opacity(0.6)
                    
                    var agg = countsByID[key] ?? (name, color, 0)
                    agg.count += 1
                    countsByID[key] = agg
                }
            }
            
            // usages로 변환 & 정렬
            let list = countsByID.map { (key, v) in
                CategoryUsage(id: key, name: v.name, color: v.color, count: v.count)
            }
                .sorted { $0.count > $1.count }
            
            // 총계
            totalCount = entries.count
            usages = list
            
        } catch {
            // 실패 시 안전 기본값
            totalCount = 0
            usages = []
            assertionFailure("Failed to fetch entries for stats: \(error)")
        }
    }
    
    private func dateInterval(for range: RangeFilter) -> DateInterval {
        let now = Date()
        let start: Date
        switch range {
            case .day:
                start = Calendar.current.date(byAdding: .hour, value: -24, to: now) ?? now
            case .week:
                start = Calendar.current.date(byAdding: .day, value: -7, to: now) ?? now
            case .month:
                start = Calendar.current.date(byAdding: .day, value: -30, to: now) ?? now
        }
        return DateInterval(start: start, end: now)
    }
    
    private func periodLabel(for range: RangeFilter) -> String {
        switch range {
            case .day: return "최근 24시간"
            case .week: return "최근 7일"
            case .month: return "최근 30일"
        }
    }
}

// MARK: - Segmented Control (그대로 사용)

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

// MARK: - Cards

struct Card<Content: View>: View {
    @ViewBuilder var content: Content
    var body: some View {
        content
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(Color(red: 0.10, green: 0.11, blue: 0.13))
                    .shadow(color: .black.opacity(0.4), radius: 20, x: 0, y: 10)
            )
    }
}

struct TotalsCard: View {
    let total: Int
    let periodLabel: String
    let categoryCount: Int
    
    var body: some View {
        Card {
            VStack(alignment: .leading, spacing: 16) {
                Text("요약")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(.white)
                
                HStack(spacing: 16) {
                    SummaryPill(title: "사용된 횟수", value: "\(categoryCount)")
                    SummaryPill(title: "기간", value: periodLabel)
                }
            }
        }
    }
}

struct SummaryPill: View {
    let title: String
    let value: String
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.headline)
                .foregroundStyle(.white.opacity(0.7))
            
            Text(value)
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .allowsTightening(true)
                .layoutPriority(1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.white.opacity(0.06))
        )
    }
}

struct UsageBarChartCard: View {
    let usages: [CategoryUsage]
    let subtitle: String
    
    var body: some View {
        Card {
            VStack(alignment: .leading, spacing: 16) {
                Text("카테고리별 사용 횟수")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(.white)
                
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.7))
                
                if usages.isEmpty {
                    Text("표시할 데이터가 없습니다.")
                        .foregroundStyle(.white.opacity(0.6))
                        .padding(.top, 12)
                } else {
                    BarChart(usages: usages)
                        .frame(height: 220)
                        .padding(.top, 8)
                }
            }
        }
    }
}

// MARK: - Simple Bar Chart

struct BarChart: View {
    let usages: [CategoryUsage]
    
    var body: some View {
        GeometryReader { geo in
            let maxVal = max(usages.map(\.count).max() ?? 1, 1)
            let barWidth = max(12, (geo.size.width - CGFloat(usages.count - 1) * 12) / CGFloat(max(usages.count, 1)))
            
            HStack(alignment: .bottom, spacing: 12) {
                ForEach(usages) { u in
                    VStack(spacing: 8) {
                        // bar
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(u.color)
                            .frame(
                                width: barWidth,
                                height: max(8, CGFloat(u.count) / CGFloat(maxVal) * (geo.size.height - 44))
                            )
                            .overlay(
                                Text("\(u.count)")
                                    .font(.caption2)
                                    .foregroundStyle(.white.opacity(0.9))
                                    .padding(.bottom, 2),
                                alignment: .top
                            )
                        
                        // label
                        Text(u.name)
                            .font(.caption2)
                            .foregroundStyle(.white.opacity(0.8))
                            .lineLimit(1)
                            .frame(width: barWidth + 8)
                    }
                    .frame(maxHeight: .infinity, alignment: .bottom)
                }
            }
            .frame(maxWidth: .infinity, alignment: .bottomLeading)
        }
    }
}

// MARK: - Preview

#Preview {
    StatusView()
}
