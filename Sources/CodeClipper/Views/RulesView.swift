import SwiftUI

struct RulesView: View {
    @EnvironmentObject private var configurationStore: ConfigurationStore
    @State private var selectedRuleID: VerificationRule.ID?

    var body: some View {
        VStack(spacing: 0) {
            List(selection: $selectedRuleID) {
                ForEach($configurationStore.configuration.rules) { $rule in
                    RuleRow(rule: $rule)
                        .tag(rule.id)
                }
                .onDelete(perform: deleteRules)
            }
            .listStyle(.inset)

            Divider()

            HStack {
                Button {
                    addRule()
                } label: {
                    Label("Add", systemImage: "plus")
                }
                .help("添加规则")

                Menu {
                    ForEach(RulePreset.allCases) { preset in
                        Button(preset.title) {
                            addPreset(preset)
                        }
                    }
                } label: {
                    Label("Preset", systemImage: "sparkles")
                }
                .help("添加预设规则")

                Button {
                    deleteSelectedRule()
                } label: {
                    Label("Delete", systemImage: "trash")
                }
                .disabled(selectedRuleID == nil)
                .help("删除选中规则")

                Spacer()

                Button("恢复默认规则") {
                    configurationStore.reset()
                }
            }
            .padding(12)
        }
        .navigationTitle("匹配规则")
    }

    private func addRule() {
        let rule = VerificationRule(
            name: "New rule",
            pattern: #"(?<!\d)(\d{6})(?!\d)"#,
            captureGroup: 1,
            isEnabled: true
        )
        configurationStore.configuration.rules.append(rule)
        selectedRuleID = rule.id
    }

    private func addPreset(_ preset: RulePreset) {
        let rule = preset.rule
        configurationStore.configuration.rules.append(rule)
        selectedRuleID = rule.id
    }

    private func deleteSelectedRule() {
        guard let selectedRuleID else { return }
        configurationStore.configuration.rules.removeAll { $0.id == selectedRuleID }
        self.selectedRuleID = nil
    }

    private func deleteRules(at offsets: IndexSet) {
        configurationStore.configuration.rules.remove(atOffsets: offsets)
    }
}

struct RuleRow: View {
    @Binding var rule: VerificationRule
    @State private var testText = "您的验证码是 123456，5 分钟内有效。"

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Toggle("", isOn: $rule.isEnabled)
                    .labelsHidden()

                TextField("Name", text: $rule.name)
                    .font(.headline)
                    .textFieldStyle(.plain)
            }

            TextField("Regular expression", text: $rule.pattern)
                .font(.system(.body, design: .monospaced))

            Stepper(value: $rule.captureGroup, in: 0...8) {
                Text("捕获组 \(rule.captureGroup)")
                    .foregroundStyle(.secondary)
            }

            HStack {
                TextField("Test message", text: $testText)
                Text(testResult)
                    .font(.system(.body, design: .monospaced))
                    .foregroundStyle(testResultColor)
                    .frame(width: 120, alignment: .trailing)
            }
        }
        .padding(.vertical, 8)
    }

    private var testResult: String {
        CodeMatcher().firstMatch(in: testText, rules: [rule])?.code ?? "No match"
    }

    private var testResultColor: Color {
        testResult == "No match" ? .secondary : .green
    }
}
