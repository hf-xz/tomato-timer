import AppKit
import Combine
import Foundation

@MainActor
final class TimerController: ObservableObject {
    @Published private(set) var mode: TimerMode = .work
    @Published private(set) var remainingSeconds: Int
    @Published private(set) var isRunning = false
    @Published private(set) var completedPomodoros = 0

    private var endDate: Date?

    let settings: SettingsStore

    private var ticker: AnyCancellable?
    private var cancellables = Set<AnyCancellable>()

    init(settings: SettingsStore) {
        self.settings = settings
        self.remainingSeconds = Self.duration(
            for: .work,
            workMinutes: settings.workMinutes,
            breakMinutes: settings.breakMinutes
        )

        settings.$workMinutes
            .combineLatest(settings.$breakMinutes)
            .sink { [weak self] workMinutes, breakMinutes in
                self?.settingsDidChange(workMinutes: workMinutes, breakMinutes: breakMinutes)
            }
            .store(in: &cancellables)
    }

    private static func duration(
        for mode: TimerMode,
        workMinutes: Int,
        breakMinutes: Int
    ) -> Int {
        (mode == .work ? workMinutes : breakMinutes) * 60
    }

    var totalSeconds: Int {
        Self.duration(
            for: mode,
            workMinutes: settings.workMinutes,
            breakMinutes: settings.breakMinutes
        )
    }

    var timeText: String {
        String(format: "%02d:%02d", remainingSeconds / 60, remainingSeconds % 60)
    }

    var menuBarText: String {
        "\(mode.emoji) \(timeText)"
    }

    func timeProgress(at date: Date) -> Double {
        let total = totalSeconds
        guard total > 0 else { return 0 }

        let remaining: Double
        if let endDate {
            remaining = max(0, endDate.timeIntervalSince(date))
        } else {
            remaining = Double(remainingSeconds)
        }
        return max(0, min(1, 1 - remaining / Double(total)))
    }

    func toggle() {
        isRunning ? pause() : start()
    }

    func start() {
        guard !isRunning, remainingSeconds > 0 else { return }
        isRunning = true
        endDate = Date().addingTimeInterval(TimeInterval(remainingSeconds))
        ticker = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in self?.tick() }
    }

    func pause() {
        guard isRunning else { return }
        isRunning = false
        endDate = nil
        ticker?.cancel()
        ticker = nil
    }

    func reset() {
        pause()
        remainingSeconds = totalSeconds
    }

    private func tick() {
        guard isRunning, let endDate else { return }
        guard Date() < endDate else {
            transition()
            return
        }
        remainingSeconds = max(1, Int(ceil(endDate.timeIntervalSinceNow)))
    }

    private func transition() {
        if mode == .work {
            completedPomodoros += 1
            mode = .break
        } else {
            mode = .work
        }
        remainingSeconds = totalSeconds
        if settings.soundEnabled {
            NSSound(named: "Glass")?.play()
        }
        if settings.notificationsEnabled {
            if mode == .break {
                NotificationManager.shared.sendWorkFinished()
            } else {
                NotificationManager.shared.sendBreakFinished()
            }
        }

        if settings.autoStartNext {
            endDate = Date().addingTimeInterval(TimeInterval(remainingSeconds))
        } else {
            endDate = nil
            isRunning = false
            ticker?.cancel()
            ticker = nil
        }
    }

    private func settingsDidChange(workMinutes: Int, breakMinutes: Int) {
        let newTotal = Self.duration(for: mode, workMinutes: workMinutes, breakMinutes: breakMinutes)
        guard newTotal != totalSeconds else { return }
        remainingSeconds = newTotal
        if isRunning {
            endDate = Date().addingTimeInterval(TimeInterval(newTotal))
        }
    }
}
