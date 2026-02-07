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
    }
}
