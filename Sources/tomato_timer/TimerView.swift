import SwiftUI

struct TimerView: View {
    @EnvironmentObject private var controller: TimerController

    var body: some View {
        VStack(spacing: 14) {
            Text(controller.mode.displayName)
                .font(.title3.weight(.semibold))
                .foregroundStyle(controller.mode == .work ? Color.accentColor : .orange)

            ZStack {
                Circle()
                    .stroke(Color.secondary.opacity(0.15), lineWidth: 8)
                TimelineView(.animation(minimumInterval: 1.0 / 30.0)) { context in
                    Circle()
                        .trim(from: 0, to: controller.timeProgress(at: context.date))
                        .stroke(
                            style: StrokeStyle(lineWidth: 8, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))
                        .foregroundStyle(controller.mode == .work ? Color.accentColor : .orange)
                }
                Text(controller.timeText)
                    .font(.system(size: 42, weight: .light, design: .monospaced))
                    .monospacedDigit()
                    .accessibilityLabel("剩余时间 \(controller.timeText)")
            }
            .frame(width: 160, height: 160)

            HStack(spacing: 10) {
                Button {
                    controller.toggle()
                } label: {
                    Label(
                        controller.isRunning ? "暂停" : "开始",
                        systemImage: controller.isRunning ? "pause.fill" : "play.fill"
                    )
                    .frame(maxWidth: .infinity)
                }
                .controlSize(.large)
                .keyboardShortcut(.space, modifiers: [])

                Button {
                    controller.skip()
                } label: {
                    Label("跳过", systemImage: "forward.fill")
                        .frame(maxWidth: .infinity)
                }
                .controlSize(.large)

                Button {
                    controller.reset()
                } label: {
                    Label("重置", systemImage: "arrow.counterclockwise")
                        .frame(maxWidth: .infinity)
                }
                .controlSize(.large)
            }

            Text("已完成 \(controller.completedPomodoros) 个番茄")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}