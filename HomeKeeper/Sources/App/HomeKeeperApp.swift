import SwiftUI

@main
struct HomeKeeperApp: App {
    @StateObject private var store = AssetStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
        }
        .commands {
            CommandGroup(replacing: .newItem) {
                Button("新規資産を追加") {
                    NotificationCenter.default.post(name: .addNewAsset, object: nil)
                }
                .keyboardShortcut("n")
            }
        }
    }
}

extension Notification.Name {
    static let addNewAsset = Notification.Name("addNewAsset")
}
