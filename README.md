
# 이스트캠프 프론티어 2기 iOS 앱 개발자 부트캠프 - 첫번째 미니프로젝트, 1조(박스의 레시피)


# 📦 BoxUp
<p align="center">
  <img width="2000" height="1000" alt="BoxUpImage" src="https://github.com/user-attachments/assets/6f99e949-6b04-4112-bdc3-3639941b6bc7" />
</p>
<div align="center">
  <h1>BoxUp 박스업</h1>
  <h3>텍스트와 제목만으로 검색하는 기존 메모앱, 찾기 어렵지 않으셨나요?</h3>
  <h4>BoxUp은 메모를 개인화된 카테고리로 분류·보관해, 나중에 읽어가며 찾지 않아도 바로 찾게 해줍니다.</h4>
  <h4>도서관 분류처럼 내 취향의 폴더 구조를 만들고, 필요한 순간 카테고리·태그·필터로 정확히 꺼내보세요.</h4>
</div>

## 📑 앱 설명

* 기존의 메모앱의 단점인 text와 title로만 검색 😡
* 나중에 내가 메모 했던 것을 찾으려고 할때는 모든 text를 직접 확인 😡
* 저희는 이 문제점을 보완해보자는 아이디어에서 출발했습니다 💡

### 그래서 우리는!

- 개인의 취향에 맞게 메모를 분류해서 저장할 수있도록 만들었습니다.
- 개인이 설정한 카테고리 별로 분류 저장하여 나중에 쉽게 찾을수 있도록 합니다.
- 일종의 도서관 분류형식을 도입했습니다!

## 💡 주요 기능 소개!
1. 🗒️ 일상 회고 정리
   * 오늘 있었던 일을 정리하며 하루를 잘 포장합니다
   * 작성된 회고는 언제든 수정, 관리 가능합니다
     
2. 🗂️ 카테고리 분류
   * 개인의 취향의 맞는 카테고리를 만들어 설정 가능
   * 카테고리별 검색 가능

3. 📊 기간별 통계 시각화
   * 일, 주, 월 별로 카테고리 사용횟수 분석
   * 카테고리 분석울 통해 개인의 활동을 파악
  
## ✨ 핵심 기술
1. 🗃️ 기술스택(Tech Stack)
   * 프레임워크: SwiftUI
   * 데이터관리: swiftData
   * 라이브러리: SwiftUI Charts
   * UIUX: ipad(가로, 세로 대응), iphone 대응, Light, Dark Mode 대응

## 📁 프로젝트 구조

    EST-First-Team1-Project/
    ├── EST-First-Team1-Project.swift      #  앱 진입점 (SwiftUI App)
    │   └─ App lifecycle 및 초기 데이터 로드
    │
    ├── Data/                              #  데이터 계층 (CRUD 기능)
    │   ├── CategoryCRUD.swift             # 카테고리 관련 데이터 처리 (Create/Read/Update/Delete)
    │   └── EntryCRUD.swift                # 엔트리(게시글, 기록 등) 관련 데이터 처리 (CRUD)
    │
    ├── Models/                            #  데이터 및 도메인 모델
    │   ├── CategoryModel.swift            # 카테고리 데이터 구조 정의
    │   └── EntryModel.swift               # 엔트리(기록/메모 등) 데이터 구조 정의
    │
    ├── Views/                             #  SwiftUI 기반 UI 화면
    │   ├── Category.swift                 # 카테고리 관련 화면
    │   ├── IntroView.swift                # 앱 인트로(시작) 화면
    │   ├── MainPage.swift                 # 메인 페이지 (앱의 핵심 UI)
    │   ├── StatusView.swift               # 상태(예: 진행 현황) 표시 화면
    │   └── TextField.swift                # 텍스트 입력 관련 커스텀 UI 컴포넌트
    │
    └── Assets/                            #  리소스 관리
    ├── Colors.xcassets                # 앱 컬러셋
    ├── Icons.xcassets                 # 아이콘 및 심볼
    └── AppIcon.appiconset             # 앱 아이콘 세트
    
## 🖥️ 앱 주요 화면
| 홈화면 (몌뉴 & 회고 리스트) | 회고 작성 페이지 | 카테고리 생성 페이지 | 통계 분석 페이지 |
|:---:|:---:|:---:|:---:|
| <img width="411" height="856" alt="스크린샷 2025-10-20 오전 12 04 02" src="https://github.com/user-attachments/assets/70e9f81f-f996-4dc1-b038-8104c7fa32a3" /> | <img width="411" height="856" alt="스크린샷 2025-10-20 오전 12 06 02" src="https://github.com/user-attachments/assets/ac87b5f8-aeaf-476a-8aa5-03d2da4ba898" /> | <img width="411" height="856" alt="스크린샷 2025-10-20 오전 12 05 39" src="https://github.com/user-attachments/assets/006faaf3-fff6-4a15-bb28-66d4c6ab72f4" /> | <img width="411" height="**560**" alt="스크린샷 2025-10-20 오전 10 25 24" src="https://github.com/user-attachments/assets/ac5bb419-aeb8-4d96-9711-29315ddc8fd2" /> |
 |

## 💡 사용방법
  1. 메인 화면에서 새 메모를 추가하려면 새 메모 버튼으로 작성 페이지 이동
     * 그 전에 왼족 상단에 3줄 버튼을 눌러서 카테고리 버튼 선택
     * 카테고리 페이지 이동후 + 버튼으로 개인이 원하는 카테고리 생성
     * 저장후 다시 메인 화면으로 이동
  2. 메모 입력 화면으로 이동후 원하는 카테고리 선택후 메모 작성 시작!
     * text라고 써 있는 필드를 누르면 텍스트 편집 바 생성
  3. 작성 완료후 편집 바 오른쪽에 네모와 연필 모양 버튼으로 저장
     
  4. 본인이 작성한 카테고리별 통계 확인을 위해 왼쪽 상단 버튼 다시 선택
  5. 통계 페이지 이동후 자신의 월,주,일 별 통계 확인

## 🧑‍🤝‍🧑 협업 문화
BoxUP은 작은 규모의 프로젝트 였지만,

지속적이고 유기적인 협업을 통해 높은 완성도를 구현했습니다

1. 스토리보드 작성
   * 스토리 보드를 통해 개인의 아이디어들을 시각화하여 취합
   * 팀원들의 이이디어를 종합해 프로젝트 설계

2. 📝 1일 1회의와 회의록 기록
   * 1일 1회의를 통해 작업 진행상황 파악과 팀원들간의 유기적인 피드백을 통해 협업
   * 1일 1회의록을 통해 현재 진행상황과 해야할일을 서로애게 공유

⚙️ 아키텍처 개요 (MVVM)
Layer	역할	예시 파일
Model	메모/카테고리/통계 데이터 정의	Memo.swift, Category.swift
ViewModel	뷰와 데이터 사이의 로직 관리	MemoViewModel.swift
View	사용자 인터페이스(UI) 구성	MainView.swift, StatisticsView.swift


## 🧩 특징

SwiftData로 데이터 영속화

SwiftUI Charts로 통계 시각화

MVVM 구조로 코드 분리 및 유지보수성 향상

Light/Dark Mode 대응 및 iPad·iPhone 대응

Category 기반 검색 & 필터링 기능 내장


## 🗓️ 개발 기간
2025.10.14.화 - 2025.10.19.일 (약 6일)
***



## 👯 팀원 소개

| | | | | |
|:---:|:---:|:---:|:---:|:---:|
| <img width="200" height="200" alt="image" src="https://github.com/user-attachments/assets/6863b073-e682-4cbb-8106-5b6a647ed288" alt="이찬희" /> | <img width="200" height="200" alt="image" src="https://github.com/user-attachments/assets/ea5c7812-dbab-44b2-8532-5a0dea6ff7a9" alt="김대현" /> | <img width="200" height="200" alt="image" src="https://github.com/user-attachments/assets/c4ea0246-022a-4f39-b34b-64155fb928ff" alt="김두열"/> | <img width="200" height="200" alt="image" src="https://github.com/user-attachments/assets/98491ccd-a8f4-4dc0-8316-98323a94510e" alt="여승위"/> | <img width="200" height="200" alt="image" src="https://github.com/user-attachments/assets/e2bfd524-b4ed-4ecf-9656-7e133cad6f6f" alt="천용휘" /> |
| **iOS** | **iOS** | **iOS** | **iOS** | **iOS** |
| **[이찬희](https://github.com/KyleLee02)**<br> | **[김대현](https://github.com/Lala-roid)**<br> | **[김두열](https://github.com/hienzld-dotcom)**<br> | **[여승위](https://github.com/yeobare-blip)**<br> | **[천용휘](https://github.com/CheonYH)**<br> |
| 개발 / 기획 / 문서작성 | 개발 / 초기 기획 / PPT 제작 | 개발 / 통계 / 시연 영상  | 개발 / 문서작성 / 디자인 | 개발 / 데이터 관리 / 깃 허브 관리 |



  

  


