import AppKit
import SwiftUI

final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        NotificationManager.shared.requestAuthorization()
    }
}

@main
struct TomatoTimerApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    @StateObject private var controller: TimerController

    init() {
        let settings = SettingsStore()
        _controller = StateObject(wrappedValue: TimerController(settings: settings))
    }

    var body: some Scene {
        MenuBarExtra {
            TomatoTimerView()
                .environmentObject(controller)
                .environmentObject(controller.settings)
                .environmentObject(NotificationManager.shared)
        } label: {
            MenuBarLabel(controller: controller)
        }
        .menuBarExtraStyle(.window)
    }
}

struct MenuBarLabel: View {
    @ObservedObject var controller: TimerController

    var body: some View {
        Text(controller.menuBarText)
            .font(.system(.body, design: .monospaced))
            .monospacedDigit()
            .accessibilityLabel("\(controller.mode.displayName)倒计时 \(controller.timeText)")
    }
}