import SwiftUI

struct AssetListView: View {
    @EnvironmentObject var store: AssetStore
    @State private var showRetired = false
    @State private var sortOrder = [KeyPathComparator(\Asset.purchaseDate, order: .reverse)]
    @State private var selectedAssetID: UUID?
    @State private var editingAsset: Asset?

    var filteredAssets: [Asset] {
        let list = showRetired ? store.assets : store.activeAssets
        return list.sorted(using: sortOrder)
    }

    var body: some View {
        VStack(spacing: 0) {
            Table(filteredAssets, selection: $selectedAssetID, sortOrder: $sortOrder) {
                TableColumn("分類", value: \.category.rawValue) { asset in
                    Text(asset.category.rawValue)
                }
                .width(min: 80, ideal: 100)

                TableColumn("製品名", value: \.name)
                    .width(min: 120, ideal: 200)

                TableColumn("購入日", value: \.purchaseDate) { asset in
                    Text(asset.purchaseDate, style: .date)
                }
                .width(min: 80, ideal: 100)

                TableColumn("金額") { asset in
                    Text("¥\(asset.purchasePrice)")
                        .monospacedDigit()
                }
                .width(min: 80, ideal: 100)

                TableColumn("経過年") { asset in
                    Text(String(format: "%.1f", asset.elapsedYears))
                        .foregroundStyle(asset.isOverUsefulLife ? .red : .primary)
                        .fontWeight(asset.isOverUsefulLife ? .semibold : .regular)
                }
                .width(min: 60, ideal: 70)

                TableColumn("耐用年") { asset in
                    Text("\(asset.usefulLife)")
                }
                .width(min: 60, ideal: 70)
            }
            .contextMenu(forSelectionType: UUID.self) { ids in
                if let id = ids.first {
                    Button("編集") {
                        editingAsset = store.assets.first { $0.id == id }
                    }
                    Button("除却") {
                        store.retire(id)
                    }
                    Divider()
                    Button("削除", role: .destructive) {
                        store.delete(id)
                    }
                }
            }
        }
        .toolbar {
            ToolbarItem {
                Toggle("除却済みを表示", isOn: $showRetired)
                    .toggleStyle(.switch)
            }
        }
        .sheet(item: $editingAsset) { asset in
            AssetEditView(mode: .edit(asset))
        }
        .navigationTitle("一覧")
    }
}
