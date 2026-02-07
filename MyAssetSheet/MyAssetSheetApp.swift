import SwiftUI

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
                Button("MyAssetSheet について") {
                    NSApplication.shared.orderFrontStandardAboutPanel(options: [
                        .credits: NSAttributedString(
                            string: "自宅の耐久消費財を管理するアプリ\n購入履歴・耐用年数・費用を一覧とダッシュボードで確認できます。",
                            attributes: [
                                .font: NSFont.systemFont(ofSize: 11),
                                .foregroundColor: NSColor.secondaryLabelColor
                            ]
                        )
                    ])
                }
            }
        }
    }
}
