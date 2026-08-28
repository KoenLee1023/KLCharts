# KLCharts: はじめに

> <span lang="ja">[English](../../README.md) · [简体中文](../zh-Hans/README.md) · [繁體中文](../zh-Hant/README.md) · [日本語](../ja/README.md) · [한국어](../ko/README.md)</span>

Xcode の「Add Package Dependencies」からリポジトリを追加するか、`Package.swift` に次のように記述します。

```swift
dependencies: [
    .package(
        url: "https://github.com/KoenLee1023/KLCharts.git",
        from: "0.1.0"
    )
]
```

動作環境は iOS 17、macOS 14、Swift 6 以降です。実行時に利用するサードパーティ製ライブラリはありません。

## 1. データを準備する

表示名のローカライズとセマンティックカラーの決定を組み込み先アプリで済ませてから、チャートデータを作成します。立体表示では、グループキーと系列キーが配列内で最初に現れる位置によって順序が決まります。平面表示はラベルで棒を配置する一方、幅とタップ位置の近似計算にはキーを使います。各キーは常に 1 つの同じラベルと対応させてください。また、各 `(groupKey, seriesKey)` の組み合わせは 1 件だけにしてください。同じ組み合わせが複数あると立体表示で棒が重なり、タップ結果が不安定になったり、隠れた棒を選べなくなったりします。

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

ID は項目ごとに一意かつ安定した値にし、グラフ値には有限の非負値を渡してください。KLCharts は入力の検証、集計、並べ替え、正規化を行いません。

## 2. モードと選択状態を管理する

```swift
@State private var mode = KLDimensionalBarChartMode.flat
@State private var selectedID: String?
@State private var resetToken = 0

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

チャートは選択と選択解除のコールバックを同期的に呼び出しますが、`selectedID` を所有したり変更したりしません。組み込み先アプリで状態を更新するかどうかを決め、その結果をチャートへ戻してください。立体表示では選択した棒の幅、高さ、奥行きが 1.06 倍になり、未選択の棒は不透明度 0.56 で表示されます。平面表示の未選択の棒は不透明度 0.38 です。2 つの描画ビューは常に保持され、非表示側は透明度がゼロになり、ヒットテストが無効になります。チャートは親ビューの領域を埋めてはみ出した内容を切り取るため、有限の高さが必要です。

## 3. 立体表示の視点を戻す

`resetToken` を変更すると、立体表示のヨー角とピッチ角が初期値に戻ります。平面表示中の変更も対象です。立体表示へ切り替えたときにもリセットされます。

```swift
Button("視点をリセット") {
    resetToken &+= 1
}
```

## 4. 項目数が多い場合とアクセシビリティ

`flatMinimumGroupWidth` を設定すると、平面表示の幅がグループ数に応じて広がります。計算後の幅がコンテナを超えた場合だけ横スクロールが有効になります。データがある立体表示では Canvas が 1 つのアクセシビリティ要素として扱われるため、内容を要約した `accessibilityLabel` を指定してください。立体表示の空状態と平面表示では、それぞれの子ビューが持つセマンティクスが使われます。

`axisValueFormatter` はビューに保持され、レイアウトや描画中に複数回呼ばれる場合があります。既定の formatter は入力を丸めて `Int` に変換します。丸めた値は `Int` で表現できる必要があります。NaN、無限大、または `Int` の範囲外になる有限値は実行時エラーを起こす場合があります。別の入力範囲が必要な場合は独自の formatter を指定してください。重い処理は避けてください。`showsSeriesLabels` は立体表示の系列軸ラベルだけを制御し、平面表示に凡例を追加しません。

## 組み込み時の確認事項

- [ ] ID が一意で安定している
- [ ] 値がすべて有限の非負値である
- [ ] 各キーが常に 1 つの同じラベルと対応している
- [ ] `(groupKey, seriesKey)` の組み合わせが重複していない
- [ ] 表示名とセマンティックカラーをアプリ側で解決している
- [ ] チャートに有限の高さを指定している
- [ ] 選択状態をアプリ側で保持し、チャートへ戻している
- [ ] 立体表示に十分なアクセシビリティラベルを指定している
