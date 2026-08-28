# KLCharts 데모 앱

> [English](../en/README.md) · [简体中文](../zh-Hans/README.md) · [繁體中文](../zh-Hant/README.md) · [日本語](../ja/README.md) · [한국어](../ko/README.md)

두 예제는 서로 독립된 macOS SwiftUI 앱입니다. 각각 `Package.swift`와 앱 진입점을 가지며 이 저장소 루트의 KLCharts 패키지만 사용합니다. 표시 데이터는 모두 예제용 합성 데이터입니다.

## Geometry Gallery

Geometry Gallery는 Q1부터 Q4까지 네 그룹과 Series A, Series B라는 레이블의 두 시리즈를 표시합니다. 세그먼트 선택기로 같은 데이터를 `.flat`과 `.dimensional` 모드로 전환하며 차트가 차지하는 영역은 그대로 유지됩니다. mint와 cyan 의미 색상을 지정하고 기본 숫자 축 formatter를 사용합니다. 접근성 요약도 제공합니다.

선택 콜백, 사용자 정의 formatter, 밀집 데이터의 가로 스크롤, 시점 초기화, 빈 데이터 상태는 다루지 않습니다.

## Interaction Lab

Interaction Lab은 `.dimensional` 모드만 표시하며 다섯 그룹과 세 시리즈를 사용합니다. 부제에는 현재 선택한 데이터 ID가 나타납니다. 막대를 탭하면 통합 앱이 선택 상태를 갱신하고, 막대가 아닌 곳을 탭하면 선택 해제 콜백이 상태를 지웁니다. 드래그하면 입체 차트의 시점이 바뀝니다. 초기화 버튼은 `resetToken`을 증가시켜 처음 시점으로 되돌립니다. 선택한 막대의 강조와 나머지 막대의 흐린 표시도 확인할 수 있습니다.

모드 전환, 평면 차트, 가로 스크롤, 사용자 정의 formatter, 빈 데이터 상태는 다루지 않습니다.

## 빌드

저장소 밖에 재사용 가능한 빌드 디렉터리를 두고 각 앱을 따로 빌드합니다.

```bash
swift build \
  --package-path Examples/GeometryGallery \
  --scratch-path <빌드-디렉터리>/KLCharts-GeometryGallery

swift build \
  --package-path Examples/InteractionLab \
  --scratch-path <빌드-디렉터리>/KLCharts-InteractionLab
```
