# KLCharts: 快速開始

> <span lang="zh-TW">[English](../../README.md) · [简体中文](../zh-Hans/README.md) · [繁體中文](../zh-Hant/README.md) · [日本語](../ja/README.md) · [한국어](../ko/README.md)</span>

透過 Xcode 的 Add Package Dependencies 加入儲存庫，或在 `Package.swift` 中宣告：

```swift
dependencies: [
    .package(
        url: "https://github.com/KoenLee1023/KLCharts.git",
        from: "0.1.0"
    )
]
```

KLCharts 支援 iOS 17、macOS 14 與 Swift 6，沒有第三方執行階段相依套件。

## 1. 準備資料

先由整合端 App 完成標籤本地化與語意色彩設定，再建立圖表資料。立體圖依群組鍵與系列鍵第一次出現的位置排序。平面圖按標籤定位長條，但寬度與點按近似計算使用鍵，因此每個鍵必須始終一對一對應到同一個標籤。每個 `(groupKey, seriesKey)` 組合只應出現一次。重複組合會讓立體長條重疊，點按結果可能不穩定，被遮住的長條也可能無法選取。

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

ID 應保持穩定且唯一，數值應為有限的非負數。KLCharts 不會驗證、彙總、排序或正規化輸入。

## 2. 管理模式與選取狀態

```swift
@State private var mode = KLDimensionalBarChartMode.flat
@State private var selectedID: String?
@State private var resetToken = 0

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

圖表會同步呼叫選取與清除回呼，但不會擁有或修改 `selectedID`。整合端 App 決定是否更新狀態，再把結果傳回圖表。立體圖會將選取長條的寬、高、深放大為 1.06 倍，未選取長條使用 0.56 透明度。平面圖的未選取長條使用 0.38 透明度。兩個渲染器會持續掛載，隱藏的一方透明度為零並停用命中測試。圖表會填滿並裁切父視圖提供的空間，因此必須給予有限高度。

## 3. 重設立體視點

修改 `resetToken` 可還原立體圖的初始偏航角與俯仰角。平面模式可見時修改也會重設。切換至立體模式時還會再次重設。

```swift
Button("重設視點") {
    resetToken &+= 1
}
```

## 4. 處理密集資料與輔助使用

設定 `flatMinimumGroupWidth` 後，平面圖會依唯一群組數延伸。只有計算寬度超過容器時才會啟用水平捲動。有資料的立體圖會把 Canvas 呈現為單一輔助使用元素，請提供完整的 `accessibilityLabel`。立體圖空狀態與平面圖使用各自子視圖的語意。

`axisValueFormatter` 會由視圖保存，並可能在版面配置與繪製期間多次呼叫。預設實作先四捨五入，再轉換為 `Int`。四捨五入後的值必須能以 `Int` 表示。NaN、無限值與超出 `Int` 範圍的有限值都可能觸發執行階段錯誤。若整合端 App 需要其他格式化輸入範圍，請提供自訂 formatter。閉包內不宜執行昂貴工作。`showsSeriesLabels` 只控制立體圖的系列軸標籤，不會替平面圖加入圖例。

## 整合檢查

- [ ] ID 穩定且唯一
- [ ] 數值都是有限的非負數
- [ ] 每個鍵始終一對一對應到同一個標籤
- [ ] 沒有重複的 `(groupKey, seriesKey)` 組合
- [ ] 整合端 App 已完成標籤本地化與語意色彩設定
- [ ] 圖表具有有限高度
- [ ] 選取狀態由整合端 App 保存並回傳
- [ ] 立體模式具有完整的輔助使用說明
