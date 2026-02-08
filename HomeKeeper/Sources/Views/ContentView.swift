import SwiftUI

struct ContentView: View {
    @EnvironmentObject var store: AssetStore
    @State private var selectedTab: Tab = .dashboard
    @State private var showingAddSheet = false

    enum Tab: String, CaseIterable {
        case dashboard = "ダッシュボード"
        case list = "一覧"
    }

    var body: some View {
        NavigationSplitView {
            List(Tab.allCases, id: \.self, selection: $selectedTab) { tab in
                Label(tab.rawValue, systemImage: tab == .dashboard ? "chart.bar" : "list.bullet")
            }
            .navigationSplitViewColumnWidth(min: 160, ideal: 180)
        } detail: {
            switch selectedTab {
            case .dashboard:
                DashboardView()
            case .list:
                AssetListView()
            }
        }
        .sheet(isPresented: $showingAddSheet) {
            AssetEditView(mode: .add)
        }
        .onReceive(NotificationCenter.default.publisher(for: .addNewAsset)) { _ in
            showingAddSheet = true
        }
    }
}
