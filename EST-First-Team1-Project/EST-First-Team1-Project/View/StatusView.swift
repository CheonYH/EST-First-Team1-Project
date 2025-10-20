//
//  StatusView.swift
//  EST-First-Team1-Project
//
//  Created by 김두열 on 10/17/25.
//

import SwiftUI
import SwiftData

// MARK: - Range


/// # Overview
/// 통계 조회 기간(최근 24시간/7일/30일)을 표현합니다.
/// 뷰의 세그먼트 컨트롤과 데이터 쿼리 범위를 동기화할 때 사용합니다.
///
/// # Cases
/// - `day`   : 최근 24시간
/// - `week`  : 최근 7일
/// - `month` : 최근 30일
enum RangeFilter: String, CaseIterable, Identifiable {
    case day = "24h"
    case week = "7d"
    case month = "30d"
    var id: String { rawValue }
}


// MARK: - Aggregated model


/// # Overview
/// 카테고리별 집계 결과(이름/색상/사용횟수)를 바 차트/요약 카드에 공급하기 위한 ViewModel입니다.
///
/// # Discussion
/// `CategoryModel`의 고유 식별자(`UUID`)를 기반으로 합니다.
/// 일반적인 사용 시에는 모든 Entry가 유효한 카테고리를 가지므로,
/// `id`에는 해당 카테고리의 UUID 문자열을 사용합니다.
///
/// - Note:
///   카테고리 삭제로 참조가 사라진 항목은 예외적으로 `"unclassified"`가 적용됩니다.
struct CategoryUsage: Identifiable {
    let id: String
    let name: String               // 카테고리 이름
    let color: Color               // 카테고리 색상
    let count: Int
}

// MARK: - StatusView (카테고리 사용량 통계)
/// # Overview
/// 선택된 기간에 대한 **카테고리 사용량 통계**를 보여주는 메인 화면입니다.
/// 상단(제목/기간 세그먼트/총계 카드) + 하단(바 차트 카드)로 구성됩니다.
///
/// # Discussion
/// - 상단 요소들의 실제 렌더링 높이를 `PreferenceKey(HeightKey)`로 집계하여,
///   데이터가 없을 때 차트 카드가 **남은 세로 공간을 자연스럽게 채우도록** 만듭니다.
/// - SwiftData `EntryModel.createdAt`을 기준으로 기간 필터링합니다.
///
/// # SeeAlso
/// `RangeSegmentedControl`, `UsageBarChartCard`, `BarChart`
struct StatusView: View {
    @Environment(\.modelContext) private var ctx

    @Query(sort: [SortDescriptor(\CategoryModel.name, order: .forward)])
    private var categories: [CategoryModel]
    
    @State private var selectedRange: RangeFilter = .week
    @State private var usages: [CategoryUsage] = []
    @State private var totalCount: Int = 0
    
    @State private var aboveHeight: CGFloat = 0   // 상단 영역 총 높이
    
    var body: some View {
        GeometryReader { outer in
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    
                    // ─ 제목
                    Text("카테고리 사용량 통계")
                        .font(.system(size: 32, weight: .heavy))
                        .foregroundStyle(.white)
                        .padding(.top, 8)
                        .background(
                            GeometryReader { Color.clear
                                    .preference(key: HeightKey.self, value: $0.size.height)
                            }
                        )
                    
                    // ─ 세그먼트
                    RangeSegmentedControl(selected: $selectedRange)
                        .onChange(of: selectedRange) { _ in reload() }
                        .onAppear { reload() }
                        .background(
                            GeometryReader { Color.clear
                                    .preference(key: HeightKey.self, value: $0.size.height)
                            }
                        )
                    
                    // ─ 총계 카드
                    TotalsCard(total: totalCount,
                               periodLabel: periodLabel(for: selectedRange),
                               categoryCount: usages.filter { $0.count > 0 }.count)
                    .background(
                        GeometryReader { Color.clear
                                .preference(key: HeightKey.self, value: $0.size.height)
                        }
                    )
                    
                    // ─ 바 차트 카드
                    UsageBarChartCard(
                        usages: usages,
                        subtitle: "\(periodLabel(for: selectedRange)) 동안 카테고리별 사용 횟수",
                        // ✅ ‘남은 공간’ = 화면높이 - 상단총높이 - 바깥 패딩(대략)
                        minHeightOverride: usages.isEmpty
                        ? max(220, outer.size.height - aboveHeight - 20 /*bottom padding*/)
                        : nil
                    )
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 32)
            }
            .background(Color(red: 53/255, green: 53/255, blue: 53/255))
            // ⬇️ 상단 요소들의 높이 합계 수신
            .onPreferenceChange(HeightKey.self) { aboveHeight = $0 }
        }
    }

    
    // MARK: - Data loading
    
    /// # Overview
    /// 선택된 기간(`selectedRange`)에 맞춰 `EntryModel`을 페치하고,
    /// 카테고리별로 그룹핑/정렬해 `usages`와 `totalCount`를 갱신합니다.
    ///
    /// # Discussion
    /// - `e.category == nil`인 항목은 `"미분류"` 키로 묶습니다.
    /// - 색상은 `CategoryModel`의 RGBA(0~255)를 `Color.from255`로 변환합니다.
    /// - 페치 실패 시 안전한 초기값으로 되돌리고 `assertionFailure`를 호출합니다.
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
    
    /// # Overview
    /// `RangeFilter`에 따른 [start, now) 구간을 생성합니다.
    /// - Returns: `DateInterval(start: past, end: now)`
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
    
    /// # Overview
    /// UI 표기를 위한 사람 친화적 기간 라벨을 반환합니다.
    /// - Example: `.day → "최근 24시간"`
    private func periodLabel(for range: RangeFilter) -> String {
        switch range {
            case .day: return "최근 24시간"
            case .week: return "최근 7일"
            case .month: return "최근 30일"
        }
    }
}

// MARK: - Segmented Control
/// # Overview
/// `RangeFilter`를 선택하는 세그먼트 컨트롤입니다.
/// 선택 변경 시 상위의 `selected` 바인딩을 애니메이션과 함께 갱신합니다.
///
/// # Accessibility
/// 버튼 라벨은 실제 값("24h", "7d", "30d")을 노출합니다.
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

/// # Overview
/// 라이트/다크 모드에 맞춘 공용 카드 컨테이너입니다.
/// 적당한 그림자, 얇은 스트로크, 큰 코너 반경(28pt)을 적용합니다.
///
/// # Discussion
/// - 라이트 모드에선 밝기 과다를 줄이기 위해 `systemGray6` 톤을 사용합니다.
/// - 다크 모드에서는 기존 대비/그림자를 유지합니다.
struct Card<Content: View>: View {
    @Environment(\.colorScheme) private var scheme
    @ViewBuilder var content: Content
    
    var body: some View {
        // 라이트: systemGray6(아주 연한 회색), 다크: 기존 값 유지
        let cardFill = scheme == .dark
        ? Color(.secondarySystemBackground)
        : Color(.systemGray6) // ← 더 덜 눈부심
        
        let strokeColor = scheme == .dark
        ? Color.white.opacity(0.06)
        : Color.black.opacity(0.06) // 라이트에선 아주 살짝만 테두리
        
        let shadowColor = scheme == .dark
        ? Color.black.opacity(0.20)
        : Color.black.opacity(0.08) // 라이트에서 그림자 약하게
        
        let shadowRadius: CGFloat = scheme == .dark ? 12 : 10
        let shadowY: CGFloat = scheme == .dark ? 6 : 6
        
        content
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(cardFill)
                    .shadow(color: shadowColor, radius: shadowRadius, x: 0, y: shadowY)
                    .overlay(
                        RoundedRectangle(cornerRadius: 28, style: .continuous)
                            .stroke(strokeColor, lineWidth: 1)
                    )
            )
    }
}


/// # Overview
/// 현재 조회기간의 총 사용횟수, 기간 라벨, 사용된 카테고리 수를 요약합니다.
struct TotalsCard: View {
    let total: Int
    let periodLabel: String
    let categoryCount: Int
    
    var body: some View {
        Card {
            VStack(alignment: .leading, spacing: 16) {
                Text("요약")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(.primary)
                
                HStack(spacing: 16) {
                    SummaryPill(title: "사용된 횟수", value: "\(categoryCount)")
                    SummaryPill(title: "기간", value: periodLabel)
                }
            }
        }
    }
}

/// # Overview
/// 작은 제목 + 굵은 값으로 구성된 요약 배지입니다.
/// 라벨 줄바꿈을 방지하기 위해 `.lineLimit(1)`과 `.minimumScaleFactor(0.7)`를 사용합니다.
struct SummaryPill: View {
    let title: String
    let value: String
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.headline)
                .foregroundStyle(.secondary)
            
            Text(value)
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundStyle(.primary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .allowsTightening(true)
                .layoutPriority(1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(.tertiarySystemBackground))
        )
    }
}

/// # Overview
/// 자식 뷰들의 높이를 상위로 누적 전달하는 `PreferenceKey`입니다.
/// 상단 영역 총합을 구해 **빈 상태 레이아웃의 가변 높이**를 계산하는 데 사용합니다.
///
/// - Note: `reduce`에서 `+=`로 누적합니다.
private struct HeightKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) { value += nextValue() }
}


/// # Overview
/// 바 차트와 서브타이틀을 담는 카드입니다.
/// 데이터가 없을 경우, `minHeightOverride`를 활용해 **남은 화면 높이**를 채우는 빈 상태 안내를 보여줍니다.
///
/// # Parameters
/// - usages: 집계된 카테고리 사용량
/// - subtitle: 기간이 반영된 설명 라벨
/// - minHeightOverride: 빈 상태일 때 강제로 확보할 최소 높이 (없으면 220pt)
struct UsageBarChartCard: View {
    let usages: [CategoryUsage]
    let subtitle: String
    var minHeightOverride: CGFloat? = nil   // ← 추가
    
    var body: some View {
        Card {
            VStack(alignment: .leading, spacing: 16) {
                Text("카테고리별 사용 횟수")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(.primary)
                
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                if usages.isEmpty {
                    // ⬇️ 남은 공간 채우기
                    VStack(spacing: 10) {
                        Image(systemName: "chart.bar.doc.horizontal")
                            .font(.system(size: 32, weight: .semibold))
                            .foregroundStyle(.secondary)
                        Text("표시할 데이터가 없습니다.")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                        Text("카테고리를 선택하거나 새로운 회고를 추가해 보세요.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(minHeight: (minHeightOverride ?? 220))  // 👈 여기!
                } else {
                    BarChart(usages: usages)
                        .frame(height: 220)
                        .padding(.top, 8)
                }
            }
        }
    }
}


/// # Overview
/// 화면 폭/SizeClass/DynamicType을 고려해 빈 상태/차트의 **권장 높이**를 계산합니다.
/// 분할뷰(iPad), 초대형 화면, 접근성 글자 크기에서 균형을 맞춥니다.
///
/// # Parameters
/// - w: 사용 가능한 가로 폭
/// - hSize/vSize: 수평/수직 SizeClass
/// - dtSize: Dynamic Type 크기
///
/// # Returns
/// - empty: 빈 상태 권장 높이
/// - chart: 차트 권장 높이

private func responsiveHeights(
    width w: CGFloat,
    hSize: UserInterfaceSizeClass?,
    vSize: UserInterfaceSizeClass?,
    dtSize: DynamicTypeSize
) -> (empty: CGFloat, chart: CGFloat) {
    
    // iPad 느낌: 가로/세로 둘 다 regular 이거나, 폭이 충분히 넓을 때
    let isRegularLike = (hSize == .regular && vSize == .regular) || w >= 820
    
    // 기본 비율(폭 기준)
    var emptyRatio: CGFloat = isRegularLike ? 0.38 : 0.30
    var chartRatio: CGFloat = isRegularLike ? 0.46 : 0.40
    
    // 폭 버킷으로 미세 조정 (분할뷰/초대형 화면 대응)
    if w < 700 { emptyRatio *= 0.9;  chartRatio *= 0.9  }
    if w > 1000 { emptyRatio *= 1.1; chartRatio *= 1.08 }
    
    // Dynamic Type가 큰 경우 살짝 키움
    if dtSize >= .accessibility1 { emptyRatio *= 1.08; chartRatio *= 1.06 }
    
    // 최종: 폭 * 비율, 안전 클램프
    let empty = max(160, min(520, w * emptyRatio))
    let chart = max(220, min(600, w * chartRatio))
    
    return (empty, chart)
}


// MARK: - Simple Bar Chart

/// # Overview
/// 카테고리별 사용 횟수를 시각화하는 **막대 차트**입니다.
/// 화면 너비에 따라 막대 폭을 동적으로 계산하고,
/// 항목이 많을 경우 자동으로 가로 스크롤이 활성화됩니다.
///
/// # Discussion
/// - `GeometryReader`로 전체 너비를 측정해 막대 폭과 간격을 계산합니다.
/// - 모든 막대는 동일한 기준선에서 정렬되며, 상하단 라벨 영역을 고정 슬롯으로 처리해
///   텍스트 길이와 관계없이 수평 정렬이 유지됩니다.
/// - 막대군이 한 화면에 모두 들어올 경우 중앙 정렬되어 표시됩니다.
/// - 항목 수가 많으면 자동으로 가로 스크롤 모드로 전환됩니다.
/// - 각 막대는 `accessibilityLabel`을 통해 스크린 리더에서 "`이름, N회`"로 읽힙니다.
struct BarChart: View {
    let usages: [CategoryUsage]
    
    var body: some View {
        GeometryReader { geo in
            let n = max(usages.count, 1)
            
            // 1) 좌우 인셋(카드 모서리에 닿지 않도록 살짝만)
            let inset: CGFloat = 12
            let available = max(0, geo.size.width - inset * 2)
            
            // 2) 최소 스펙
            let minBar: CGFloat = 14
            let minGap: CGFloat = 12
            
            // 3) 필요 총폭(막대군)
            let needed = CGFloat(n) * minBar + CGFloat(n - 1) * minGap
            
            // 4) Y 스케일
            let maxVal = max(usages.map(\.count).max() ?? 1, 1)
            
            if needed > available {
                // ─ 넘치면: 가로 스크롤(좌우 inset 유지)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(alignment: .bottom, spacing: minGap) {
                        ForEach(usages) { u in
                            BarColumn(u: u, barWidth: minBar, maxVal: maxVal, chartHeight: geo.size.height)
                        }
                    }
                    .padding(.horizontal, inset)
                }
            } else {
                // ─ 들어오면: barW 재계산 + 막대군을 가운데 배치
                let barW = (available - CGFloat(n - 1) * minGap) / CGFloat(n)
                let barsWidth = CGFloat(n) * barW + CGFloat(n - 1) * minGap
                
                HStack(alignment: .bottom, spacing: minGap) {
                    ForEach(usages) { u in
                        BarColumn(u: u, barWidth: barW, maxVal: maxVal, chartHeight: geo.size.height)
                    }
                }
                .frame(width: barsWidth)                              // 막대군 실제 폭
                .frame(maxWidth: .infinity, alignment: .center)       // 가운데 정렬!
                .padding(.horizontal, inset)
            }
        }
    }
}

private struct BarColumn: View {
    let u: CategoryUsage
    let barWidth: CGFloat
    let maxVal: Int
    let chartHeight: CGFloat
    
    //  라벨 슬롯(고정 높이): 필요 시 조정하세요
    private let topSlot: CGFloat = 18     // 상단 값 라벨 영역
    private let bottomSlot: CGFloat = 16  // 하단 카테고리명 영역
    private let innerSpacing: CGFloat = 6 // 라벨↔막대 사이 간격
    
    var body: some View {
        // 모든 막대가 동일 기준으로 계산됨
        let usable = max(0, chartHeight - topSlot - bottomSlot - innerSpacing*2)
        let barH   = max(8, CGFloat(u.count) / CGFloat(maxVal) * usable)
        
        VStack(spacing: innerSpacing) {
            // 상단 값 라벨 — 고정 높이 슬롯에 맞춰 정렬(아래 정렬)
            Text("\(u.count)")
                .font(.caption2.monospacedDigit().weight(.semibold))
                .foregroundStyle(.primary)
                .frame(width: barWidth, height: topSlot, alignment: .bottom)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            
            // 막대
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(u.color)
                .frame(width: barWidth, height: barH)
            
            // 하단 카테고리명 — 고정 높이 슬롯에 맞춰 정렬(위 정렬)
            Text(u.name)
                .font(.caption2)
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .frame(width: barWidth, height: bottomSlot, alignment: .top)
        }
        .frame(maxHeight: .infinity, alignment: .bottom)
    }
}





// MARK: - Preview

#Preview {
    StatusView()
}
