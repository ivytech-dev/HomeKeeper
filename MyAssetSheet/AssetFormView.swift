import SwiftUI

struct AssetFormView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var selectedCategory: String
    @State private var customCategory: String
    @State private var productName: String
    @State private var store: String
    @State private var purchaseDate: Date
    @State private var purchasePrice: String
    @State private var usefulLifeYears: String
    @State private var notes: String
    @State private var disposed: Bool

    private let existingAsset: Asset?
    private let onSave: (Asset) -> Void

    private var category: String {
        selectedCategory == AssetCategory.other ? customCategory : selectedCategory
    }

    init(asset: Asset? = nil, onSave: @escaping (Asset) -> Void) {
        self.existingAsset = asset
        self.onSave = onSave
        let cat = asset?.category ?? ""
        let isPredefined = AssetCategory.predefined.contains(cat)
        _selectedCategory = State(initialValue: isPredefined ? cat : (cat.isEmpty ? "" : AssetCategory.other))
        _customCategory = State(initialValue: isPredefined ? "" : cat)
        _productName = State(initialValue: asset?.productName ?? "")
        _store = State(initialValue: asset?.store ?? "")
        _purchaseDate = State(initialValue: asset?.purchaseDate ?? Date())
        _purchasePrice = State(initialValue: asset.map { String($0.purchasePrice) } ?? "")
        _usefulLifeYears = State(initialValue: asset.map { String($0.usefulLifeYears) } ?? "")
        _notes = State(initialValue: asset?.notes ?? "")
        _disposed = State(initialValue: asset?.disposed ?? false)
    }

    var body: some View {
        VStack(spacing: 16) {
            Text(existingAsset == nil ? "新規登録" : "編集")
                .font(.headline)

            Form {
                Picker("分類:", selection: $selectedCategory) {
                    Text("選択してください").tag("")
                    ForEach(AssetCategory.predefined, id: \.self) { cat in
                        Text(cat).tag(cat)
                    }
                    Divider()
                    Text(AssetCategory.other).tag(AssetCategory.other)
                }
                if selectedCategory == AssetCategory.other {
                    TextField("分類名:", text: $customCategory)
                }
                TextField("製品:", text: $productName)
                TextField("購入店:", text: $store)
                DatePicker("購入日:", selection: $purchaseDate, displayedComponents: .date)
                TextField("購入金額 (円):", text: $purchasePrice)
                TextField("耐用年数:", text: $usefulLifeYears)
                TextField("備考:", text: $notes)
                Toggle("除却済み", isOn: $disposed)
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
        asset.disposed = disposed
        onSave(asset)
        dismiss()
    }
}
