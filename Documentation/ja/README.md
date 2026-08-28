# KLCharts

> <span lang="ja">[English](../../README.md) · [简体中文](../zh-Hans/README.md) · [繁體中文](../zh-Hant/README.md) · [日本語](../ja/README.md) · [한국어](../ko/README.md)</span>

同じデータを、Swift Charts の平面表示と、操作できる立体的な Canvas 表示で切り替えられます。表示を変えても周囲のレイアウトは動きません。

KLCharts は、`.flat` と `.dimensional` の2種類の棒グラフを提供します。選択状態、数値の書式、色、元データ、画面遷移はアプリ側で管理し、パッケージは描画、モード切り替え、タップ判定、項目が多い場合の横スクロールを担当します。

## 概要

- 2種類の表示で共通のデータモデルを使用
- 表示を切り替えても周囲のレイアウトを維持
- 選択状態と選択解除はアプリ側で管理
- 立体表示のドラッグ操作、視点のリセット、タップ判定
- 項目数に応じて平面表示を横スクロール

## 要件

- Swift 6.0 以降
- iOS 17 以降
- macOS 14 以降
- 実行時に利用するサードパーティ製ライブラリなし
- SwiftUI · Swift Charts

## 導入

Xcode の「Add Package Dependencies」からリポジトリを追加するか、`Package.swift` に次のように記述します。

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

## はじめに

1. 表示用の文字列と意味に対応する色をアプリ側で決定し、データを作成します。
2. チャートには明示的な高さを指定します。
3. 安定した ID を使い、`selectedID` と選択時のコールバックを接続します。
4. 項目が多い場合は `flatMinimumGroupWidth` を調整し、Canvas には内容を説明するアクセシビリティ情報を設定します。

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
            seriesLabel: "オンライン",
            value: 42,
            color: .teal
        ),
        KLDimensionalBarDatum(
            id: "jan-store",
            groupKey: "jan",
            groupLabel: "1月",
            seriesKey: "store",
            seriesLabel: "店舗",
            value: 28,
            color: .indigo
        )
    ]

    var body: some View {
        KLDimensionalBarChart(
            data: data,
            mode: mode,
            emptyText: "売上データがありません",
            accessibilityLabel: "月別・販売経路別の売上",
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

## 動作保証

立体表示では `groupKey` と `seriesKey` が最初に現れる位置で順序が決まります。平面表示は `groupLabel` と `seriesLabel` で棒を配置しますが、幅とタップ位置の近似計算にはキーを使います。各キーは常に 1 つの同じラベルと対応させ、各 `(groupKey, seriesKey)` の組み合わせは 1 件だけにしてください。同じ組み合わせが複数あると立体表示で棒が重なり、タップ選択が不安定になったり、隠れた棒を選べなくなったりします。

チャートは選択コールバックを同期的に呼び出しますが、選択状態は組み込み先アプリが管理します。立体表示では選択した棒の幅、高さ、奥行きが 1.06 倍になり、未選択の棒は不透明度 0.56 で表示されます。平面表示の未選択の棒は不透明度 0.38 です。既定の数値 formatter は丸めた入力を `Int` に変換するため、その値は `Int` で表現できる必要があります。NaN、無限大、範囲外になる有限値は実行時エラーを起こす場合があります。独自の formatter では別の入力範囲を定義できます。

- `KLDimensionalBarDatum`：棒、グループ、系列を識別する安定した ID と、表示名、値、色を保持します。
- `KLDimensionalBarChartMode`：平面表示の `.flat` と立体表示の `.dimensional` を切り替えます。
- `KLDimensionalBarChart`：2つの描画方式を保持したまま、透明度とタップ受付の切り替えで表示モードを変更します。
- `KLFlatBarChartLayout.chartWidth`：描画を行わず、横方向に必要な幅を計算します。
- `KLDimensionalHitTesting.acceptsTap`：タップ位置と半径が有限値であることを確認し、境界を含めて当たり判定を行います。

## 責務の境界

このパッケージは、アプリ側で準備したデータの描画だけを行います。集計処理、ローカライズ、テーマの決定、選択状態の保存、凡例、棒グラフからの画面遷移はアプリ側で実装してください。

## ドキュメント

- [はじめに](GettingStarted.md)
- [API リファレンス](API.md)
- [アーキテクチャ](Architecture.md)
- [移行](Migration.md)
- [デモアプリ](../../Examples/Documentation/ja/README.md)
- [セキュリティポリシー](SECURITY.md)
- [行動規範](CODE_OF_CONDUCT.md)
- [変更履歴](CHANGELOG.md)

## ステータス

現在の API は 1.0 未満です。wondays で実際に使用していますが、安定版にするまでは、マイナーアップデートで名前や設定方法を見直すことがあります。

## ライセンス

MIT. [LICENSE](../../LICENSE)
