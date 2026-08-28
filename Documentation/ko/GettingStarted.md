# KLCharts: 시작하기

> <span lang="ko">[English](../../README.md) · [简体中文](../zh-Hans/README.md) · [繁體中文](../zh-Hant/README.md) · [日本語](../ja/README.md) · [한국어](../ko/README.md)</span>

Xcode의 Add Package Dependencies에서 저장소를 추가하거나 `Package.swift`에 다음을 선언합니다.

```swift
dependencies: [
    .package(
        url: "https://github.com/KoenLee1023/KLCharts.git",
        from: "0.1.0"
    )
]
```

KLCharts는 iOS 17, macOS 14, Swift 6 이상을 지원하며 타사 런타임 의존성이 없습니다.

## 1. 데이터 준비

표시 문자열의 현지화와 의미 색상 선택을 통합 앱에서 마친 뒤 차트 데이터를 만듭니다. 입체 차트에서는 그룹 키와 시리즈 키가 배열에서 처음 나타나는 위치가 순서를 정합니다. 평면 차트는 레이블로 막대를 배치하지만 너비와 탭 위치 근사 계산에는 키를 사용합니다. 각 키는 언제나 하나의 동일한 레이블과 일대일로 대응해야 합니다. 각 `(groupKey, seriesKey)` 조합도 한 번만 사용하세요. 조합이 중복되면 입체 막대가 겹치고 탭 결과가 불안정해지거나 가려진 막대를 선택하지 못할 수 있습니다.

```swift
let chartData = records.map { record in
    KLDimensionalBarDatum(
        id: record.id.uuidString,
        groupKey: record.monthKey,
        groupLabel: record.localizedMonth,
        seriesKey: record.category.rawValue,
        seriesLabel: record.category.localizedName,
        value: record.amount,
        color: record.category.color
    )
}
```

각 ID는 고유하고 안정적이어야 하며 차트 값은 유한한 음이 아닌 수여야 합니다. KLCharts는 입력을 검증하거나 집계, 정렬, 정규화하지 않습니다.

## 2. 모드와 선택 상태 관리

```swift
@State private var mode = KLDimensionalBarChartMode.flat
@State private var selectedID: String?
@State private var resetToken = 0

KLDimensionalBarChart(
    data: chartData,
    mode: mode,
    emptyText: "표시할 데이터가 없습니다",
    accessibilityLabel: "월별 및 채널별 매출",
    selectedID: selectedID,
    resetToken: resetToken,
    flatMinimumGroupWidth: 76,
    axisValueFormatter: { $0.formatted(.number.precision(.fractionLength(0))) },
    onSelect: { selectedID = $0.id },
    onClearSelection: { selectedID = nil }
)
.frame(height: 300)
```

차트는 선택과 선택 해제 콜백을 동기적으로 호출하지만 `selectedID`를 소유하거나 변경하지 않습니다. 통합 앱이 상태를 갱신할지 결정하고 그 결과를 차트에 다시 전달해야 합니다. 입체 차트는 선택한 막대의 너비, 높이, 깊이를 1.06배로 확대하고 선택하지 않은 막대를 불투명도 0.56으로 표시합니다. 평면 차트의 선택하지 않은 막대는 불투명도 0.38입니다. 두 렌더러는 항상 마운트되어 있고 숨겨진 쪽은 투명도가 0이며 히트 테스트가 비활성화됩니다. 차트는 부모 뷰 영역을 채우고 넘치는 내용을 자르므로 유한한 높이가 필요합니다.

## 3. 입체 시점 초기화

`resetToken`을 변경하면 입체 차트의 요와 피치가 초기값으로 돌아갑니다. 평면 모드가 보이는 동안의 변경도 포함됩니다. 입체 모드로 전환할 때도 시점이 초기화됩니다.

```swift
Button("시점 초기화") {
    resetToken &+= 1
}
```

## 4. 많은 항목과 접근성 처리

`flatMinimumGroupWidth`를 지정하면 평면 차트 너비가 고유 그룹 수에 따라 늘어납니다. 계산된 너비가 컨테이너보다 클 때만 가로 스크롤이 활성화됩니다. 데이터가 있는 입체 차트에서는 Canvas가 하나의 접근성 요소로 제공되므로 내용을 요약한 `accessibilityLabel`을 지정해야 합니다. 입체 차트의 빈 상태와 평면 차트는 각 하위 뷰가 제공하는 의미 정보를 사용합니다.

`axisValueFormatter`는 뷰에 저장되고 레이아웃이나 그리기 중 여러 번 호출될 수 있습니다. 기본 formatter는 입력을 반올림한 뒤 `Int`로 변환합니다. 반올림한 값은 `Int`로 표현할 수 있어야 합니다. NaN, 무한대, `Int` 범위를 벗어나는 유한 값은 런타임 오류를 일으킬 수 있습니다. 다른 입력 범위가 필요하면 사용자 정의 formatter를 제공하세요. 클로저 안에는 무거운 작업을 넣지 마세요. `showsSeriesLabels`는 입체 차트의 시리즈 축 레이블만 제어하며 평면 차트에 범례를 추가하지 않습니다.

## 통합 확인 목록

- [ ] ID가 고유하고 안정적임
- [ ] 모든 값이 유한한 음이 아닌 수임
- [ ] 각 키가 언제나 하나의 동일한 레이블과 일대일로 대응함
- [ ] `(groupKey, seriesKey)` 조합이 중복되지 않음
- [ ] 표시 문자열과 의미 색상을 통합 앱에서 결정함
- [ ] 차트에 유한한 높이를 지정함
- [ ] 선택 상태를 통합 앱이 저장하고 차트에 다시 전달함
- [ ] 입체 모드에 충분한 접근성 레이블을 제공함
