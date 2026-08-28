# KLCharts

> <span lang="ko">[English](../../README.md) · [简体中文](../zh-Hans/README.md) · [繁體中文](../zh-Hant/README.md) · [日本語](../ja/README.md) · [한국어](../ko/README.md)</span>

같은 데이터를 Swift Charts의 평면 막대 차트와 조작할 수 있는 입체 Canvas 차트로 전환해 표시합니다. 모드를 바꿔도 주변 레이아웃은 움직이지 않습니다.

KLCharts는 `.flat`과 `.dimensional` 두 가지 막대 차트를 제공합니다. 선택 상태, 숫자 형식, 색상, 원본 데이터, 화면 이동은 앱에서 관리합니다. 패키지는 그리기, 모드 전환, 탭 판정, 항목이 많을 때의 가로 스크롤을 담당합니다.

## 개요

- 두 표시 방식에서 같은 데이터 모델 사용
- 모드를 전환해도 주변 레이아웃 유지
- 선택 상태와 선택 해제는 앱에서 관리
- 입체 차트의 드래그, 시점 초기화, 탭 판정
- 항목 수에 따라 평면 차트를 가로로 스크롤

## 요구 사항

- Swift 6.0 이상
- iOS 17 이상
- macOS 14 이상
- 타사 런타임 의존성 없음
- SwiftUI · Swift Charts

## 설치

Xcode의 Add Package Dependencies에서 저장소를 추가하거나 `Package.swift`에 다음을 선언합니다.

```swift
dependencies: [
    .package(
        url: "https://github.com/KoenLee1023/KLCharts.git",
        from: "0.1.0"
    )
]
```

```swift
import KLCharts
```

## 시작하기

1. 표시 문자열과 의미에 맞는 색상을 앱에서 결정한 뒤 차트 데이터를 만듭니다.
2. 차트에는 명시적인 높이를 지정합니다.
3. 안정적인 ID로 `selectedID`와 선택 콜백을 연결합니다.
4. 항목이 많으면 `flatMinimumGroupWidth`를 조정하고 Canvas에는 내용을 설명하는 접근성 정보를 제공합니다.

```swift
struct RevenueChart: View {
    @State private var mode = KLDimensionalBarChartMode.flat
    @State private var selectedID: String?
    @State private var resetToken = 0

    let data = [
        KLDimensionalBarDatum(
            id: "jan-online",
            groupKey: "jan",
            groupLabel: "1월",
            seriesKey: "online",
            seriesLabel: "온라인",
            value: 42,
            color: .teal
        ),
        KLDimensionalBarDatum(
            id: "jan-store",
            groupKey: "jan",
            groupLabel: "1월",
            seriesKey: "store",
            seriesLabel: "매장",
            value: 28,
            color: .indigo
        )
    ]

    var body: some View {
        KLDimensionalBarChart(
            data: data,
            mode: mode,
            emptyText: "매출 데이터가 없습니다",
            accessibilityLabel: "월별 및 채널별 매출",
            selectedID: selectedID,
            resetToken: resetToken,
            flatMinimumGroupWidth: 76,
            axisValueFormatter: { "$\(Int($0))" },
            onSelect: { selectedID = $0.id },
            onClearSelection: { selectedID = nil }
        )
        .frame(height: 300)
    }
}
```

## 동작 보장

입체 차트에서는 `groupKey`와 `seriesKey`가 처음 나타나는 위치가 순서를 정합니다. 평면 차트는 `groupLabel`과 `seriesLabel`로 막대를 배치하지만 너비와 탭 위치 근사 계산에는 키를 사용합니다. 각 키는 언제나 하나의 동일한 레이블과 일대일로 대응해야 하며 각 `(groupKey, seriesKey)` 조합도 한 번만 사용해야 합니다. 조합이 중복되면 입체 막대가 겹쳐 탭 선택이 불안정해지거나 가려진 막대를 선택하지 못할 수 있습니다.

차트는 선택 콜백을 동기적으로 호출하지만 선택 상태는 통합 앱이 관리합니다. 입체 차트는 선택한 막대의 너비, 높이, 깊이를 1.06배로 확대하고 선택하지 않은 막대를 불투명도 0.56으로 표시합니다. 평면 차트의 선택하지 않은 막대는 불투명도 0.38입니다. 기본 숫자 formatter는 반올림한 입력을 `Int`로 변환하므로 그 값은 `Int`로 표현할 수 있어야 합니다. NaN, 무한대, 범위를 벗어나는 유한 값은 런타임 오류를 일으킬 수 있습니다. 사용자 정의 formatter는 다른 입력 범위를 정할 수 있습니다.

- `KLDimensionalBarDatum`: 막대, 그룹, 시리즈를 식별하는 안정적인 ID와 표시 이름, 값, 색상을 담습니다.
- `KLDimensionalBarChartMode`: 평면 차트인 `.flat`과 입체 차트인 `.dimensional`을 선택합니다.
- `KLDimensionalBarChart`: 두 렌더러를 계속 유지하면서 투명도와 탭 수신 여부를 바꿔 표시 모드를 전환합니다.
- `KLFlatBarChartLayout.chartWidth`: 실제로 그리지 않고 가로 방향에 필요한 너비를 계산합니다.
- `KLDimensionalHitTesting.acceptsTap`: 탭 거리와 반경이 유효한 값인지 확인하고 경계를 포함해 판정합니다.

## 책임 경계

이 패키지는 앱에서 준비한 데이터를 그리는 일만 담당합니다. 데이터 집계, 현지화, 테마 결정, 선택 상태 저장, 범례, 막대를 눌렀을 때의 화면 이동은 앱에서 구현해야 합니다.

## 문서

- [시작하기](GettingStarted.md)
- [API 레퍼런스](API.md)
- [아키텍처](Architecture.md)
- [마이그레이션](Migration.md)
- [데모 앱](../../Examples/Documentation/ko/README.md)
- [보안 정책](SECURITY.md)
- [행동 강령](CODE_OF_CONDUCT.md)
- [변경 기록](CHANGELOG.md)

## 상태

현재 API 버전은 1.0 미만입니다. wondays에서 실제로 사용하고 있지만 안정 버전을 발표하기 전까지는 마이너 업데이트에서 이름이나 설정 방식을 변경할 수 있습니다.

## 라이선스

MIT. [LICENSE](../../LICENSE)
