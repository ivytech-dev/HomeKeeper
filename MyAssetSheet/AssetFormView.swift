import SwiftUI

struct AssetFormView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var category: String
    @State private var productName: String
    @State private var store: String
    @State private var purchaseDate: Date
    @State private var purchasePrice: String
    @State private var usefulLifeYears: String
    @State private var notes: String

    private let existingAsset: Asset?
    private let onSave: (Asset) -> Void

    init(asset: Asset? = nil, onSave: @escaping (Asset) -> Void) {
        self.existingAsset = asset
        self.onSave = onSave
        _category = State(initialValue: asset?.category ?? "")
        _productName = State(initialValue: asset?.productName ?? "")
        _store = State(initialValue: asset?.store ?? "")
        _purchaseDate = State(initialValue: asset?.purchaseDate ?? Date())
        _purchasePrice = State(initialValue: asset.map { String($0.purchasePrice) } ?? "")
        _usefulLifeYears = State(initialValue: asset.map { String($0.usefulLifeYears) } ?? "")
        _notes = State(initialValue: asset?.notes ?? "")
    }

    var body: some View {
        VStack(spacing: 16) {
            Text(existingAsset == nil ? "新規登録" : "編集")
                .font(.headline)

            Form {
                TextField("分類:", text: $category)
                TextField("製品:", text: $productName)
                TextField("購入店:", text: $store)
                DatePicker("購入日:", selection: $purchaseDate, displayedComponents: .date)
                TextField("購入金額 (円):", text: $purchasePrice)
                TextField("耐用年数:", text: $usefulLifeYears)
                TextField("備考:", text: $notes)
            }

            HStack {
                Button("キャンセル") { dismiss() }
                    .keyboardShortcut(.cancelAction)
                Spacer()
                Button("保存") { save() }
                    .keyboardShortcut(.defaultAction)
                    .disabled(productName.isEmpty)
            }
        }
        .padding()
        .frame(width: 400)
    }

    private func save() {
        var asset = existingAsset ?? Asset()
        asset.category = category
        asset.productName = productName
        asset.store = store
        asset.purchaseDate = purchaseDate
        asset.purchasePrice = Int(purchasePrice) ?? 0
        asset.usefulLifeYears = Int(usefulLifeYears) ?? 0
        asset.notes = notes
        onSave(asset)
        dismiss()
    }
}
