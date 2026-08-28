# KLCharts API リファレンス

> <span lang="ja">[English](../../README.md) · [简体中文](../zh-Hans/README.md) · [繁體中文](../zh-Hant/README.md) · [日本語](../ja/README.md) · [한국어](../ko/README.md)</span>

KLCharts は、`.flat` と `.dimensional` の2種類の棒グラフを提供します。選択状態、数値の書式、色、元データ、画面遷移はアプリ側で管理し、パッケージは描画、モード切り替え、タップ判定、項目が多い場合の横スクロールを担当します。

## 公開 API

- `KLDimensionalBarDatum`：棒、グループ、系列を識別する安定した ID と、表示名、値、色を保持します。
- `KLDimensionalBarChartMode`：平面表示の `.flat` と立体表示の `.dimensional` を切り替えます。
- `KLDimensionalBarChart`：2つの描画方式を保持したまま、透明度とタップ受付の切り替えで表示モードを変更します。
- `KLFlatBarChartLayout.chartWidth`：描画を行わず、横方向に必要な幅を計算します。
- `KLDimensionalHitTesting.acceptsTap`：タップ位置と半径が有限値であることを確認し、境界を含めて当たり判定を行います。

## 完全なシグネチャ

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
    emptyText: "表示するデータがありません",
    selectedID: selectedID,
    resetToken: resetToken,
    onSelect: { selectedID = $0.id },
    onClearSelection: { selectedID = nil }
)

Button("視点をリセット") {
    resetToken &+= 1
}
```

## データの契約

- `id` は SwiftUI の識別と `selectedID` の照合に使われます。パッケージは一意性を検証しません。同じ ID を再利用すると複数の棒が選択状態になり、SwiftUI でも項目を明確に識別できなくなります。
- `groupKey` と `seriesKey` はローカライズしない業務上の識別子です。立体表示では各キーが配列内で最初に現れる位置によってグループと系列の順序が決まります。平面表示の幅とタップ位置の近似計算にもキーが使われます。
- `groupLabel` と `seriesLabel` はそのまま表示され、パッケージ内では翻訳されません。Swift Charts は平面表示の棒をラベルで配置するため、各キーは常に 1 つの同じラベルと対応させてください。
- `value` は検証されません。2 つの描画方式は有限の非負値を前提としており、負値や非有限値を渡した場合は意味のない結果やフレームワークの実装に依存する結果になる可能性があります。
- `color` は組み込み先のアプリが指定する SwiftUI のセマンティックカラーです。平面表示ではグラデーションが適用され、立体表示では選択時の透明度と面ごとの明暗が加わります。動的カラーは現在の環境に応じて解決されます。

イニシャライザは各引数をそのまま保持し、検証、並べ替え、変換を行いません。各 `(groupKey, seriesKey)` の組み合わせに対応するデータは 1 件までにしてください。同じ組み合わせが複数あると立体表示で棒が重なり、タップによる選択が不安定になります。隠れた棒をタップで選べなくなる場合もあります。

## モードの契約

- `.flat` は Swift Charts の平面表示です。
- `.dimensional` は SwiftUI Canvas の立体表示です。
- `id` は raw value の `"flat"` または `"dimensional"` を返します。1.0 より前の段階では、移行保証のある永続化形式として扱わないでください。

## チャートのプロパティと初期化引数

- `data` は元の配列順のまま両方の描画方式へ渡されます。空配列の場合は `emptyText` が表示されます。
- `mode` は表示とヒットテストを有効にする描画方式を指定します。もう一方も保持されますが、透明度がゼロになり、ヒットテストが無効になります。
- `emptyText` は組み込み先のアプリでローカライズしてください。
- `accessibilityLabel` はデータがある立体表示に適用されます。空文字列の場合は `emptyText` が使われます。立体表示の空状態と平面表示では、それぞれの子ビューが持つアクセシビリティセマンティクスが使われます。
- `selectedID` は組み込み先アプリで管理します。存在しない ID はどの棒にも一致せず、同じ ID を再利用すると複数の棒が選択表示になる場合があります。立体表示では選択した棒の幅、高さ、奥行きが 1.06 倍になり、未選択の棒は不透明度 0.56 で表示されます。平面表示の未選択の棒は不透明度 0.38 です。`nil` の場合は選択表示を適用しません。
- `resetToken` が変わるたびに立体表示の視点が初期値へ戻ります。平面表示中の変更も対象です。立体表示へ切り替えたときにもリセットされます。
- `showsSeriesLabels` は立体表示の系列軸ラベルだけを制御し、平面表示に凡例を追加しません。
- `flatMinimumGroupWidth` は平面表示で各グループに割り当てる最小幅です。`nil` はゼロとして扱われます。計算後の幅がコンテナを超えた場合だけ横スクロールが有効になります。
- `axisValueFormatter` はビューに保持され、両方の描画方式で数値ラベルに使われます。レイアウトや Canvas の描画中に繰り返し呼ばれる場合があります。既定の処理は値を整数へ丸め、`Int` に変換して `formatted()` を呼び出します。丸めた値は `Int` で表現できる必要があります。NaN、無限大、または `Int` の範囲外になる有限値は実行時エラーを起こす場合があります。独自の formatter では別の入力範囲を定義できます。
- `onSelect` はタップがデータに命中したときに同期的に呼ばれます。`onClearSelection` は命中しなかったときに同期的に呼ばれます。どちらもビューに保持され、チャート自身は選択状態を変更しません。
- `body` は 2 つの描画ビューを同じ `ZStack` に置き、親ビューから与えられた幅と高さを埋め、はみ出した内容を切り取ります。モードの透明度には 0.22 秒のイーズイン・イーズアウトが適用されます。アプリ側で有限の高さを指定してください。

公開ビューとデータ型は SwiftUI の値とクロージャを含み、`Sendable` には準拠していません。他の SwiftUI 状態と同じ UI 分離コンテキストで作成、更新してください。

## レイアウト関数の正確な動作

`chartWidth` は `max(availableWidth, CGFloat(max(groupCount, 1)) * minimumGroupWidth)` を返します。

- 1 未満の `groupCount` は 1 として扱われます。
- ゼロまたは負の `minimumGroupWidth` もそのまま計算に使われます。
- 負の `availableWidth` もそのまま計算に使われます。
- NaN と正負の無限大は補正されません。結果は Swift の `CGFloat` の乗算と `max` 比較に従います。

## ヒットテスト関数の正確な動作

`acceptsTap` が `true` を返すのは、両方の引数が有限で、`hitRadius >= 0` かつ `distance <= hitRadius` の場合だけです。

- 半径と等しい距離は命中します。
- 負の半径、NaN、正負の無限大の半径は拒否されます。
- NaN と正負の無限大の距離は拒否されます。
- 有限の負距離は、非負の半径以下であるため受け入れられます。この関数は距離を正規化しません。

## 動作保証

- 2種類の表示で共通のデータモデルを使用
- 表示を切り替えても周囲のレイアウトを維持
- 選択状態と選択解除はアプリ側で管理
- 立体表示のドラッグ操作、視点のリセット、タップ判定
- 項目数に応じて平面表示を横スクロール

## 責務の境界

このパッケージは、アプリ側で準備したデータの描画だけを行います。集計処理、ローカライズ、テーマの決定、選択状態の保存、凡例、棒グラフからの画面遷移はアプリ側で実装してください。
