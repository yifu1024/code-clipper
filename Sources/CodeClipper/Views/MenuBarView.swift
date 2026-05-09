import AppKit
import SwiftUI

struct MenuBarView: View {
    @EnvironmentObject private var configurationStore: ConfigurationStore
    @EnvironmentObject private var monitor: VerificationMonitor
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(monitor.isRunning ? "正在监听" : "已暂停")
                .font(.headline)

            if let match = monitor.lastMatch {
                Text("最近：\(match.code)")
                    .lineLimit(1)
            } else {
                Text("暂无验证码")
                    .foregroundStyle(.secondary)
            }

            Divider()

            Button(monitor.isRunning ? "暂停监听" : "开始监听") {
                monitor.toggle()
            }

            Button("立即检查") {
                monitor.scanNow()
            }

            Button("重扫未命中短信") {
                monitor.rescanRecentUnmatched()
            }

            Button("打开设置") {
                openWindow(id: "main")
                NSApp.activate(ignoringOtherApps: true)
            }

            Divider()

            Button("退出") {
                NSApp.terminate(nil)
            }
        }
        .padding(12)
        .frame(width: 220, alignment: .leading)
    }
}
