import Foundation
import OSLog
import UserNotifications

actor NotificationService {
    private let logger = Logger(subsystem: "com.codex.CodeClipper", category: "Notifications")

    func notifyCodeCopied(ruleName: String) async {
        await send(title: "验证码已复制", body: "CodeClipper 已根据“\(ruleName)”复制验证码。")
    }

    func notifyClipboardRestored() async {
        await send(title: "剪贴板已恢复", body: "CodeClipper 已恢复之前的剪贴板内容。")
    }

    private func send(title: String, body: String) async {
        let center = UNUserNotificationCenter.current()

        do {
            let granted = try await center.requestAuthorization(options: [.alert, .sound])
            guard granted else {
                logger.info("Notification authorization not granted")
                return
            }

            let content = UNMutableNotificationContent()
            content.title = title
            content.body = body
            content.sound = .default

            let request = UNNotificationRequest(
                identifier: UUID().uuidString,
                content: content,
                trigger: nil
            )
            try await center.add(request)
        } catch {
            logger.error("Notification failed: \(error.localizedDescription, privacy: .public)")
        }
    }
}
