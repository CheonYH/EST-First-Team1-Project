//
//  IntroView.swift
//  EST-First-Team1-Project
//
//  Created by 이찬희 on 10/17/25.
//

//
//  IntroView.swift
//  EST-First-Team1-Project
//
//  Created by 이찬희 on 10/17/25.
//

import SwiftUI

struct IntroView: View {
    @AppStorage("hasSeenIntro") private var hasSeenIntro = false
    @State private var page = 0
    
    // 마지막 페이지 인덱스
    private let lastPage = 3
    
    var body: some View {
        ZStack {
            // 요청: 배경을 지정한 RGB 색상으로 변경
            Color(red: 53/255, green: 53/255, blue: 53/255)
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                
                // 개발용: 인트로 다시 보기 스위치 (필요 시 주석 해제)
                /*
                 Toggle("인트로 다시 보기(개발용)", isOn: Binding(
                 get: { !hasSeenIntro },
                 set: { newValue in hasSeenIntro = !newValue }
                 ))
                 .toggleStyle(.switch)
                 .tint(.white)
                 .foregroundStyle(.white)
                 .padding(.top, 8)
                 */
                
                // ✅ 스와이프 가능한 페이지
                TabView(selection: $page) {
                    // 1) 앱 이미지 + 타이틀 + 소개
                    VStack(spacing: 16) {
                        // 앱 이미지
                        Image("star")
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: 200, maxHeight: 200)
                            .accessibilityLabel("앱 아이콘")
                        
                        // 앱 타이틀
                        Text("BoxUp 박스업")
                            .font(.system(size: 34, weight: .bold))
                            .foregroundStyle(.white)
                        
                        // 앱 한 줄 소개(멀티라인)
                        Text("기록을 담고, 꺼내는 즐거움.\n카테고리로 정리하고 바로 찾는 회고앱")
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.white.opacity(0.9))
                            .accessibilityLabel("기록을 담고 꺼내는 즐거움. 카테고리로 정리하고 바로 찾는 회고앱")
                    }
                    .padding(.horizontal, 20)
                    .tag(0)
                    
                    // 2) Spacer + IntroCard + (아래)Spacer
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
                    
                    // 3) Spacer + IntroCard + Spacer
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
                    
                    // 4) Spacer + IntroCard + Spacer (마지막 페이지)
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
                // 인디케이터가 텍스트를 가리지 않도록 높이를 늘리고 아래쪽 패딩을 추가
                .frame(height: 440)
                .padding(.bottom, 8)
                
                // 하단 컨트롤: 이전 / 다음 또는 시작하기
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
                            // ✅ App 루트 분기에 의해 MainPage로 전환
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

// 재사용 카드
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

#Preview {
    IntroView()
}
