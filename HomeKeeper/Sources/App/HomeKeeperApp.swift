import SwiftUI

@main
struct HomeKeeperApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(TaskStore())
        }
    }
}
