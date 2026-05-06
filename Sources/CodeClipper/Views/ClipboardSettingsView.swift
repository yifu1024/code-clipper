import SwiftUI

struct ClipboardSettingsView: View {
    @EnvironmentObject private var configurationStore: ConfigurationStore
    @EnvironmentObject private var loginItemManager: LoginItemManager
    @FocusState private var focusedField: Field?

    private enum Field {
        case restoreDelay
    }

    var body: some View {
        Form {
            Section("监听") {
                Toggle("启动后自动监听", isOn: $configurationStore.configuration.launchMonitoringAutomatically)

                Toggle("开机自动启动", isOn: Binding(
                    get: { loginItemManager.isEnabled },
                    set: { loginItemManager.setEnabled($0) }
                ))

                Stepper(value: $configurationStore.configuration.scanIntervalSeconds, in: 1...30, step: 1) {
                    LabeledContent("扫描间隔", value: "\(Int(configurationStore.configuration.scanIntervalSeconds)) 秒")
                }

                Stepper(value: $configurationStore.configuration.messageLookbackMinutes, in: 1...120, step: 1) {
                    LabeledContent("消息回看", value: "\(Int(configurationStore.configuration.messageLookbackMinutes)) 分钟")
                }
            }

            Section("剪贴板") {
                LabeledContent("恢复剪贴板内容") {
                    HStack(spacing: 8) {
                        TextField("秒数", value: restoreDelayBinding, format: .number)
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 82)
                            .focused($focusedField, equals: .restoreDelay)

                        Text("秒后")
                            .foregroundStyle(.secondary)

                        Stepper("", value: restoreDelayBinding, in: 1...3600, step: 5)
                            .labelsHidden()
                    }
                }

                Toggle("复制后发送通知", isOn: $configurationStore.configuration.showCopyNotification)

                Text("复制验证码后，应用会在设定秒数后恢复之前的剪贴板内容。恢复时只会在剪贴板仍然是验证码时执行；如果你已经复制了别的内容，应用会跳过恢复。")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            if let error = loginItemManager.lastError {
                Section("开机启动") {
                    Text(error)
                        .foregroundStyle(.red)
                        .textSelection(.enabled)
                }
            }
        }
        .formStyle(.grouped)
        .padding(20)
        .navigationTitle("剪贴板")
    }

    private var restoreDelayBinding: Binding<Double> {
        Binding(
            get: { configurationStore.configuration.restoreDelaySeconds },
            set: { value in
                configurationStore.configuration.restoreDelaySeconds = min(max(value, 1), 3600)
            }
        )
    }
}
