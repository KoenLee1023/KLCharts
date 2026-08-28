# KLCharts を使い始める

同じデータを Swift Charts の平面グラフと、回転操作ができる Canvas の立体グラフで表示します。操作状態は組み込み先のアプリで管理します。

## 概要

### パッケージを追加する

`https://github.com/KoenLee1023/KLCharts.git` のバージョン `0.1.0` 以降を追加し、SwiftUI target に `KLCharts` をリンクしてからモジュールを読み込みます。

```swift
import KLCharts
import SwiftUI
```

動作環境は iOS 17、macOS 14、Swift 6 以降です。実行時に利用するサードパーティ製ライブラリはありません。

### データを準備する

表示名のローカライズとセマンティックカラーの決定をアプリ側で済ませてから、``KLDimensionalBarDatum`` を作成します。立体表示の順序は、各 `groupKey` と `seriesKey` が最初に現れる位置で決まります。平面表示はラベルで棒を配置しますが、幅とタップ位置の近似計算にはキーを使います。各キーには常に 1 つの同じラベルを対応させてください。

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

ID は項目ごとに一意かつ安定した値にし、グラフ値には有限の非負値を渡してください。同じ `(groupKey, seriesKey)` を持つ複数のデータは、立体表示で同じ位置に重なります。重なりによってタップ結果が不安定になり、隠れた棒をタップで選択できなくなる場合があります。パッケージは入力の検証、集計、並べ替え、正規化を行いません。

### モードと選択状態を管理する

``KLDimensionalBarChart`` は操作のコールバックを同期的に呼び出しますが、選択状態を所有したり変更したりしません。組み込み先アプリで更新の有無と方法を決め、その結果を `selectedID` に戻します。

立体表示では、選択した棒の幅、高さ、奥行きが `1.06` 倍になり、ほかの棒の透明度は `0.56` になります。平面表示では、ほかの棒の透明度が `0.38` になります。

```swift
KLDimensionalBarChart(
    data: chartData,
    mode: mode,
    emptyText: "表示するデータがありません",
    accessibilityLabel: "月別、チャネル別の売上",
    selectedID: selectedID,
    resetToken: resetToken,
    flatMinimumGroupWidth: 76,
    axisValueFormatter: { $0.formatted(.number.precision(.fractionLength(0))) },
    onSelect: { selectedID = $0.id },
    onClearSelection: { selectedID = nil }
)
.frame(height: 300)
```

グラフは親ビューから与えられた領域を埋め、はみ出した内容を切り取ります。高さは有限値で指定してください。2 つの描画ビューは常に保持され、モード切り替え時は透明度とヒットテストだけが変わります。切り替えには 0.22 秒のクロスフェードが適用されます。

### 立体表示の視点を戻す

`resetToken` の値を変更すると、立体表示のヨー角とピッチ角が初期値に戻ります。平面表示中に値を変更した場合もリセット処理が行われます。立体表示へ切り替えたときにも視点が初期化されます。

```swift
Button("視点をリセット") {
    resetToken &+= 1
}
```

### 項目数が多い場合とアクセシビリティ

`flatMinimumGroupWidth` を指定すると、平面表示の幅がグループ数に応じて広がります。計算後の幅がコンテナを超えた場合だけ横スクロールが有効になります。`showsSeriesLabels` は立体表示の系列軸ラベルだけを制御し、平面表示に凡例を追加するものではありません。

データがある立体表示では、Canvas が 1 つのアクセシビリティ要素として扱われます。内容を要約した `accessibilityLabel` を指定してください。立体表示の空状態と平面表示では、それぞれの子ビューが持つセマンティクスが使われます。`axisValueFormatter` はビューに保持され、レイアウトや描画のたびに複数回呼ばれる場合があります。重い処理は避けてください。既定の formatter は丸めた値を `Int` に変換します。丸めた結果が `Int` で表現できる必要があり、NaN、無限大、`Int` の範囲外にある有限値では実行時に停止する可能性があります。独自の formatter では別の入力範囲を定義できますが、不正なグラフ形状を有効にはできません。

### 入力値の境界

``KLDimensionalHitTesting/acceptsTap(distance:hitRadius:)`` は非有限値と負の半径を拒否し、半径と等しい距離は命中として扱います。有限の負距離は拒否しません。``KLFlatBarChartLayout/chartWidth(availableWidth:groupCount:minimumGroupWidth:)`` は 1 未満のグループ数だけを 1 として扱い、負の幅、NaN、無限大は補正しません。
