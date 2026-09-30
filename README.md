# Arrive

到达即提醒 · P0 版本

## 是什么

把任务绑定到地点，当你到达该地点时，App 发通知提醒你。

## P0 范围

- 地址库（增删改查、半径、提醒频率）
- 围栏判定引擎（进入 / 离开 + 最近优先 + 防抖 + 频率控制）
- 普通通知（不接 AI、不接语音）

**不包含**：用户体系、云同步、分类、AI 提醒、语音播报。

## 技术栈

Flutter + Riverpod + go_router + sqflite + geolocator + flutter_local_notifications

## 本地存储

- locations 表：地址库
- fence_state 表：围栏运行状态，重启后可恢复

## 构建

本地（需 Flutter SDK）：用 flutter pub get / flutter analyze / flutter build apk --debug。

或推送到 main 分支，由 GitHub Actions 自动构建并上传 APK（见 .github/workflows/build.yml）。

## 包名

com.rf.arrive
