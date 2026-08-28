# KLCharts API 레퍼런스

> <span lang="ko">[English](../../README.md) · [简体中文](../zh-Hans/README.md) · [繁體中文](../zh-Hant/README.md) · [日本語](../ja/README.md) · [한국어](../ko/README.md)</span>

KLCharts는 `.flat`과 `.dimensional` 두 가지 막대 차트를 제공합니다. 선택 상태, 숫자 형식, 색상, 원본 데이터, 화면 이동은 앱에서 관리합니다. 패키지는 그리기, 모드 전환, 탭 판정, 항목이 많을 때의 가로 스크롤을 담당합니다.

## 공개 API

- `KLDimensionalBarDatum`: 막대, 그룹, 시리즈를 식별하는 안정적인 ID와 표시 이름, 값, 색상을 담습니다.
- `KLDimensionalBarChartMode`: 평면 차트인 `.flat`과 입체 차트인 `.dimensional`을 선택합니다.
- `KLDimensionalBarChart`: 두 렌더러를 계속 유지하면서 투명도와 탭 수신 여부를 바꿔 표시 모드를 전환합니다.
- `KLFlatBarChartLayout.chartWidth`: 실제로 그리지 않고 가로 방향에 필요한 너비를 계산합니다.
- `KLDimensionalHitTesting.acceptsTap`: 탭 거리와 반경이 유효한 값인지 확인하고 경계를 포함해 판정합니다.

## 전체 시그니처

```swift
public struct KLDimensionalBarDatum: Identifiable {
    public let id: String
    public let groupKey: String
    public let groupLabel: String
    public let seriesKey: String
    public let seriesLabel: String
    public let value: Double
    public let color: Color

    public init(
        id: String,
        groupKey: String,
        groupLabel: String,
        seriesKey: String,
        seriesLabel: String,
        value: Double,
        color: Color
    )
}
```

```swift
public enum KLDimensionalBarChartMode: String, CaseIterable, Identifiable {
    case flat
    case dimensional
    public var id: String { rawValue }
}
```

```swift
public struct KLDimensionalBarChart: View {
    public init(
        data: [KLDimensionalBarDatum],
        mode: KLDimensionalBarChartMode,
        emptyText: String,
        accessibilityLabel: String = "",
        selectedID: String? = nil,
        resetToken: Int = 0,
        showsSeriesLabels: Bool = true,
        flatMinimumGroupWidth: CGFloat? = nil,
        axisValueFormatter: @escaping (Double) -> String = {
            Int($0.rounded()).formatted()
        },
        onSelect: ((KLDimensionalBarDatum) -> Void)? = nil,
        onClearSelection: (() -> Void)? = nil
    )
}
```

```swift
public enum KLFlatBarChartLayout {
    public static func chartWidth(
        availableWidth: CGFloat,
        groupCount: Int,
        minimumGroupWidth: CGFloat
    ) -> CGFloat
}
```

```swift
public enum KLDimensionalHitTesting {
    public static func acceptsTap(
        distance: CGFloat,
        hitRadius: CGFloat
    ) -> Bool
}
```

```swift
@State private var selectedID: String?
@State private var resetToken = 0

KLDimensionalBarChart(
    data: data,
    mode: .dimensional,
    emptyText: "표시할 데이터가 없습니다",
    selectedID: selectedID,
    resetToken: resetToken,
    onSelect: { selectedID = $0.id },
    onClearSelection: { selectedID = nil }
)

Button("시점 초기화") {
    resetToken &+= 1
}
```

## 데이터 계약

- `id`는 SwiftUI 식별과 `selectedID` 비교에 사용됩니다. 패키지는 고유성을 검사하지 않습니다. 같은 ID를 다시 쓰면 여러 막대가 선택된 것처럼 보일 수 있고 SwiftUI도 항목을 명확히 식별할 수 없습니다.
- `groupKey`와 `seriesKey`는 현지화하지 않는 업무 식별자입니다. 입체 차트에서는 각 키가 배열에서 처음 나타나는 위치가 그룹과 시리즈 순서를 정합니다. 평면 차트의 너비와 탭 위치 근사 계산에도 키를 사용합니다.
- `groupLabel`과 `seriesLabel`은 입력한 그대로 표시되며 패키지가 번역하지 않습니다. Swift Charts는 레이블로 평면 막대의 위치를 정하므로 각 키는 언제나 하나의 동일한 레이블과 일대일로 대응해야 합니다.
- `value`는 검증되지 않습니다. 두 렌더러는 유한한 음이 아닌 값을 전제로 하며 음수나 유한하지 않은 값을 전달하면 의미 없는 결과 또는 프레임워크 구현에 따라 달라지는 결과가 나올 수 있습니다.
- `color`는 통합 앱이 제공하는 SwiftUI 의미 색상입니다. 평면 차트는 그라데이션을 적용하고 입체 차트는 선택 투명도와 면 조명을 추가합니다. 동적 색상은 현재 환경에 맞춰 해석됩니다.

초기화 메서드는 모든 인자를 그대로 저장하며 검증, 정렬, 변환하지 않습니다. 각 `(groupKey, seriesKey)` 조합에는 데이터가 하나만 있어야 합니다. 같은 조합이 여러 번 나오면 입체 차트에서 막대가 겹치고 탭 선택 결과가 불안정해집니다. 가려진 막대를 탭으로 선택할 수 없을 수도 있습니다.

## 모드 계약

- `.flat`은 Swift Charts 평면 차트를 표시합니다.
- `.dimensional`은 SwiftUI Canvas 입체 차트를 표시합니다.
- `id`는 원시 문자열 `"flat"` 또는 `"dimensional"`을 반환합니다. 1.0 이전에는 마이그레이션이 보장되는 장기 저장 형식으로 사용하지 마세요.

## 차트 속성과 초기화 인자

- `data`는 원본 배열 순서대로 두 렌더러에 전달됩니다. 빈 배열이면 `emptyText`가 표시됩니다.
- `mode`는 보이고 입력을 받는 렌더러를 정합니다. 다른 렌더러도 계속 마운트되어 있지만 투명도가 0이고 히트 테스트가 비활성화됩니다.
- `emptyText`는 통합 앱에서 현지화합니다.
- `accessibilityLabel`은 데이터가 있는 입체 차트에 적용됩니다. 빈 문자열이면 `emptyText`를 사용합니다. 입체 차트의 빈 상태와 평면 모드는 각 하위 뷰가 제공하는 접근성 의미 정보를 사용합니다.
- `selectedID`는 통합 앱이 관리합니다. 알 수 없는 ID는 어떤 막대와도 일치하지 않고 같은 ID를 다시 쓰면 여러 막대가 선택 상태로 보일 수 있습니다. 입체 차트는 선택한 막대의 너비, 높이, 깊이를 1.06배로 확대하고 선택하지 않은 막대를 불투명도 0.56으로 표시합니다. 평면 차트의 선택하지 않은 막대는 불투명도 0.38입니다. `nil`이면 선택 효과를 적용하지 않습니다.
- `resetToken`이 바뀔 때마다 입체 차트 시점이 초기값으로 돌아갑니다. 평면 모드가 보이는 동안의 변경도 포함됩니다. 입체 모드로 전환할 때도 시점이 초기화됩니다.
- `showsSeriesLabels`는 입체 차트의 시리즈 축 레이블만 제어하고 평면 차트에 범례를 추가하지 않습니다.
- `flatMinimumGroupWidth`는 평면 모드에서 고유 그룹마다 확보할 최소 너비입니다. `nil`은 0으로 처리됩니다. 계산된 너비가 컨테이너보다 클 때만 가로 스크롤이 활성화됩니다.
- `axisValueFormatter`는 뷰에 저장되고 두 렌더러의 숫자 레이블에 사용됩니다. 레이아웃과 Canvas 그리기 중 반복해서 호출될 수 있습니다. 기본 구현은 값을 가장 가까운 정수로 반올림하고 `Int`로 변환한 뒤 `formatted()`를 호출합니다. 반올림한 값은 `Int`로 표현할 수 있어야 합니다. NaN, 무한대, `Int` 범위를 벗어나는 유한 값은 런타임 오류를 일으킬 수 있습니다. 사용자 정의 formatter는 다른 입력 범위를 정할 수 있습니다.
- `onSelect`는 탭이 데이터에 적중하면 동기적으로 호출됩니다. `onClearSelection`은 적중하지 않으면 동기적으로 호출됩니다. 두 콜백은 뷰에 저장되며 차트는 선택 상태를 직접 바꾸지 않습니다.
- `body`는 두 렌더러를 같은 `ZStack`에 배치하고 부모 뷰가 제공한 너비와 높이를 채운 뒤 넘치는 내용을 자릅니다. 모드 투명도에는 0.22초 이즈 인 아웃 애니메이션이 적용됩니다. 통합 앱에서 유한한 높이를 지정해야 합니다.

공개 뷰와 데이터 형식은 SwiftUI 값과 클로저를 포함하며 `Sendable`을 선언하지 않습니다. 다른 SwiftUI 상태와 같은 UI 격리 컨텍스트에서 만들고 갱신하세요.

## 레이아웃 함수의 정확한 동작

`chartWidth`는 `max(availableWidth, CGFloat(max(groupCount, 1)) * minimumGroupWidth)`를 반환합니다.

- 1보다 작은 `groupCount`는 1로 처리됩니다.
- 0 또는 음수인 `minimumGroupWidth`도 그대로 계산에 사용됩니다.
- 음수 `availableWidth`도 그대로 계산에 사용됩니다.
- NaN과 양수 또는 음수 무한대는 보정하지 않습니다. 결과는 Swift의 `CGFloat` 곱셈과 `max` 비교를 따릅니다.

## 히트 테스트 함수의 정확한 동작

`acceptsTap`은 두 인자가 모두 유한하고 `hitRadius >= 0`이며 `distance <= hitRadius`일 때만 `true`를 반환합니다.

- 반경과 같은 거리는 적중합니다.
- 음수 반경, NaN, 양수 또는 음수 무한대 반경은 거부됩니다.
- NaN과 양수 또는 음수 무한대 거리는 거부됩니다.
- 유한한 음수 거리는 음이 아닌 반경보다 작거나 같으므로 허용됩니다. 이 함수는 거리를 정규화하지 않습니다.

## 동작 보장

- 두 표시 방식에서 같은 데이터 모델 사용
- 모드를 전환해도 주변 레이아웃 유지
- 선택 상태와 선택 해제는 앱에서 관리
- 입체 차트의 드래그, 시점 초기화, 탭 판정
- 항목 수에 따라 평면 차트를 가로로 스크롤

## 책임 경계

이 패키지는 앱에서 준비한 데이터를 그리는 일만 담당합니다. 데이터 집계, 현지화, 테마 결정, 선택 상태 저장, 범례, 막대를 눌렀을 때의 화면 이동은 앱에서 구현해야 합니다.
