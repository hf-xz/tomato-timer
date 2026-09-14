import SwiftUI

struct MenuPreferences: View {
    @EnvironmentObject private var controller: TimerController
    @EnvironmentObject private var settings: SettingsStore

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            durationRow(
                title: "工作时长",
                value: workBinding,
                range: 1...180
            )
            durationRow(
                title: "休息时长",
                value: breakBinding,
                range: 1...60
            )

            Toggle("自动开始下一阶段", isOn: $settings.autoStartNext)
            HStack {
                Toggle("提示音", isOn: $settings.soundEnabled)
                Toggle("通知", isOn: $settings.notificationsEnabled)
            }
        }
        .padding(.top, 6)
    }

    private var workBinding: Binding<Int> {
        Binding(
            get: { settings.workMinutes },
            set: { settings.workMinutes = min(max($0, 1), 180) }
        )
    }

    private var breakBinding: Binding<Int> {
        Binding(
            get: { settings.breakMinutes },
            set: { settings.breakMinutes = min(max($0, 1), 60) }
        )
    }

    private func durationRow(title: String, value: Binding<Int>, range: ClosedRange<Int>) -> some View {
        HStack {
            Text(title)
            Spacer()
            TextField("", value: value, format: .number)
                .frame(width: 48)
                .textFieldStyle(.roundedBorder)
                .multilineTextAlignment(.trailing)
            Stepper("", value: value, in: range)
                .labelsHidden()
            Text("分钟")
                .foregroundStyle(.secondary)
        }
    }
}