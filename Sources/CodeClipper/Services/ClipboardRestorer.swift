import AppKit
import Foundation
import OSLog

@MainActor
final class ClipboardRestorer {
    enum RestoreOutcome {
        case restored
        case skippedBecauseClipboardChanged
    }

    private let logger = Logger(subsystem: "com.codex.CodeClipper", category: "Clipboard")
    private var restoreTask: Task<Void, Never>?

    func copy(_ text: String, restoreAfter delay: Double, onRestore: ((RestoreOutcome) -> Void)? = nil) {
        let pasteboard = NSPasteboard.general
        let previous = pasteboard.string(forType: .string)

        pasteboard.clearContents()
        pasteboard.setString(text, forType: .string)
        logger.info("Verification code copied to clipboard")

        restoreTask?.cancel()
        restoreTask = Task { [previous] in
            let nanoseconds = UInt64(max(1, delay) * 1_000_000_000)
            try? await Task.sleep(nanoseconds: nanoseconds)
            guard !Task.isCancelled else { return }

            await MainActor.run {
                guard NSPasteboard.general.string(forType: .string) == text else {
                    logger.info("Clipboard changed by user; restore skipped")
                    onRestore?(.skippedBecauseClipboardChanged)
                    return
                }

                NSPasteboard.general.clearContents()
                if let previous {
                    NSPasteboard.general.setString(previous, forType: .string)
                }
                logger.info("Clipboard restored")
                onRestore?(.restored)
            }
        }
    }
}
