import Foundation

struct AppConfiguration: Codable, Equatable {
    var rules: [VerificationRule]
    var restoreDelaySeconds: Double
    var scanIntervalSeconds: Double
    var messageLookbackMinutes: Double
    var launchMonitoringAutomatically: Bool
    var showCopyNotification: Bool

    static let `default` = AppConfiguration(
        rules: [
            VerificationRule(
                name: "6 digit code",
                pattern: #"(?<!\d)(\d{6})(?!\d)"#,
                captureGroup: 1,
                isEnabled: true
            ),
            VerificationRule(
                name: "4-8 digit code",
                pattern: #"(?<!\d)(\d{4,8})(?!\d)"#,
                captureGroup: 1,
                isEnabled: false
            )
        ],
        restoreDelaySeconds: 90,
        scanIntervalSeconds: 3,
        messageLookbackMinutes: 10,
        launchMonitoringAutomatically: true,
        showCopyNotification: true
    )
}

extension AppConfiguration {
    enum CodingKeys: String, CodingKey {
        case rules
        case restoreDelaySeconds
        case scanIntervalSeconds
        case messageLookbackMinutes
        case launchMonitoringAutomatically
        case showCopyNotification
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        rules = try container.decode([VerificationRule].self, forKey: .rules)
        restoreDelaySeconds = try container.decode(Double.self, forKey: .restoreDelaySeconds)
        scanIntervalSeconds = try container.decode(Double.self, forKey: .scanIntervalSeconds)
        messageLookbackMinutes = try container.decode(Double.self, forKey: .messageLookbackMinutes)
        launchMonitoringAutomatically = try container.decodeIfPresent(Bool.self, forKey: .launchMonitoringAutomatically) ?? true
        showCopyNotification = try container.decodeIfPresent(Bool.self, forKey: .showCopyNotification) ?? true
    }
}

enum RulePreset: String, CaseIterable, Identifiable {
    case sixDigits
    case fourToEightDigits
    case codeKeyword
    case colonSeparated

    var id: Self { self }

    var title: String {
        switch self {
        case .sixDigits: "6 位数字"
        case .fourToEightDigits: "4-8 位数字"
        case .codeKeyword: "验证码关键字"
        case .colonSeparated: "冒号后数字"
        }
    }

    var rule: VerificationRule {
        switch self {
        case .sixDigits:
            VerificationRule(name: title, pattern: #"(?<!\d)(\d{6})(?!\d)"#, captureGroup: 1, isEnabled: true)
        case .fourToEightDigits:
            VerificationRule(name: title, pattern: #"(?<!\d)(\d{4,8})(?!\d)"#, captureGroup: 1, isEnabled: true)
        case .codeKeyword:
            VerificationRule(name: title, pattern: #"(?:验证码|校验码|动态码|code|Code)[^\d]{0,12}(\d{4,8})"#, captureGroup: 1, isEnabled: true)
        case .colonSeparated:
            VerificationRule(name: title, pattern: #"[:：]\s*(\d{4,8})(?!\d)"#, captureGroup: 1, isEnabled: true)
        }
    }
}

struct VerificationRule: Codable, Equatable, Identifiable {
    var id: UUID
    var name: String
    var pattern: String
    var captureGroup: Int
    var isEnabled: Bool

    init(
        id: UUID = UUID(),
        name: String,
        pattern: String,
        captureGroup: Int,
        isEnabled: Bool
    ) {
        self.id = id
        self.name = name
        self.pattern = pattern
        self.captureGroup = captureGroup
        self.isEnabled = isEnabled
    }
}

struct MatchedCode: Identifiable, Equatable {
    let id = UUID()
    let code: String
    let ruleName: String
    let messageID: Int64
    let receivedAt: Date
    let copiedAt: Date
}

struct MessageRecord: Equatable {
    let id: Int64
    let receivedAt: Date
    let body: String
}
