import SwiftUI

struct StatusView: View {
    @EnvironmentObject private var configurationStore: ConfigurationStore
    @EnvironmentObject private var monitor: VerificationMonitor

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                HeaderBlock(
                    title: monitor.isRunning ? "正在监听验证码" : "监听已暂停",
                    subtitle: "收到匹配规则的新验证码后会自动复制，并在设定时间后恢复原剪贴板。"
                )

                Grid(alignment: .leading, horizontalSpacing: 18, verticalSpacing: 12) {
                    GridRow {
                        MetricView(title: "规则", value: "\(enabledRuleCount)/\(configurationStore.configuration.rules.count)")
                        MetricView(title: "扫描间隔", value: "\(Int(configurationStore.configuration.scanIntervalSeconds))s")
                        MetricView(title: "恢复时间", value: "\(Int(configurationStore.configuration.restoreDelaySeconds))s")
                    }
                }

                if let summary = monitor.lastScanSummary {
                    DetailSection(title: "最近扫描") {
                        Text(summary)
                            .foregroundStyle(.secondary)

                        Button {
                            monitor.rescanRecentUnmatched()
                        } label: {
                            Label("重扫最近未命中短信", systemImage: "arrow.triangle.2.circlepath")
                        }
                    }
                }

                if let match = monitor.lastMatch {
                    DetailSection(title: "最近复制") {
                        LabeledContent("验证码", value: match.code)
                        LabeledContent("规则", value: match.ruleName)
                        LabeledContent("收到时间", value: match.receivedAt.formatted(date: .omitted, time: .standard))
                        LabeledContent("复制时间", value: match.copiedAt.formatted(date: .omitted, time: .standard))
                    }
                } else {
                    DetailSection(title: "最近复制") {
                        Text("还没有命中的验证码。")
                            .foregroundStyle(.secondary)
                    }
                }

                if let error = monitor.lastError {
                    DetailSection(title: "需要处理") {
                        Text(error)
                            .foregroundStyle(.red)
                            .textSelection(.enabled)
                    }
                }
            }
            .padding(24)
            .frame(maxWidth: 720, alignment: .leading)
        }
        .navigationTitle("状态")
    }

    private var enabledRuleCount: Int {
        configurationStore.configuration.rules.filter(\.isEnabled).count
    }
}

struct HeaderBlock: View {
    let title: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.title2)
                .fontWeight(.semibold)
            Text(subtitle)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

struct MetricView: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.title3)
                .fontWeight(.medium)
        }
        .frame(width: 150, alignment: .leading)
        .padding(12)
        .background(.quaternary, in: RoundedRectangle(cornerRadius: 8))
    }
}

struct DetailSection<Content: View>: View {
    let title: String
    @ViewBuilder var content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
            content
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 8))
    }
}
