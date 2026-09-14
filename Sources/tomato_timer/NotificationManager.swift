import Combine
import Foundation
import UserNotifications

@MainActor
final class NotificationManager: NSObject, ObservableObject {
    static let shared = NotificationManager()

    @Published var authorizationStatus: UNAuthorizationStatus = .notDetermined

    weak var controller: TimerController?

    static let startActionID = "START_NEXT"
    static let laterActionID = "LATER"
    static let timerFinishedCategoryID = "TIMER_FINISHED"

    private override init() {
        super.init()
    }

    func registerCategories() {
        let startAction = UNNotificationAction(
            identifier: Self.startActionID,
            title: "开始",
            options: []
        )
        let laterAction = UNNotificationAction(
            identifier: Self.laterActionID,
            title: "稍后",
            options: []
        )
        let category = UNNotificationCategory(
            identifier: Self.timerFinishedCategoryID,
            actions: [startAction, laterAction],
            intentIdentifiers: [],
            options: []
        )
        let center = UNUserNotificationCenter.current()
        center.setNotificationCategories([category])
        center.delegate = self
    }

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

    func sendWorkFinished(includeActions: Bool) {
        send(
            title: "番茄工作结束 🍅",
            body: "干得不错！休息一下，让眼睛放松看看吧。",
            includeActions: includeActions
        )
    }

    func sendBreakFinished(includeActions: Bool) {
        send(
            title: "休息结束 ☕️",
            body: "准备好开始下一个番茄钟了吗？",
            includeActions: includeActions
        )
    }

    private func send(title: String, body: String, includeActions: Bool = false) {
        guard authorizationStatus == .authorized else { return }
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        if includeActions {
            content.categoryIdentifier = Self.timerFinishedCategoryID
        }

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

extension NotificationManager: UNUserNotificationCenterDelegate {
    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let actionID = response.actionIdentifier
        Task { @MainActor in
            if actionID == Self.startActionID {
                controller?.start()
            }
        }
        completionHandler()
    }
}