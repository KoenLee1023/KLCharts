# 使用 KLCharts

以同一組資料切換 Swift Charts 平面圖與可旋轉的 Canvas 立體圖，互動狀態則由整合端 App 管理。

## 概覽

### 加入套件

從 `0.1.0` 起加入 `https://github.com/KoenLee1023/KLCharts.git`，將 `KLCharts` 連結至 SwiftUI target，再匯入模組。

```swift
import KLCharts
import SwiftUI
```

KLCharts 支援 iOS 17、macOS 14 與 Swift 6，沒有第三方執行階段相依套件。

### 準備資料

先由整合端 App 完成標籤本地化與語意色彩設定，再建立 ``KLDimensionalBarDatum``。立體圖順序由各 `groupKey` 與 `seriesKey` 第一次出現的位置決定。平面圖依標籤安排長條，但寬度與點按近似計算仍使用鍵。每個鍵必須固定對應唯一標籤。

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

每個 ID 應保持穩定且唯一，數值應為有限的非負數。相同 `(groupKey, seriesKey)` 的多筆資料會占用同一個立體位置。重疊可能使命中結果不穩定，也可能讓被遮住的長條無法透過點按選取。套件不會驗證、彙總、排序或正規化輸入。

### 管理模式與選取狀態

``KLDimensionalBarChart`` 會同步呼叫互動回呼，但不擁有也不修改選取狀態。整合端 App 自行決定是否更新及如何更新，再把選取結果傳回 `selectedID`。

立體模式會把選取長條的寬度、高度與深度放大為 `1.06` 倍，其他長條使用 `0.56` 透明度。平面模式中的其他長條使用 `0.38` 透明度。

```swift
KLDimensionalBarChart(
    data: chartData,
    mode: mode,
    emptyText: "沒有資料",
    accessibilityLabel: "依月份與通路統計的收入",
    selectedID: selectedID,
    resetToken: resetToken,
    flatMinimumGroupWidth: 76,
    axisValueFormatter: { $0.formatted(.number.precision(.fractionLength(0))) },
    onSelect: { selectedID = $0.id },
    onClearSelection: { selectedID = nil }
)
.frame(height: 300)
```

圖表會填滿父視圖提供的空間並裁切超出範圍的內容，因此必須給予有限高度。兩個渲染器會持續掛載。切換模式時只改變透明度與命中測試，並以 0.22 秒交叉淡化。

### 重設立體視點

修改 `resetToken` 可還原立體圖的初始偏航角與俯仰角。即使平面圖目前可見，token 改變時仍會重設。切換至立體模式時也會再次重設。

```swift
Button("重設視點") {
    resetToken &+= 1
}
```

### 密集資料、格式與輔助使用

`flatMinimumGroupWidth` 依唯一群組數計算平面圖畫布寬度。只有畫布超過容器時才會啟用水平捲動。`showsSeriesLabels` 只控制立體圖的系列軸標籤，不會替平面圖加入圖例。

有資料的立體圖會把 Canvas 呈現為單一輔助使用元素，請提供完整的 `accessibilityLabel`。立體圖空狀態與平面圖使用各自子視圖提供的語意。`axisValueFormatter` 會由視圖保存，並可能在版面配置與繪製期間多次呼叫，閉包內不宜執行昂貴工作。預設 formatter 會把四捨五入後的結果轉成 `Int`。該結果必須能由 `Int` 表示，NaN、無窮值與超出 `Int` 範圍的有限值可能觸發執行階段錯誤。自訂 formatter 可定義其他輸入範圍，但不會修正無效的圖表幾何。

### 輸入邊界

``KLDimensionalHitTesting/acceptsTap(distance:hitRadius:)`` 會拒絕非有限值與負半徑，半徑邊界視為命中。函式不會拒絕有限的負距離。``KLFlatBarChartLayout/chartWidth(availableWidth:groupCount:minimumGroupWidth:)`` 只會把小於 1 的群組數視為 1，不會處理負寬度、NaN 或無窮值。
