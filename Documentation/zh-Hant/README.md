# KLCharts

> <span lang="zh-TW">[English](../../README.md) · [简体中文](../zh-Hans/README.md) · [繁體中文](../zh-Hant/README.md) · [日本語](../ja/README.md) · [한국어](../ko/README.md)</span>

同一組分組資料，兩種呈現方式：精確的 Swift Charts 平面圖與可探索的立體 Canvas，共用穩定版面。

KLCharts 提供 `.flat` 與 `.dimensional` 兩種長條圖渲染器。選取、格式、色彩、業務資料與導覽由整合端 App 管理。套件負責穩定幾何、模式切換、命中測試與密集分組的水平延伸。

## 概覽

- 平面與投影視圖共用資料模型
- 切換模式不替換版面空間
- 整合端 App 控制選取與清除
- 維度拖曳、視點重設與命中測試
- 密集平面圖依群組寬度自動水平捲動

## 需求

- Swift 6.0 或更新版本
- iOS 17 或更新版本
- macOS 14 或更新版本
- 不含第三方執行階段相依套件
- SwiftUI · Swift Charts

## 安裝

透過 Xcode 的 Add Package Dependencies 加入儲存庫，或在 `Package.swift` 中宣告：

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

## 快速開始

1. 先在整合端 App 解析本地化標籤與語意色彩，再建立圖表資料。
2. 為圖表提供有限高度。圖表會填滿父容器給予的空間。
3. 以穩定 ID 往返 `selectedID` 與選取回呼。
4. 標籤擁擠時設定 `flatMinimumGroupWidth`，並為 Canvas 提供完整輔助使用說明。

```swift
struct RevenueChart: View {
    @State private var mode = KLDimensionalBarChartMode.flat
    @State private var selectedID: String?
    @State private var resetToken = 0

    let data = [
        KLDimensionalBarDatum(
            id: "jan-online",
            groupKey: "jan",
            groupLabel: "1月",
            seriesKey: "online",
            seriesLabel: "線上",
            value: 42,
            color: .teal
        ),
        KLDimensionalBarDatum(
            id: "jan-store",
            groupKey: "jan",
            groupLabel: "1月",
            seriesKey: "store",
            seriesLabel: "門市",
            value: 28,
            color: .indigo
        )
    ]

    var body: some View {
        KLDimensionalBarChart(
            data: data,
            mode: mode,
            emptyText: "尚無收入資料",
            accessibilityLabel: "依月份與通路統計的收入",
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

## 行為保證

立體圖依 `groupKey` 與 `seriesKey` 第一次出現的位置排序。平面圖以 `groupLabel` 和 `seriesLabel` 定位長條，但寬度與點按近似計算使用鍵。每個鍵必須始終一對一對應到同一個標籤，每個 `(groupKey, seriesKey)` 組合也只應出現一次。重複組合會在立體圖中重疊，導致點按選取不穩定，或讓被遮住的長條無法選取。

圖表會同步呼叫選取回呼，但選取狀態由整合端 App 管理。立體模式中，選取長條的寬、高、深為 1.06 倍，未選取長條使用 0.56 透明度。平面模式的未選取長條使用 0.38 透明度。預設數值 formatter 會把四捨五入後的輸入轉換為 `Int`，因此該值必須在 `Int` 可表示的範圍內。NaN、無限值與超出範圍的有限值可能觸發執行階段錯誤。自訂 formatter 可以定義其他輸入範圍。

- `KLDimensionalBarDatum`：穩定的長條、群組與系列識別，加上顯示標籤、數值與色彩。
- `KLDimensionalBarChartMode`：`.flat` 或 `.dimensional`。
- `KLDimensionalBarChart`：兩個渲染器保持掛載，以透明度與命中測試切換。
- `KLFlatBarChartLayout.chartWidth`：無需渲染即可預測水平畫布寬度。
- `KLDimensionalHitTesting.acceptsTap`：對有限距離與命中半徑進行含邊界判斷。

## 職責邊界

只渲染已解析資料。不聚合業務模型、不在套件內本地化標籤、不選擇主題、不保存選取、不產生圖例，也不從長條觸發導覽。

## 文件

- [快速開始](GettingStarted.md)
- [API 參考](API.md)
- [架構](Architecture.md)
- [遷移](Migration.md)
- [示範 App](../../Examples/Documentation/zh-Hant/README.md)
- [參與貢獻](CONTRIBUTING.md)
- [安全政策](SECURITY.md)
- [行為準則](CODE_OF_CONDUCT.md)
- [變更記錄](CHANGELOG.md)

## 狀態

此 API 目前仍在 1.0 之前。功能已用於 wondays 的真實產品情境，但在宣告穩定前，小版本仍可能調整命名或策略介面。

## 授權

MIT. [LICENSE](../../LICENSE)
