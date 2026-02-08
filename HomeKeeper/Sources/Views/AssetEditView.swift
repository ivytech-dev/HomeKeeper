import SwiftUI

struct AssetEditView: View {
    enum Mode: Identifiable {
        case add
        case edit(Asset)

        var id: String {
            switch self {
            case .add: return "add"
            case .edit(let asset): return asset.id.uuidString
            }
        }
    }

    @EnvironmentObject var store: AssetStore
    @Environment(\.dismiss) private var dismiss

    let mode: Mode

    @State private var name = ""
    @State private var category: AssetCategory = .other
    @State private var purchaseDate = Date()
    @State private var purchasePrice = ""
    @State private var purchaseStore = ""
    @State private var usefulLife = ""
    @State private var notes = ""

    var body: some View {
        VStack(spacing: 0) {
            Form {
                TextField("製品名", text: $name)
                Picker("カテゴリ", selection: $category) {
                    ForEach(AssetCategory.allCases, id: \.self) { cat in
                        Text(cat.rawValue).tag(cat)
                    }
                }
                .onChange(of: category) { _, newValue in
                    if usefulLife.isEmpty || usefulLife == String(category.defaultUsefulLife) {
                        usefulLife = String(newValue.defaultUsefulLife)
                    }
                }

                DatePicker("購入日", selection: $purchaseDate, displayedComponents: .date)
                TextField("金額", text: $purchasePrice)
                TextField("購入店", text: $purchaseStore)
                TextField("耐用年数", text: $usefulLife)
                TextField("備考", text: $notes, axis: .vertical)
                    .lineLimit(3)
            }
            .padding()

            HStack {
                Button("キャンセル") { dismiss() }
                    .keyboardShortcut(.cancelAction)
                Spacer()
                Button(isAdding ? "追加" : "保存") { save() }
                    .keyboardShortcut(.defaultAction)
                    .disabled(name.isEmpty)
            }
            .padding()
        }
        .frame(minWidth: 400, minHeight: 360)
        .onAppear { loadIfEditing() }
    }

    private var isAdding: Bool {
        if case .add = mode { return true }
        return false
    }

    private func loadIfEditing() {
        guard case .edit(let asset) = mode else { return }
        name = asset.name
        category = asset.category
        purchaseDate = asset.purchaseDate
        purchasePrice = String(asset.purchasePrice)
        purchaseStore = asset.purchaseStore
        usefulLife = String(asset.usefulLife)
        notes = asset.notes
    }

    private func save() {
        let price = Int(purchasePrice) ?? 0
        let life = Int(usefulLife) ?? category.defaultUsefulLife

        switch mode {
        case .add:
            let asset = Asset(
                name: name,
                category: category,
                purchaseDate: purchaseDate,
                purchasePrice: price,
                purchaseStore: purchaseStore,
                usefulLife: life,
                notes: notes
            )
            store.add(asset)
        case .edit(var asset):
            asset.name = name
            asset.category = category
            asset.purchaseDate = purchaseDate
            asset.purchasePrice = price
            asset.purchaseStore = purchaseStore
            asset.usefulLife = life
            asset.notes = notes
            store.update(asset)
        }
        dismiss()
    }
}
