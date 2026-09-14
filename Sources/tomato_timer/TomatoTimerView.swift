import AppKit
import SwiftUI
import UserNotifications

struct TomatoTimerView: View {
    @EnvironmentObject private var controller: TimerController
    @EnvironmentObject private var settings: SettingsStore
    @EnvironmentObject private var notifications: NotificationManager

    var body: some View {
        VStack(spacing: 12) {
            TimerView()
                .environmentObject(controller)

            Divider()

            MenuPreferences()
                .environmentObject(controller)
                .environmentObject(settings)

            notificationStatusView
        }
        .padding()
        .frame(width: 280)
        .task {
            await notifications.refreshAuthorizationStatus()
        }
    }

    @ViewBuilder
    private var notificationStatusView: some View {
        switch notifications.authorizationStatus {
        case .denied:
            HStack(spacing: 6) {
                Image(systemName: "bell.slash")
                Text("系统通知已关闭")
                    .foregroundStyle(.secondary)
                Spacer()
                Button("去开启") {
                    NSWorkspace.shared.open(
                        URL(string: "x-apple.systempreferences:com.apple.preference.notifications")!
                    )
                }
            }
            .font(.caption)
        case .notDetermined:
            HStack(spacing: 6) {
                Image(systemName: "bell.badge")
                    .foregroundStyle(.secondary)
                Text("通知未就绪")
                    .foregroundStyle(.secondary)
                Spacer()
                Button("请求权限") {
                    notifications.requestAuthorization()
                }
            }
            .font(.caption)
        default:
            HStack(spacing: 6) {
                Image(systemName: "bell")
                    .foregroundStyle(.secondary)
                Text("通知正常")
                    .foregroundStyle(.secondary)
                Spacer()
                Button("测试通知") {
                    NotificationManager.shared.sendTestNotification()
                }
            }
            .font(.caption)
        }
    }
}