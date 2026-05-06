import AppKit
import SwiftUI

struct AccessView: View {
    @State private var permissionState: MessagesPermissionState = .checking
    private let checker = MessagesPermissionChecker()

    var body: some View {
        Form {
            Section("当前状态") {
                LabeledContent("信息数据库") {
                    statusLabel
                }

                Button {
                    refresh()
                } label: {
                    Label("刷新权限状态", systemImage: "arrow.clockwise")
                }
            }

            Section("授予信息数据库读取权限") {
                Text("macOS 会保护 ~/Library/Messages/chat.db。首次运行时，如果看到无法打开数据库，请在系统设置里给 CodeClipper 完全磁盘访问权限。")
                    .fixedSize(horizontal: false, vertical: true)

                LabeledContent("设置路径") {
                    Text("隐私与安全性 > 完全磁盘访问权限")
                        .textSelection(.enabled)
                }

                LabeledContent("添加应用") {
                    Text("~/Applications/CodeClipper.app")
                        .textSelection(.enabled)
                }
            }

            Section("打开权限设置") {
                Button {
                    NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_AllFiles")!)
                } label: {
                    Label("打开完全磁盘访问权限", systemImage: "gear")
                }
            }

            Section("数据处理") {
                Text("应用只在本机读取最近收到的信息并匹配验证码，不上传数据。日志只记录规则名和状态，不记录短信正文或验证码内容。")
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .formStyle(.grouped)
        .padding(20)
        .navigationTitle("权限")
        .task {
            refresh()
        }
    }

    @ViewBuilder
    private var statusLabel: some View {
        switch permissionState {
        case .checking:
            ProgressView()
                .controlSize(.small)
        case .granted:
            Label("已授权", systemImage: "checkmark.circle.fill")
                .foregroundStyle(.green)
        case .denied(let message):
            VStack(alignment: .trailing, spacing: 4) {
                Label("未授权", systemImage: "xmark.circle.fill")
                    .foregroundStyle(.red)
                Text(message)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .textSelection(.enabled)
            }
        }
    }

    private func refresh() {
        permissionState = .checking
        Task {
            let state = await checker.check()
            await MainActor.run {
                permissionState = state
            }
        }
    }
}
