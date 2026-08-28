# KLCharts 시작하기

하나의 데이터를 Swift Charts 평면 차트와 회전할 수 있는 Canvas 입체 차트로 표시하고, 상호작용 상태는 통합 앱에서 관리합니다.

## 개요

### 패키지 추가

`https://github.com/KoenLee1023/KLCharts.git`의 `0.1.0` 이상 버전을 추가하고 SwiftUI target에 `KLCharts`를 연결한 다음 모듈을 가져옵니다.

```swift
import KLCharts
import SwiftUI
```

KLCharts는 iOS 17, macOS 14, Swift 6 이상을 지원하며 타사 런타임 의존성이 없습니다.

### 데이터 준비

표시 문자열의 현지화와 의미 색상 선택을 통합 앱에서 마친 뒤 ``KLDimensionalBarDatum``을 만듭니다. 입체 차트의 순서는 각 `groupKey`와 `seriesKey`가 처음 나타나는 위치로 정해집니다. 평면 차트는 레이블로 막대를 배치하지만 너비와 탭 위치 근사 계산에는 키를 사용합니다. 각 키는 항상 하나의 동일한 레이블에 대응해야 합니다.

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

각 ID는 고유하고 안정적이어야 하며 차트 값은 유한한 음이 아닌 수여야 합니다. 같은 `(groupKey, seriesKey)`를 가진 데이터가 여러 개면 입체 차트의 같은 위치에서 겹칩니다. 겹침 때문에 탭 결과가 불안정해지거나 가려진 막대를 탭으로 선택하지 못할 수 있습니다. 패키지는 입력을 검증하거나 집계, 정렬, 정규화하지 않습니다.

### 모드와 선택 상태 관리

``KLDimensionalBarChart``는 상호작용 콜백을 동기적으로 호출하지만 선택 상태를 소유하거나 변경하지 않습니다. 통합 앱이 갱신 여부와 방법을 정하고 그 결과를 `selectedID`에 다시 전달합니다.

입체 모드에서는 선택한 막대의 너비, 높이, 깊이가 `1.06`배가 되고 나머지 막대의 불투명도는 `0.56`이 됩니다. 평면 모드에서는 나머지 막대의 불투명도가 `0.38`이 됩니다.

```swift
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

차트는 부모 뷰가 제공한 영역을 채우고 넘치는 내용을 자르므로 유한한 높이를 지정해야 합니다. 두 렌더러는 항상 마운트된 상태를 유지합니다. 모드를 바꾸면 투명도와 히트 테스트만 변경되며 0.22초 동안 교차 페이드가 적용됩니다.

### 입체 시점 초기화

`resetToken` 값을 변경하면 입체 차트의 요와 피치가 초기값으로 돌아갑니다. 평면 모드가 표시되는 동안 값이 바뀌어도 초기화가 실행됩니다. 입체 모드로 전환할 때도 시점이 다시 초기화됩니다.

```swift
Button("시점 초기화") {
    resetToken &+= 1
}
```

### 많은 항목과 접근성 처리

`flatMinimumGroupWidth`를 지정하면 고유 그룹 수에 따라 평면 차트 너비가 늘어납니다. 계산된 너비가 컨테이너보다 클 때만 가로 스크롤이 활성화됩니다. `showsSeriesLabels`는 입체 차트의 시리즈 축 레이블만 제어하며 평면 차트에 범례를 추가하지 않습니다.

데이터가 있는 입체 차트에서는 Canvas가 하나의 접근성 요소로 제공되므로 내용을 요약한 `accessibilityLabel`을 지정해야 합니다. 입체 차트의 빈 상태와 평면 차트는 각 하위 뷰가 제공하는 의미 정보를 사용합니다. `axisValueFormatter`는 뷰에 저장되고 레이아웃이나 그리기 중 여러 번 호출될 수 있으므로 무거운 작업을 넣지 마세요. 기본 formatter는 반올림한 값을 `Int`로 변환합니다. 반올림 결과를 `Int`로 표현할 수 있어야 하며 NaN, 무한대, `Int` 범위를 벗어난 유한한 값은 런타임 중단을 일으킬 수 있습니다. 사용자 정의 formatter는 다른 입력 범위를 정할 수 있지만 잘못된 차트 기하를 유효하게 만들지는 않습니다.

### 입력 경계

``KLDimensionalHitTesting/acceptsTap(distance:hitRadius:)``는 유한하지 않은 값과 음수 반경을 거부하고 반경과 같은 거리는 적중으로 처리합니다. 유한한 음수 거리는 거부하지 않습니다. ``KLFlatBarChartLayout/chartWidth(availableWidth:groupCount:minimumGroupWidth:)``는 1보다 작은 그룹 수만 1로 처리하며 음수 너비, NaN, 무한대를 보정하지 않습니다.
