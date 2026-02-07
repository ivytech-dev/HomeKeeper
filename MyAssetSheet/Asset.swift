import Foundation

struct Asset: Identifiable, Codable {
    var id = UUID()
    var category: String = ""           // 分類
    var productName: String = ""        // 製品
    var store: String = ""              // 購入店
    var purchaseDate: Date = Date()     // 購入日
    var purchasePrice: Int = 0          // 購入金額
    var usefulLifeYears: Int = 0        // 耐用年数
    var notes: String = ""              // 備考

    /// 購入日から現在までの経過日数
    var elapsedDays: Int {
        max(Calendar.current.dateComponents([.day], from: purchaseDate, to: Date()).day ?? 0, 0)
    }

    /// 経過年数（小数）
    var elapsedYears: Double {
        Double(elapsedDays) / 365.25
    }

    /// 1日当たりの費用
    var dailyCost: Double {
        guard elapsedDays > 0 else { return 0 }
        return Double(purchasePrice) / Double(elapsedDays)
    }
}

@MainActor
class AssetStore: ObservableObject {
    @Published var assets: [Asset] = []

    private static var fileURL: URL {
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let dir = appSupport.appendingPathComponent("MyAssetSheet")
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir.appendingPathComponent("assets.json")
    }

    init() {
        load()
    }

    func load() {
        guard let data = try? Data(contentsOf: Self.fileURL) else { return }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        assets = (try? decoder.decode([Asset].self, from: data)) ?? []
    }

    func save() {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = .prettyPrinted
        guard let data = try? encoder.encode(assets) else { return }
        try? data.write(to: Self.fileURL)
    }

    func add(_ asset: Asset) {
        assets.append(asset)
        save()
    }

    func update(_ asset: Asset) {
        if let index = assets.firstIndex(where: { $0.id == asset.id }) {
            assets[index] = asset
            save()
        }
    }

    func delete(_ ids: Set<Asset.ID>) {
        assets.removeAll { ids.contains($0.id) }
        save()
    }
}
