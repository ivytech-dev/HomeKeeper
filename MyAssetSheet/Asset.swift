import Foundation

enum AssetCategory {
    /// 分類名とデフォルト耐用年数（年）
    static let catalog: [(name: String, usefulLife: Int)] = [
        ("テレビ",             8),   // メーカー補修部品保有 8年
        ("冷蔵庫",             10),  // 補修部品保有 9年、実使用 10〜15年
        ("洗濯機",             7),   // 補修部品保有 6〜7年
        ("掃除機",             7),   // 補修部品保有 6年
        ("エアコン",           10),  // 補修部品保有 10年
        ("電子レンジ",         10),  // 補修部品保有 8年
        ("炊飯器",             6),   // 補修部品保有 6年
        ("食洗機",             7),   // 補修部品保有 6年
        ("PC",                4),   // 法定耐用年数 4年
        ("タブレット",         4),   // 法定耐用年数 4年
        ("スマートフォン",     3),   // 実使用 3〜4年
        ("時計",              10),   // 種類による、電池式 5〜10年
        ("カメラ",             5),   // 法定耐用年数 5年
        ("プリンター/複合機",  5),   // 法定耐用年数 5年
        ("スキャナー",         5),   // 法定耐用年数 5年
        ("ルータ/ネットワーク", 5),  // 法定耐用年数 5年
        ("オーディオ",         7),   // 補修部品保有 8年
        ("照明",              10),   // LED 10年以上
        ("家具",              10),   // 法定耐用年数 8〜15年
    ]

    static let predefined: [String] = catalog.map(\.name)
    static let other = "その他"

    /// 分類名からデフォルト耐用年数を取得
    static func defaultUsefulLife(for category: String) -> Int? {
        catalog.first { $0.name == category }?.usefulLife
    }
}

struct Asset: Identifiable, Codable {
    var id = UUID()
    var category: String = ""           // 分類
    var productName: String = ""        // 製品
    var store: String = ""              // 購入店
    var purchaseDate: Date = Date()     // 購入日
    var purchasePrice: Int = 0          // 購入金額
    var usefulLifeYears: Int = 0        // 耐用年数
    var notes: String = ""              // 備考
    var disposed: Bool = false          // 除却済み

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
        let dir = appSupport.appendingPathComponent("HomeKeeper")
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

    // MARK: - CSV Export

    func exportCSV() -> String {
        let header = "分類,製品,購入店,購入日,購入金額,耐用年数,備考"
        let df = DateFormatter()
        df.dateFormat = "yyyy/MM/dd"

        let rows = assets.map { asset -> String in
            let notes = asset.disposed
                ? "除却済み" + (asset.notes.isEmpty ? "" : " \(asset.notes)")
                : asset.notes
            let cols = [
                csvEscape(asset.category),
                csvEscape(asset.productName),
                csvEscape(asset.store),
                df.string(from: asset.purchaseDate),
                String(asset.purchasePrice),
                String(asset.usefulLifeYears),
                csvEscape(notes),
            ]
            return cols.joined(separator: ",")
        }
        return ([header] + rows).joined(separator: "\n") + "\n"
    }

    private func csvEscape(_ field: String) -> String {
        if field.contains(",") || field.contains("\"") || field.contains("\n") {
            return "\"" + field.replacingOccurrences(of: "\"", with: "\"\"") + "\""
        }
        return field
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

    func toggleDisposed(_ ids: Set<Asset.ID>) {
        for id in ids {
            if let index = assets.firstIndex(where: { $0.id == id }) {
                assets[index].disposed.toggle()
            }
        }
        save()
    }

    func delete(_ ids: Set<Asset.ID>) {
        assets.removeAll { ids.contains($0.id) }
        save()
    }

    // MARK: - CSV Import

    /// CSV ファイルを読み込んでアセットを追加する
    /// 期待するカラム順: 分類, 製品, 購入店, 購入日, 購入金額, 耐用年数, 備考
    /// 1行目がヘッダ行（"分類" or "製品" を含む）なら自動スキップ
    func importCSV(from url: URL) throws -> Int {
        let content = try String(contentsOf: url, encoding: .utf8)
        let lines = content.components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }

        guard !lines.isEmpty else { return 0 }

        var dataLines = lines
        // ヘッダ行の判定・スキップ
        if let first = dataLines.first, first.contains("分類") || first.contains("製品") {
            dataLines.removeFirst()
        }

        var imported = 0
        for line in dataLines {
            let cols = parseCSVLine(line)
            guard cols.count >= 2 else { continue } // 最低限「分類」「製品」が必要

            var asset = Asset()
            asset.category = cols.value(at: 0)
            asset.productName = cols.value(at: 1)
            asset.store = cols.value(at: 2)
            asset.purchaseDate = Self.parseDate(cols.value(at: 3)) ?? Date()
            asset.purchasePrice = Int(cols.value(at: 4).replacingOccurrences(of: ",", with: "")) ?? 0
            asset.usefulLifeYears = Int(cols.value(at: 5)) ?? 0
            let rawNotes = cols.value(at: 6)
            if rawNotes.contains("除却済み") {
                asset.disposed = true
                asset.notes = rawNotes.replacingOccurrences(of: "除却済み", with: "").trimmingCharacters(in: .whitespaces)
            } else {
                asset.notes = rawNotes
            }

            assets.append(asset)
            imported += 1
        }

        if imported > 0 { save() }
        return imported
    }

    /// CSV の1行をパースし、ダブルクォート囲みやカンマを正しく処理する
    private func parseCSVLine(_ line: String) -> [String] {
        var fields: [String] = []
        var current = ""
        var inQuotes = false
        var iterator = line.makeIterator()

        while let char = iterator.next() {
            if inQuotes {
                if char == "\"" {
                    // "" はエスケープされた引用符
                    if let next = iterator.next() {
                        if next == "\"" {
                            current.append("\"")
                        } else {
                            inQuotes = false
                            if next == "," {
                                fields.append(current)
                                current = ""
                            } else {
                                current.append(next)
                            }
                        }
                    } else {
                        inQuotes = false
                    }
                } else {
                    current.append(char)
                }
            } else {
                if char == "\"" {
                    inQuotes = true
                } else if char == "," {
                    fields.append(current)
                    current = ""
                } else {
                    current.append(char)
                }
            }
        }
        fields.append(current)
        return fields
    }

    private static func parseDate(_ string: String) -> Date? {
        let trimmed = string.trimmingCharacters(in: .whitespaces)
        if trimmed.isEmpty { return nil }
        for fmt in ["yyyy/MM/dd", "yyyy-MM-dd", "yyyy.MM.dd", "yyyy年MM月dd日"] {
            let df = DateFormatter()
            df.locale = Locale(identifier: "ja_JP")
            df.dateFormat = fmt
            if let date = df.date(from: trimmed) { return date }
        }
        return nil
    }
}

private extension Array where Element == String {
    func value(at index: Int) -> String {
        index < count ? self[index].trimmingCharacters(in: .whitespaces) : ""
    }
}
