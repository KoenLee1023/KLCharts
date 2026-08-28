# KLCharts 遷移

> <span lang="zh-TW">[English](../../README.md) · [简体中文](../zh-Hans/README.md) · [繁體中文](../zh-Hant/README.md) · [日本語](../ja/README.md) · [한국어](../ko/README.md)</span>

先固定資料排序、色彩、選取、空狀態與容器尺寸。將業務模型映射為穩定的圖表資料，並列比較舊圖與套件視圖，檢查平面和立體模式。選取狀態繼續由整合端 App 持有。確認模式切換、捲動與輔助使用行為後，再移除舊渲染器。

## 檢查清單

- [ ] 先在整合端 App 解析本地化標籤與語意色彩，再建立圖表資料。
- [ ] 為圖表提供有限高度。圖表會填滿父容器給予的空間。
- [ ] 以穩定 ID 往返 `selectedID` 與選取回呼。
- [ ] 標籤擁擠時設定 `flatMinimumGroupWidth`，並為 Canvas 提供完整輔助使用說明。
- [ ] 執行套件測試
- [ ] 執行整合端 App 回歸測試
- [ ] 更新 API 參考與變更記錄
