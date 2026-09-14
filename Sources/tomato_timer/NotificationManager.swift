import Combine
import Foundation
import UserNotifications

@MainActor
final class NotificationManager: ObservableObject {
    static let shared = NotificationManager()

    @Published var authorizationStatus: UNAuthorizationStatus = .notDetermined

    private init() {}

    func requestAuthorization() {
        UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .sound]) { [weak self] _, _ in
                Task { @MainActor in
                    await self?.refreshAuthorizationStatus()
                }
            }
    }

    func refreshAuthorizationStatus() async {
        authorizationStatus = await UNUserNotificationCenter.current()
            .notificationSettings()
            .authorizationStatus
    }

    func sendTestNotification() {
        send(
            title: "测试通知 🍅",
            body: "如果你看到这条通知，说明系统通知已正常工作。"
        )
    }

    func sendWorkFinished() {
        send(
            title: "番茄工作结束 🍅",
            body: "干得不错！休息一下，让眼睛放松看看吧。"
        )
    }

    func sendBreakFinished() {
        send(
            title: "休息结束 ☕️",
            body: "准备好开始下一个番茄钟了吗？"
        )
    }

    private func send(title: String, body: String) {
        guard authorizationStatus == .authorized else { return }
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        )
        UNUserNotificationCenter.current().add(request) { error in
            if let error {
                NSLog("[TomatoTimer] 通知投递失败: \(error.localizedDescription)")
            }
        }
    }
}