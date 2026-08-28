# KLCharts 示範 App

兩個範例都是獨立的 macOS SwiftUI App。它們各自包含 `Package.swift` 與 App 進入點，只依賴此儲存庫根目錄的 KLCharts 套件，並使用合成資料。

## Geometry Gallery

Geometry Gallery 顯示 Q1 至 Q4 四個季度群組，每組包含標籤為 Series A 與 Series B 的兩個系列。分段選擇器使用同一組資料在 `.flat` 與 `.dimensional` 之間切換，圖表始終占用相同的視圖空間。App 提供薄荷色與青色語意色彩，使用預設數值軸 formatter，並設定輔助使用摘要。

此範例沒有設定選取回呼、自訂 formatter、密集資料水平捲動、視點重設或空資料狀態。

## Interaction Lab

Interaction Lab 只顯示 `.dimensional` 模式，使用五個群組與三個系列。副標題會顯示目前選取資料的 ID。點按命中後，整合端 App 更新自行管理的選取狀態。點按未命中時，清除回呼會移除選取。拖曳可以改變立體視點，重設按鈕則透過增加 `resetToken` 還原初始視點。選取後也可觀察立體圖的放大與淡化效果。

此範例不會切換模式，也不顯示平面圖、水平捲動、自訂 formatter 或空資料狀態。

## 建置

請為兩個 App 分別使用儲存庫外可重複使用的建置目錄：

```bash
swift build \
  --package-path Examples/GeometryGallery \
  --scratch-path <建置目錄>/KLCharts-GeometryGallery

swift build \
  --package-path Examples/InteractionLab \
  --scratch-path <建置目錄>/KLCharts-InteractionLab
```
