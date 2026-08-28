# KLCharts デモアプリ

2 つのサンプルは、それぞれ独立した macOS 向け SwiftUI アプリです。個別の `Package.swift` とアプリのエントリポイントを持ち、このリポジトリのルートにある KLCharts パッケージだけに依存します。表示データはすべてサンプル用です。

## Geometry Gallery

Geometry Gallery は Q1 から Q4 までの 4 グループと、Series A、Series B というラベルの 2 系列を表示します。セグメントコントロールで同じデータを `.flat` と `.dimensional` に切り替えます。切り替え前後でチャートの表示領域は変わりません。色には mint と cyan を指定し、数値軸には既定の formatter を使っています。アクセシビリティ向けの概要も設定しています。

選択コールバック、独自の formatter、密集データの横スクロール、視点のリセット、空データ表示は扱いません。

## Interaction Lab

Interaction Lab は `.dimensional` モードだけを表示し、5 グループと 3 系列のデータを使います。副題には選択中のデータ ID が表示されます。棒をタップすると組み込み先アプリが選択状態を更新し、棒以外をタップすると選択解除のコールバックによって状態が消去されます。ドラッグすると立体表示の視点が変わります。リセットボタンは `resetToken` を増やし、初期視点へ戻します。選択した棒の強調と、それ以外の棒の淡色表示も確認できます。

モード切り替え、平面表示、横スクロール、独自の formatter、空データ表示は扱いません。

## ビルド

リポジトリ外に再利用可能なビルドディレクトリを用意し、各アプリを個別にビルドします。

```bash
swift build \
  --package-path Examples/GeometryGallery \
  --scratch-path <ビルドディレクトリ>/KLCharts-GeometryGallery

swift build \
  --package-path Examples/InteractionLab \
  --scratch-path <ビルドディレクトリ>/KLCharts-InteractionLab
```
