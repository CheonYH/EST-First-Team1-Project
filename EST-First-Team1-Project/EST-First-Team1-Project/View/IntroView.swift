//
//  IntroView.swift
//  EST-First-Team1-Project
//
//  Created by 이찬희 on 10/17/25.
//


import SwiftUI

// MARK: - IntroView

/// # Overview
/// BoxUp 앱의 **온보딩(인트로) 화면**입니다.
/// 좌우로 스와이프 가능한 4개의 페이지를 제공하며, 마지막 페이지에서 **“시작하기”** 버튼으로
/// 온보딩을 종료하고 메인 화면으로 전환합니다.
///
/// # Discussion
/// - 온보딩 완료 여부는 `@AppStorage("hasSeenIntro")` 키로 영구 저장됩니다.
/// - App 엔트리(@main)에서 아래와 같이 분기해야 동작합니다:
///   ```swift
///   if hasSeenIntro { MainPage() } else { IntroView() }
///   ```
/// - 페이지 구성:
///   0: 앱 이미지/타이틀/한줄 소개
///   1: 카테고리로 담기(카드)
///   2: 필터로 찾기(카드)
///   3: 되돌아보기(카드) + 시작하기
///
/// # SeeAlso
/// - ``IntroCard``
/// - `@AppStorage("hasSeenIntro")`
struct IntroView: View {
    
    /// 온보딩을 이미 보았는지 여부.
    ///
    /// - Note: `true`가 되면 App 루트 분기에 의해 `MainPage`가 표시됩니다.
    @AppStorage("hasSeenIntro") private var hasSeenIntro = false
    
    /// 현재 선택된 페이지 인덱스(0-based).
    @State private var page = 0
    
    /// 마지막 페이지 인덱스. (페이지가 늘어나면 함께 수정)
    private let lastPage = 3
    
    /// # Overview
    /// 인트로 전체 레이아웃을 구성합니다.
    /// 배경은 다크 톤 고정이며, `TabView(.page)`로 스와이프 전환을 제공합니다.
    var body: some View {
        ZStack {
            // 앱 공용 다크 배경
            Color(red: 53/255, green: 53/255, blue: 53/255)
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                // ─ 페이지들 (스와이프)
                TabView(selection: $page) {
                    // 0) 앱 이미지 + 타이틀 + 소개
                    VStack(spacing: 16) {
                
                        Image("star")
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: 200, maxHeight: 200)
                            .accessibilityLabel("앱 아이콘")
            
                        Text("BoxUp 박스업")
                            .font(.system(size: 34, weight: .bold))
                            .foregroundStyle(.white)
                        
                        Text("기록을 담고, 꺼내는 즐거움.\n카테고리로 정리하고 바로 찾는 회고앱")
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.white.opacity(0.9))
                            .accessibilityLabel("기록을 담고 꺼내는 즐거움. 카테고리로 정리하고 바로 찾는 회고앱")
                    }
                    .padding(.horizontal, 20)
                    .tag(0)
                    
                    // 1) 카테고리로 담기
                    VStack {
                        Spacer()
                        IntroCard(
                            icon: "shippingbox.fill",
                            title: "카테고리로 담기",
                            subtitle: "도서관처럼, 나만의 분류로 메모를 깔끔하게 보관"
                        )
                        Spacer()
                    }
                    .tag(1)
                    
                    // 2) 필터로 바로 찾기
                    VStack {
                        Spacer()
                        IntroCard(
                            icon: "magnifyingglass",
                            title: "필터로 바로 찾기",
                            subtitle: "읽어가며 찾지 말고, 조건으로 정확하게 도달"
                        )
                        Spacer()
                    }
                    .tag(2)
                    
                    // 3) 되돌아보기 (+ 마지막 페이지)
                    VStack {
                        Spacer()
                        IntroCard(
                            icon: "clock.fill",
                            title: "되돌아보기",
                            subtitle: "타임라인과 즐겨찾기로 회고를 더 쉽게"
                        )
                        Spacer()
                    }
                    .tag(3)
                }
                .tabViewStyle(.page)
                .indexViewStyle(.page(backgroundDisplayMode: .always))
                .frame(height: 440) // 인디케이터와 텍스트 간격 확보
                .padding(.bottom, 8)
                
                // ─ 하단 컨트롤: 이전 / 다음 / 시작하기
                HStack {
                    // 첫 페이지에서는 "이전" 숨김
                    if page == 0 {
                        Spacer(minLength: 0)
                    } else {
                        Button("이전") {
                            withAnimation(.easeInOut) {
                                page = max(page - 1, 0)
                            }
                        }
                        .buttonStyle(.bordered)
                        .tint(.white.opacity(0.6))
                        .accessibilityLabel("이전 페이지")
                    }
                    
                    Spacer()
                    
                    if page < lastPage {
                        Button("다음") {
                            withAnimation(.easeInOut) {
                                page = min(page + 1, lastPage)
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.white)
                        .foregroundStyle(.black)
                        .accessibilityLabel("다음 페이지")
                    } else {
                        Button("시작하기") {
                            // 온보딩 완료 → App 루트 분기에 의해 MainPage 표시
                            hasSeenIntro = true
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.white)
                        .foregroundStyle(.black)
                        .accessibilityLabel("앱 시작하기")
                    }
                }
                .padding(.top, 4)
                
                
            }
            .padding(24)
        }
    }
}

// MARK: - IntroCard (재사용 카드)

/// # Overview
/// 온보딩에서 사용하는 단순 설명 카드 컴포넌트입니다.
/// 큰 아이콘, 제목, 부제목으로 구성됩니다.
///
/// # Parameters
/// - icon: SF Symbols 이름
/// - title: 카드 제목
/// - subtitle: 카드 설명(멀티라인 가능)
///
/// # Accessibility
/// 보이스오버가 하나의 문장처럼 읽도록 `accessibilityElement(children: .combine)`을 사용합니다.
private struct IntroCard: View {
    let icon: String
    let title: String
    let subtitle: String
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 52, weight: .bold))
                .foregroundStyle(.white)
            
            Text(title)
                .font(.title2).bold()
                .foregroundStyle(.white)
            
            Text(subtitle)
                .multilineTextAlignment(.center)
                .foregroundStyle(.white.opacity(0.9))
                .padding(.horizontal, 12)
        }
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title). \(subtitle)")
    }
}

// MARK: - Preview
#Preview {
    IntroView()
}
