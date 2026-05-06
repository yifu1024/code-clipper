import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var configurationStore: ConfigurationStore
    @EnvironmentObject private var monitor: VerificationMonitor
    @State private var selection: Section = .status

    enum Section: String, CaseIterable, Identifiable {
        case status = "Status"
        case rules = "Rules"
        case clipboard = "Clipboard"
        case access = "Access"

        var id: Self { self }

        var title: String {
            switch self {
            case .status: "状态"
            case .rules: "匹配规则"
            case .clipboard: "剪贴板"
            case .access: "权限"
            }
        }

        var systemImage: String {
            switch self {
            case .status: "waveform.path.ecg"
            case .rules: "text.magnifyingglass"
            case .clipboard: "doc.on.clipboard"
            case .access: "lock.shield"
            }
        }
    }

    var body: some View {
        NavigationSplitView {
            List(Section.allCases, selection: $selection) { section in
                Label(section.title, systemImage: section.systemImage)
                    .tag(section)
            }
            .listStyle(.sidebar)
            .navigationSplitViewColumnWidth(min: 170, ideal: 190)
        } detail: {
            switch selection {
            case .status:
                StatusView()
            case .rules:
                RulesView()
            case .clipboard:
                ClipboardSettingsView()
            case .access:
                AccessView()
            }
        }
        .toolbar {
            ToolbarItemGroup {
                Button {
                    monitor.scanNow()
                } label: {
                    Label("Check Now", systemImage: "arrow.clockwise")
                }
                .help("立即检查")

                Button {
                    monitor.toggle()
                } label: {
                    Label(monitor.isRunning ? "Pause" : "Start", systemImage: monitor.isRunning ? "pause.fill" : "play.fill")
                }
                .help(monitor.isRunning ? "暂停监听" : "开始监听")
            }
        }
    }
}
