import Foundation

struct Asset: Identifiable, Codable {
    let id: UUID
    var name: String
    var category: AssetCategory
    var purchaseDate: Date
    var purchasePrice: Int
    var purchaseStore: String
    var usefulLife: Int
    var isRetired: Bool
    var retiredDate: Date?
    var notes: String

    init(
        id: UUID = UUID(),
        name: String,
        category: AssetCategory,
        purchaseDate: Date = Date(),
        purchasePrice: Int = 0,
        purchaseStore: String = "",
        usefulLife: Int? = nil,
        isRetired: Bool = false,
        retiredDate: Date? = nil,
        notes: String = ""
    ) {
        self.id = id
        self.name = name
        self.category = category
        self.purchaseDate = purchaseDate
        self.purchasePrice = purchasePrice
        self.purchaseStore = purchaseStore
        self.usefulLife = usefulLife ?? category.defaultUsefulLife
        self.isRetired = isRetired
        self.retiredDate = retiredDate
        self.notes = notes
    }

    var elapsedYears: Double {
        let days = Calendar.current.dateComponents([.day], from: purchaseDate, to: Date()).day ?? 0
        return Double(days) / 365.25
    }

    var dailyCost: Double {
        guard elapsedYears > 0 else { return 0 }
        return Double(purchasePrice) / (elapsedYears * 365.25)
    }

    var isOverUsefulLife: Bool {
        elapsedYears > Double(usefulLife)
    }

    var usefulLifeProgress: Double {
        min(elapsedYears / Double(usefulLife), 1.5)
    }
}

enum AssetCategory: String, Codable, CaseIterable {
    case tv = "テレビ"
    case refrigerator = "冷蔵庫"
    case washingMachine = "洗濯機"
    case vacuumCleaner = "掃除機"
    case airConditioner = "エアコン"
    case microwave = "電子レンジ"
    case riceCooker = "炊飯器"
    case dishwasher = "食洗機"
    case pc = "PC"
    case tablet = "タブレット"
    case smartphone = "スマートフォン"
    case watch = "時計"
    case camera = "カメラ"
    case printer = "プリンター/複合機"
    case scanner = "スキャナー"
    case router = "ルータ/ネットワーク"
    case audio = "オーディオ"
    case lighting = "照明"
    case furniture = "家具"
    case other = "その他"

    var defaultUsefulLife: Int {
        switch self {
        case .tv: return 8
        case .refrigerator: return 10
        case .washingMachine: return 7
        case .vacuumCleaner: return 7
        case .airConditioner: return 10
        case .microwave: return 10
        case .riceCooker: return 6
        case .dishwasher: return 7
        case .pc: return 4
        case .tablet: return 4
        case .smartphone: return 3
        case .watch: return 10
        case .camera: return 5
        case .printer: return 5
        case .scanner: return 5
        case .router: return 5
        case .audio: return 7
        case .lighting: return 10
        case .furniture: return 10
        case .other: return 5
        }
    }
}
