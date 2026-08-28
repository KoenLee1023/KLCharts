# KLCharts API 參考

> <span lang="zh-TW">[English](../../README.md) · [简体中文](../zh-Hans/README.md) · [繁體中文](../zh-Hant/README.md) · [日本語](../ja/README.md) · [한국어](../ko/README.md)</span>

KLCharts 提供 `.flat` 與 `.dimensional` 兩種長條圖渲染器。選取、格式、色彩、業務資料與導覽由整合端 App 管理。套件負責穩定幾何、模式切換、命中測試與密集分組的水平延伸。

## 公開 API

- `KLDimensionalBarDatum`：穩定的長條、群組與系列識別，加上顯示標籤、數值與色彩。
- `KLDimensionalBarChartMode`：`.flat` 或 `.dimensional`。
- `KLDimensionalBarChart`：兩個渲染器保持掛載，以透明度與命中測試切換。
- `KLFlatBarChartLayout.chartWidth`：無需渲染即可預測水平畫布寬度。
- `KLDimensionalHitTesting.acceptsTap`：對有限距離與命中半徑進行含邊界判斷。

## 完整簽名

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
    emptyText: "沒有資料",
    selectedID: selectedID,
    resetToken: resetToken,
    onSelect: { selectedID = $0.id },
    onClearSelection: { selectedID = nil }
)

Button("重設視點") {
    resetToken &+= 1
}
```

## 資料契約

- `id` 用於 SwiftUI 識別與 `selectedID` 比對。套件不檢查唯一性。重複 ID 可能讓多個長條同時呈現選取狀態，也會使 SwiftUI 無法明確識別項目。
- `groupKey` 與 `seriesKey` 是不應本地化的業務識別。立體圖依各鍵在陣列中第一次出現的位置排列群組與系列。平面圖的寬度與點按近似計算也使用這些鍵。
- `groupLabel` 與 `seriesLabel` 會直接顯示，套件不會翻譯。Swift Charts 使用標籤定位平面圖中的長條，因此每個鍵必須始終一對一對應到同一個標籤。
- `value` 不會經過驗證。兩個渲染器都以有限的非負數為設計前提，負數或非有限值可能產生無意義或依賴框架實作的結果。
- `color` 是整合端 App 提供的 SwiftUI 語意色彩。平面圖使用其漸層，立體圖會加入選取透明度與表面明暗。動態色彩依目前環境解析。

初始化器只保存參數，不會驗證、排序或轉換。每個 `(groupKey, seriesKey)` 組合最多應對應一筆資料。重複組合會在立體圖中占用相同位置，長條彼此遮擋，點按選取也可能不穩定，甚至無法選取被遮住的長條。

## 模式契約

- `.flat` 顯示 Swift Charts 平面圖。
- `.dimensional` 顯示 SwiftUI Canvas 立體圖。
- `id` 回傳原始字串 `"flat"` 或 `"dimensional"`。1.0 之前不應把這些值視為具備遷移保證的長期儲存格式。

## 圖表屬性與初始化參數

- `data` 依原始陣列順序交給兩個渲染器。空陣列顯示 `emptyText`。
- `mode` 決定可見且可接收點按的渲染器。另一個渲染器仍會掛載，只是透明度為零並停用命中測試。
- `emptyText` 由整合端 App 完成本地化。
- `accessibilityLabel` 套用於有資料的立體圖。空字串會改用 `emptyText`。立體圖空狀態與平面模式使用各自子視圖提供的輔助使用語意。
- `selectedID` 由整合端 App 管理。未知 ID 不會符合任何長條，重複 ID 可能同時選取多個長條。立體圖會將選取長條的寬、高、深放大為 1.06 倍，未選取長條使用 0.56 透明度。平面圖的未選取長條使用 0.38 透明度。`nil` 表示不套用選取效果。
- `resetToken` 的任何變化都會還原立體圖的初始視點，平面模式可見時也一樣。切換至立體模式時還會再重設一次。
- `showsSeriesLabels` 只控制立體圖的系列軸標籤，不會替平面圖加入圖例。
- `flatMinimumGroupWidth` 是平面模式中每個唯一群組的最小寬度。`nil` 視為零。計算結果超過容器後才會啟用水平捲動。
- `axisValueFormatter` 會由視圖保存，並用於兩個渲染器的數值標籤。版面配置與 Canvas 繪製期間可能多次呼叫。預設實作先四捨五入，再轉為 `Int` 並呼叫 `formatted()`。四捨五入後的值必須能以 `Int` 表示。NaN、無限值與超出 `Int` 範圍的有限值都可能觸發執行階段錯誤。自訂 formatter 可以定義其他格式化輸入範圍。
- `onSelect` 在點按命中資料時同步呼叫。`onClearSelection` 在點按未命中時同步呼叫。兩個閉包都會由視圖保存，圖表本身不會修改選取狀態。
- `body` 把兩個渲染器放在同一個 `ZStack`，填滿父視圖提供的寬高並裁切超出範圍的內容。模式透明度使用 0.22 秒緩動動畫。整合端 App 必須提供有限高度。

公開視圖與資料類型包含 SwiftUI 值和閉包，沒有宣告 `Sendable`。請在與其他 SwiftUI 狀態相同的 UI 隔離環境中建立和更新。

## 版面函式的精確行為

`chartWidth` 回傳 `max(availableWidth, CGFloat(max(groupCount, 1)) * minimumGroupWidth)`。

- 小於 1 的 `groupCount` 視為 1。
- 零或負的 `minimumGroupWidth` 會直接參與公式。
- 負的 `availableWidth` 也會直接參與公式。
- NaN 與正負無窮值不會被處理，結果遵循 Swift 的 `CGFloat` 乘法與 `max` 比較。

## 命中函式的精確行為

`acceptsTap` 只有在兩個參數都是有限值、`hitRadius >= 0` 且 `distance <= hitRadius` 時回傳 `true`。

- 等於半徑的邊界會命中。
- 負半徑、NaN 與正負無窮半徑會被拒絕。
- NaN 與正負無窮距離會被拒絕。
- 有限的負距離只要小於或等於非負半徑就會被接受。函式不會正規化距離。

## 行為保證

- 平面與投影視圖共用資料模型
- 切換模式不替換版面空間
- 整合端 App 控制選取與清除
- 維度拖曳、視點重設與命中測試
- 密集平面圖依群組寬度自動水平捲動

## 職責邊界

只渲染已解析資料。不聚合業務模型、不在套件內本地化標籤、不選擇主題、不保存選取、不產生圖例，也不從長條觸發導覽。
