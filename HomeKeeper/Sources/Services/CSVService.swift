import Foundation

struct CSVService {
    enum DateFormat: String, CaseIterable {
        case iso = "yyyy-MM-dd"
        case slashYMD = "yyyy/MM/dd"
        case dotYMD = "yyyy.MM.dd"
        case japanese = "yyyy年MM月dd日"
    }

    static func export(assets: [Asset], dateFormat: DateFormat = .iso) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = dateFormat.rawValue

        var csv = "分類,製品名,購入店,購入日,金額,耐用年数,除却,除却日,備考\n"
        for asset in assets {
            let retired = asset.isRetired ? "済" : ""
            let retiredDate = asset.retiredDate.map { formatter.string(from: $0) } ?? ""
            let line = [
                asset.category.rawValue,
                asset.name,
                asset.purchaseStore,
                formatter.string(from: asset.purchaseDate),
                String(asset.purchasePrice),
                String(asset.usefulLife),
                retired,
                retiredDate,
                asset.notes
            ].map { "\"\($0)\"" }.joined(separator: ",")
            csv += line + "\n"
        }
        return csv
    }

    static func importCSV(_ content: String, dateFormat: DateFormat = .iso) -> [Asset] {
        let formatter = DateFormatter()
        formatter.dateFormat = dateFormat.rawValue

        let lines = content.components(separatedBy: .newlines).filter { !$0.isEmpty }
        guard lines.count > 1 else { return [] }

        return lines.dropFirst().compactMap { line in
            let fields = parseCSVLine(line)
            guard fields.count >= 6 else { return nil }

            let category = AssetCategory.allCases.first { $0.rawValue == fields[0] } ?? .other
            let date = formatter.date(from: fields[3]) ?? Date()
            let price = Int(fields[4]) ?? 0
            let life = Int(fields[5]) ?? category.defaultUsefulLife
            let retired = fields.count > 6 && fields[6] == "済"
            let retiredDate = fields.count > 7 ? formatter.date(from: fields[7]) : nil
            let notes = fields.count > 8 ? fields[8] : ""

            return Asset(
                name: fields[1],
                category: category,
                purchaseDate: date,
                purchasePrice: price,
                purchaseStore: fields.count > 2 ? fields[2] : "",
                usefulLife: life,
                isRetired: retired,
                retiredDate: retiredDate,
                notes: notes
            )
        }
    }

    private static func parseCSVLine(_ line: String) -> [String] {
        var fields: [String] = []
        var current = ""
        var inQuotes = false

        for char in line {
            if char == "\"" {
                inQuotes.toggle()
            } else if char == "," && !inQuotes {
                fields.append(current)
                current = ""
            } else {
                current.append(char)
            }
        }
        fields.append(current)
        return fields
    }
}
