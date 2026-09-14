# AGENTS.md

macOS 菜单栏番茄钟应用（SwiftPM，Swift 6.4，macOS 13+）。单 executable target `tomato_timer`，SwiftUI + AppKit 实现，仅菜单栏常驻（`LSUIElement=true`，无 Dock 图标）。

## 常用命令

- 构建（仅产出二进制 `.build/debug/tomato_timer`）：`swift build`
- 打包成可运行 `.app`（生成 `dist/TomatoTimer.app`，含 Info.plist）：`bash scripts/build-app.sh`
- 直接运行（菜单栏形态，需在 macOS GUI 会话）：`swift run`
- 运行已打包应用：`open dist/TomatoTimer.app`

注意：`scripts/build-app.sh` 会先执行 `swift build`，再手工拼装 `.app` bundle 与 `Info.plist`（含 `CFBundleIdentifier=com.local.tomato-timer`、`LSMinimumSystemVersion=13.0`、`LSUIElement=true`）。修改包名/标识/最低系统版本时，必须同步改此脚本，而非只改 `Package.swift`。

## 测试 / Lint

仓库无测试 target、无 lint / format / typecheck 配置。不要假设 `swift test` 有意义。验证靠手动运行 `.app`。

## 架构要点

- 入口：`Sources/tomato_timer/TomatoTimerApp.swift`（`@main`，`MenuBarExtra` 场景，`@NSApplicationDelegateAdaptor` 设 `.accessory` 激活策略）。
- `TimerController`（`@MainActor`）：计时核心。基于 `endDate: Date` 推算剩余秒数，而非累加 tick，避免漂移；切换工作/休息时播放 `NSSound("Glass")` 并发通知。
- `SettingsStore`（`@MainActor`）：通过 `UserDefaults` 持久化，键名集中在 `Constants.swift` 的 `AppConstants.Keys`（`workMinutes`/`breakMinutes`/`autoStartNext`）。
- `NotificationManager`（`@MainActor` 单例）：`UNUserNotificationCenter`，启动时请求授权。UI 与通知文案均为中文。
- 视图层：`TomatoTimerView`（菜单栏窗口根）→ `TimerView` + `MenuPreferences`。进度环用 `TimelineView(.animation)` 实时绘制 `controller.timeProgress(at:)`。

## Swift 6 并发

`TimerController` / `SettingsStore` / `NotificationManager` 均为 `@MainActor`。新增需访问这些类型的状态的代码时，保持主线程隔离；跨 actor 调用走 `Task { @MainActor in }` 模式（见 `NotificationManager.requestAuthorization`）。

## 平台约束

- 最低 macOS 13（`MenuBarExtra` API 要求）；`Package.swift` 与 `Info.plist` 的 `LSMinimumSystemVersion` 必须一致。
- 目标为 macOS 菜单栏应用，不要引入 iOS-only API。
