import AppKit
import SwiftUI
import UserNotifications

@main
struct CodeClipperApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @StateObject private var configurationStore = ConfigurationStore()
    @StateObject private var monitor = VerificationMonitor()
    @StateObject private var loginItemManager = LoginItemManager()

    var body: some Scene {
        Window("CodeClipper", id: "main") {
            ContentView()
                .environmentObject(configurationStore)
                .environmentObject(monitor)
                .environmentObject(loginItemManager)
                .task {
                    monitor.configure(with: configurationStore.configuration)
                }
                .onChange(of: configurationStore.configuration) { _, configuration in
                    monitor.configure(with: configuration)
                }
                .frame(minWidth: 760, minHeight: 520)
        }
        .commands {
            CommandMenu("CodeClipper") {
                Button(monitor.isRunning ? "Pause Monitoring" : "Start Monitoring") {
                    monitor.toggle()
                }
                .keyboardShortcut("m", modifiers: [.command, .shift])

                Button("Check Now") {
                    monitor.scanNow()
                }
                .keyboardShortcut("r", modifiers: [.command, .shift])

                Button("Rescan Recent Unmatched") {
                    monitor.rescanRecentUnmatched()
                }
                .keyboardShortcut("r", modifiers: [.command, .option])
            }
        }

        MenuBarExtra {
            MenuBarView()
                .environmentObject(configurationStore)
                .environmentObject(monitor)
                .environmentObject(loginItemManager)
        } label: {
            Image(systemName: "message.badge.waveform")
        }
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        UNUserNotificationCenter.current().delegate = self
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        [.banner, .sound]
    }
}
