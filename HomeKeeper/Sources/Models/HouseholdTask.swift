import Foundation

struct HouseholdTask: Identifiable, Codable {
    let id: UUID
    var title: String
    var category: TaskCategory
    var isCompleted: Bool
    var dueDate: Date?
    var recurrence: Recurrence?
    var notificationEnabled: Bool

    init(
        id: UUID = UUID(),
        title: String,
        category: TaskCategory,
        isCompleted: Bool = false,
        dueDate: Date? = nil,
        recurrence: Recurrence? = nil,
        notificationEnabled: Bool = true
    ) {
        self.id = id
        self.title = title
        self.category = category
        self.isCompleted = isCompleted
        self.dueDate = dueDate
        self.recurrence = recurrence
        self.notificationEnabled = notificationEnabled
    }
}

enum TaskCategory: String, Codable, CaseIterable {
    case cleaning = "掃除"
    case laundry = "洗濯"
    case cooking = "料理"
    case shopping = "買い物"
    case maintenance = "メンテナンス"
    case other = "その他"
}

enum Recurrence: String, Codable, CaseIterable {
    case daily = "毎日"
    case weekly = "毎週"
    case biweekly = "隔週"
    case monthly = "毎月"
}
