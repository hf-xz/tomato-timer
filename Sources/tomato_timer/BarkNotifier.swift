import Foundation

@MainActor
final class BarkNotifier {
    static let shared = BarkNotifier()

    private init() {}

    func sendTest(url: String) {
        send(
            url: url,
            title: "测试推送 🍅",
            body: "收到说明 Bark 配置成功，推送可用。"
        )
    }

    func sendWorkFinished(url: String) {
        send(
            url: url,
            title: "番茄工作结束 🍅",
            body: "干得不错！休息一下，让眼睛放松看看吧。"
        )
    }

    func sendBreakFinished(url: String) {
        send(
            url: url,
            title: "休息结束 ☕️",
            body: "准备好开始下一个番茄钟了吗？"
        )
    }

    private func send(url pushURL: String, title: String, body: String) {
        let trimmed = pushURL.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, let url = URL(string: trimmed) else {
            NSLog("[TomatoTimer] Bark 推送地址无效，已跳过推送")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.timeoutInterval = 10
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")

        let payload: [String: String] = [
            "title": title,
            "body": body,
            "group": "TomatoTimer",
            "level": "timeSensitive"
        ]
        request.httpBody = try? JSONEncoder().encode(payload)

        URLSession.shared.dataTask(with: request) { _, response, error in
            if let error {
                NSLog("[TomatoTimer] Bark 推送失败: \(error.localizedDescription)")
                return
            }
            if let http = response as? HTTPURLResponse, http.statusCode != 200 {
                NSLog("[TomatoTimer] Bark 推送异常，状态码: \(http.statusCode)")
            }
        }
        .resume()
    }
}
