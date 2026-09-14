import Combine
import Foundation

enum TimerMode: String {
    case work
    case `break`

    var displayName: String {
        switch self {
        case .work: "专注"
        case .break: "休息"
        }
    }

    var emoji: String {
        switch self {
        case .work: "🍅"
        case .break: "☕️"
        }
    }
}

@MainActor
final class SettingsStore: ObservableObject {
    @Published var workMinutes: Int {
        didSet { persist() }
    }
    @Published var breakMinutes: Int {
        didSet { persist() }
    }
    @Published var autoStartNext: Bool {
        didSet { persist() }
    }
    @Published var soundEnabled: Bool {
        didSet { persist() }
    }
    @Published var notificationsEnabled: Bool {
        didSet { persist() }
    }

    init() {
        let defaults = UserDefaults.standard
        let savedWork = defaults.object(forKey: AppConstants.Keys.workMinutes) as? Int
        let savedBreak = defaults.object(forKey: AppConstants.Keys.breakMinutes) as? Int
        let savedAutoStart = defaults.object(forKey: AppConstants.Keys.autoStartNext) as? Bool
        let savedSound = defaults.object(forKey: AppConstants.Keys.soundEnabled) as? Bool
        let savedNotifications = defaults.object(forKey: AppConstants.Keys.notificationsEnabled) as? Bool

        workMinutes = savedWork ?? AppConstants.defaultWorkMinutes
        breakMinutes = savedBreak ?? AppConstants.defaultBreakMinutes
        autoStartNext = savedAutoStart ?? true
        soundEnabled = savedSound ?? true
        notificationsEnabled = savedNotifications ?? true
    }

    private func persist() {
        let defaults = UserDefaults.standard
        defaults.set(workMinutes, forKey: AppConstants.Keys.workMinutes)
        defaults.set(breakMinutes, forKey: AppConstants.Keys.breakMinutes)
        defaults.set(autoStartNext, forKey: AppConstants.Keys.autoStartNext)
        defaults.set(soundEnabled, forKey: AppConstants.Keys.soundEnabled)
        defaults.set(notificationsEnabled, forKey: AppConstants.Keys.notificationsEnabled)
    }
}