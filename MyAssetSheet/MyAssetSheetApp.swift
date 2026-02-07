import SwiftUI
import UniformTypeIdentifiers

@main
struct MyAssetSheetApp: App {
    @StateObject private var store = AssetStore()

    var body: some Scene {
        WindowGroup {
            TabView {
                ContentView(store: store)
                    .tabItem { Label("一覧", systemImage: "list.bullet") }

                DashboardView(store: store)
                    .tabItem { Label("ダッシュボード", systemImage: "chart.bar") }
            }
        }
        .defaultSize(width: 1100, height: 600)
        .commands {
            CommandGroup(replacing: .appInfo) {
                Button("Home Keeper について") {
                    var options: [NSApplication.AboutPanelOptionKey: Any] = [
                        .credits: NSAttributedString(
                            string: "自宅の耐久消費財を管理するアプリ\n購入履歴・耐用年数・費用を一覧とダッシュボードで確認できます。",
                            attributes: [
                                .font: NSFont.systemFont(ofSize: 11),
                                .foregroundColor: NSColor.secondaryLabelColor
                            ]
                        )
                    ]
                    if let icon = NSImage(named: "AppIcon") {
                        let size = icon.size
                        let radius = size.width * 0.22
                        let masked = NSImage(size: size)
                        masked.lockFocus()
                        NSBezierPath(roundedRect: NSRect(origin: .zero, size: size),
                                     xRadius: radius, yRadius: radius).addClip()
                        icon.draw(in: NSRect(origin: .zero, size: size))
                        masked.unlockFocus()
                        options[.applicationIcon] = masked
                    }
                    NSApplication.shared.orderFrontStandardAboutPanel(options: options)
                }
            }
            CommandGroup(after: .newItem) {
                Divider()
                Button("CSV 取込...") {
                    let panel = NSOpenPanel()
                    panel.allowedContentTypes = [.commaSeparatedText, .plainText]
                    panel.allowsMultipleSelection = false
                    guard panel.runModal() == .OK, let url = panel.url else { return }
                    let accessing = url.startAccessingSecurityScopedResource()
                    defer { if accessing { url.stopAccessingSecurityScopedResource() } }
                    do {
                        let count = try store.importCSV(from: url)
                        let alert = NSAlert()
                        alert.messageText = "CSV取込"
                        alert.informativeText = "\(count)件のデータを取り込みました。"
                        alert.runModal()
                    } catch {
                        let alert = NSAlert()
                        alert.messageText = "CSV取込エラー"
                        alert.informativeText = error.localizedDescription
                        alert.alertStyle = .warning
                        alert.runModal()
                    }
                }
                .keyboardShortcut("i", modifiers: [.command, .shift])

                Button("CSV 出力...") {
                    let panel = NSSavePanel()
                    panel.allowedContentTypes = [.commaSeparatedText]
                    panel.nameFieldStringValue = "HomeKeeper.csv"
                    guard panel.runModal() == .OK, let url = panel.url else { return }
                    let accessing = url.startAccessingSecurityScopedResource()
                    defer { if accessing { url.stopAccessingSecurityScopedResource() } }
                    do {
                        let csv = store.exportCSV()
                        try csv.write(to: url, atomically: true, encoding: .utf8)
                    } catch {
                        let alert = NSAlert()
                        alert.messageText = "CSV出力エラー"
                        alert.informativeText = error.localizedDescription
                        alert.alertStyle = .warning
                        alert.runModal()
                    }
                }
                .keyboardShortcut("e", modifiers: [.command, .shift])
                .disabled(store.assets.isEmpty)
            }
        }
    }
}
