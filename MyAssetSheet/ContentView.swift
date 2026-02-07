import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    @ObservedObject var store: AssetStore
    @State private var selection = Set<Asset.ID>()
    @State private var showingAddSheet = false
    @State private var editingAsset: Asset?
    @State private var sortOrder = [KeyPathComparator(\Asset.purchaseDate, order: .reverse)]
    @State private var showingCSVImporter = false
    @State private var importMessage: String?
    @State private var showDisposed = true
    @State private var showingExporter = false
    @State private var csvDocument = CSVDocument()
    @State private var exportMessage: String?

    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.locale = Locale(identifier: "ja_JP")
        return f
    }()

    private var sortedAssets: [Asset] {
        let filtered = showDisposed ? store.assets : store.assets.filter { !$0.disposed }
        return filtered.sorted(using: sortOrder)
    }

    private func rowOpacity(_ asset: Asset) -> Double {
        asset.disposed ? 0.4 : 1.0
    }

    var body: some View {
        Table(sortedAssets, selection: $selection, sortOrder: $sortOrder) {
            TableColumn("分類", value: \.category) { asset in
                Text(asset.category)
                    .opacity(rowOpacity(asset))
            }
            .width(min: 60, ideal: 80)

            TableColumn("製品", value: \.productName) { asset in
                Text(asset.productName)
                    .opacity(rowOpacity(asset))
            }
            .width(min: 80, ideal: 120)

            TableColumn("購入店", value: \.store) { asset in
                Text(asset.store)
                    .opacity(rowOpacity(asset))
            }
            .width(min: 60, ideal: 100)

            TableColumn("購入日", value: \.purchaseDate) { asset in
                Text(Self.dateFormatter.string(from: asset.purchaseDate))
                    .opacity(rowOpacity(asset))
            }
            .width(min: 80, ideal: 100)

            TableColumn("購入金額", value: \.purchasePrice) { asset in
                Text("¥\(asset.purchasePrice.formatted())")
                    .monospacedDigit()
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .opacity(rowOpacity(asset))
            }
            .width(min: 80, ideal: 100)

            TableColumn("経過日数") { (asset: Asset) in
                Text(asset.disposed ? "-" : "\(asset.elapsedDays.formatted())日")
                    .monospacedDigit()
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .opacity(rowOpacity(asset))
            }
            .width(min: 60, ideal: 80)

            TableColumn("経過年数") { (asset: Asset) in
                Text(asset.disposed ? "-" : String(format: "%.1f年", asset.elapsedYears))
                    .monospacedDigit()
                    .foregroundColor(
                        !asset.disposed && asset.usefulLifeYears > 0 && asset.elapsedYears > Double(asset.usefulLifeYears) ? .red : .primary
                    )
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .opacity(rowOpacity(asset))
            }
            .width(min: 60, ideal: 70)

            TableColumn("日額費用") { (asset: Asset) in
                Text(asset.disposed ? "-" :
                     (asset.purchasePrice > 0 && asset.elapsedDays > 0
                      ? String(format: "¥%.1f", asset.dailyCost) : "-"))
                    .monospacedDigit()
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .opacity(rowOpacity(asset))
            }
            .width(min: 60, ideal: 80)

            TableColumn("耐用年数", value: \.usefulLifeYears) { asset in
                Text("\(asset.usefulLifeYears)年")
                    .monospacedDigit()
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .opacity(rowOpacity(asset))
            }
            .width(min: 50, ideal: 60)

            TableColumn("備考", value: \.notes) { asset in
                Text(asset.disposed ? "除却済み" + (asset.notes.isEmpty ? "" : " \(asset.notes)") : asset.notes)
                    .opacity(rowOpacity(asset))
            }
            .width(min: 60, ideal: 120)
        }
        .contextMenu(forSelectionType: Asset.ID.self) { ids in
            if ids.isEmpty {
                Button("追加") { showingAddSheet = true }
            } else {
                if ids.count == 1 {
                    Button("編集") {
                        if let asset = store.assets.first(where: { $0.id == ids.first }) {
                            editingAsset = asset
                        }
                    }
                }
                let allDisposed = ids.allSatisfy { id in
                    store.assets.first { $0.id == id }?.disposed == true
                }
                Button(allDisposed ? "除却を解除" : "除却済みにする") {
                    store.toggleDisposed(ids)
                }
                Button("削除", role: .destructive) {
                    store.delete(ids)
                    selection.removeAll()
                }
            }
        } primaryAction: { ids in
            if let asset = store.assets.first(where: { $0.id == ids.first }) {
                editingAsset = asset
            }
        }
        .toolbar {
            ToolbarItemGroup {
                Button {
                    showDisposed.toggle()
                    if !showDisposed {
                        selection = selection.filter { id in
                            store.assets.first { $0.id == id }?.disposed != true
                        }
                    }
                } label: {
                    Label(
                        showDisposed ? "除却済みを非表示" : "除却済みを表示",
                        systemImage: showDisposed ? "eye" : "eye.slash"
                    )
                }
                .help(showDisposed ? "除却済みを非表示" : "除却済みを表示")

                Button {
                    showingAddSheet = true
                } label: {
                    Label("追加", systemImage: "plus")
                }
                .help("新規追加")

                Button {
                    showingCSVImporter = true
                } label: {
                    Label("CSV取込", systemImage: "square.and.arrow.down")
                }
                .help("CSV取込")

                Button {
                    csvDocument = CSVDocument(text: store.exportCSV())
                    showingExporter = true
                } label: {
                    Label("CSV出力", systemImage: "square.and.arrow.up")
                }
                .disabled(store.assets.isEmpty)
                .help("CSV出力")

                Button {
                    store.delete(selection)
                    selection.removeAll()
                } label: {
                    Label("削除", systemImage: "trash")
                }
                .disabled(selection.isEmpty)
                .help("削除")
            }
        }
        .fileImporter(
            isPresented: $showingCSVImporter,
            allowedContentTypes: [.commaSeparatedText, .plainText],
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case .success(let urls):
                guard let url = urls.first else { return }
                let accessing = url.startAccessingSecurityScopedResource()
                defer { if accessing { url.stopAccessingSecurityScopedResource() } }
                do {
                    let count = try store.importCSV(from: url)
                    importMessage = "\(count)件のデータを取り込みました。"
                } catch {
                    importMessage = "読み込みエラー: \(error.localizedDescription)"
                }
            case .failure(let error):
                importMessage = "ファイル選択エラー: \(error.localizedDescription)"
            }
        }
        .fileExporter(
            isPresented: $showingExporter,
            document: csvDocument,
            contentType: .commaSeparatedText,
            defaultFilename: "HomeKeeper.csv"
        ) { result in
            if case .failure(let error) = result {
                exportMessage = "書き出しエラー: \(error.localizedDescription)"
            }
        }
        .alert("CSV取込", isPresented: Binding(
            get: { importMessage != nil },
            set: { if !$0 { importMessage = nil } }
        )) {
            Button("OK") { importMessage = nil }
        } message: {
            Text(importMessage ?? "")
        }
        .alert("CSV出力", isPresented: Binding(
            get: { exportMessage != nil },
            set: { if !$0 { exportMessage = nil } }
        )) {
            Button("OK") { exportMessage = nil }
        } message: {
            Text(exportMessage ?? "")
        }
        .sheet(isPresented: $showingAddSheet) {
            AssetFormView { asset in
                store.add(asset)
            }
        }
        .sheet(item: $editingAsset) { asset in
            AssetFormView(asset: asset) { updated in
                store.update(updated)
            }
        }
        .navigationTitle("耐久消費財管理")
        .frame(minWidth: 900, minHeight: 400)
    }
}

// MARK: - CSV Document

struct CSVDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.commaSeparatedText] }

    var text: String

    init(text: String = "") {
        self.text = text
    }

    init(configuration: ReadConfiguration) throws {
        text = String(data: configuration.file.regularFileContents ?? Data(), encoding: .utf8) ?? ""
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        FileWrapper(regularFileWithContents: text.data(using: .utf8) ?? Data())
    }
}
