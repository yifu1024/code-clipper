import Foundation
import OSLog
import ServiceManagement

@MainActor
final class LoginItemManager: ObservableObject {
    @Published private(set) var isEnabled = false
    @Published private(set) var lastError: String?

    private let logger = Logger(subsystem: "com.codex.CodeClipper", category: "LoginItem")

    init() {
        refresh()
    }

    func refresh() {
        isEnabled = SMAppService.mainApp.status == .enabled
    }

    func setEnabled(_ enabled: Bool) {
        do {
            if enabled {
                try SMAppService.mainApp.register()
            } else {
                try SMAppService.mainApp.unregister()
            }
            lastError = nil
            refresh()
            logger.info("Launch at login updated: \(enabled, privacy: .public)")
        } catch {
            refresh()
            lastError = error.localizedDescription
            logger.error("Launch at login update failed: \(error.localizedDescription, privacy: .public)")
        }
    }
}
