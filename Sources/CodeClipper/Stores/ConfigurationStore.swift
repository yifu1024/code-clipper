import Foundation
import OSLog

@MainActor
final class ConfigurationStore: ObservableObject {
    @Published var configuration: AppConfiguration {
        didSet {
            guard configuration != oldValue else { return }
            save()
        }
    }

    private let logger = Logger(subsystem: "com.codex.CodeClipper", category: "Configuration")
    private let fileURL: URL

    init() {
        let supportURL = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)
            .first!
            .appendingPathComponent("CodeClipper", isDirectory: true)
        self.fileURL = supportURL.appendingPathComponent("configuration.json")

        do {
            try FileManager.default.createDirectory(at: supportURL, withIntermediateDirectories: true)
            let data = try Data(contentsOf: fileURL)
            self.configuration = try JSONDecoder().decode(AppConfiguration.self, from: data)
        } catch {
            self.configuration = .default
            logger.info("Using default configuration")
        }
    }

    func reset() {
        configuration = .default
    }

    private func save() {
        do {
            let data = try JSONEncoder.pretty.encode(configuration)
            try data.write(to: fileURL, options: .atomic)
            logger.info("Configuration saved")
        } catch {
            logger.error("Configuration save failed: \(error.localizedDescription, privacy: .public)")
        }
    }
}
