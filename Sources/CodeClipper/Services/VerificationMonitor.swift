import Foundation
import OSLog

@MainActor
final class VerificationMonitor: ObservableObject {
    @Published private(set) var isRunning = false
    @Published private(set) var lastMatch: MatchedCode?
    @Published private(set) var lastError: String?
    @Published private(set) var lastScanAt: Date?

    private let logger = Logger(subsystem: "com.codex.CodeClipper", category: "Monitor")
    private let scanner = MessagesDatabaseScanner()
    private let matcher = CodeMatcher()
    private let clipboard = ClipboardRestorer()
    private let notificationService = NotificationService()
    private var configuration = AppConfiguration.default
    private var timer: Timer?
    private var seenMessageIDs = Set<Int64>()

    func configure(with configuration: AppConfiguration) {
        self.configuration = configuration

        if configuration.launchMonitoringAutomatically, !isRunning {
            start()
        } else if isRunning {
            scheduleTimer()
        }
    }

    func toggle() {
        isRunning ? stop() : start()
    }

    func start() {
        guard !isRunning else { return }
        isRunning = true
        logger.info("Monitoring started")
        scheduleTimer()
        scanNow()
    }

    func stop() {
        guard isRunning else { return }
        timer?.invalidate()
        timer = nil
        isRunning = false
        logger.info("Monitoring stopped")
    }

    func scanNow() {
        lastScanAt = Date()
        let config = configuration

        Task {
            do {
                let messages = try await scanner.recentIncomingMessages(
                    lookbackMinutes: config.messageLookbackMinutes
                )

                await MainActor.run {
                    handle(messages: messages, configuration: config)
                    lastError = nil
                }
            } catch {
                await MainActor.run {
                    lastError = error.localizedDescription
                    logger.error("Message scan failed: \(error.localizedDescription, privacy: .public)")
                }
            }
        }
    }

    private func scheduleTimer() {
        timer?.invalidate()
        guard isRunning else { return }

        timer = Timer.scheduledTimer(withTimeInterval: max(1, configuration.scanIntervalSeconds), repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.scanNow()
            }
        }
    }

    private func handle(messages: [MessageRecord], configuration: AppConfiguration) {
        let freshMessages = messages
            .filter { !seenMessageIDs.contains($0.id) }
            .sorted { $0.receivedAt < $1.receivedAt }

        for message in freshMessages {
            seenMessageIDs.insert(message.id)

            guard let match = matcher.firstMatch(in: message.body, rules: configuration.rules) else {
                continue
            }

            clipboard.copy(
                match.code,
                restoreAfter: configuration.restoreDelaySeconds
            ) { [weak self] outcome in
                guard outcome == .restored, configuration.showCopyNotification else { return }
                Task {
                    await self?.notificationService.notifyClipboardRestored()
                }
            }

            lastMatch = MatchedCode(
                code: match.code,
                ruleName: match.ruleName,
                messageID: message.id,
                receivedAt: message.receivedAt,
                copiedAt: Date()
            )
            logger.info("Verification code copied by rule: \(match.ruleName, privacy: .public)")

            if configuration.showCopyNotification {
                Task {
                    await notificationService.notifyCodeCopied(ruleName: match.ruleName)
                }
            }
        }
    }
}
