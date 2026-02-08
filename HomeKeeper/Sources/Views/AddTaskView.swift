import SwiftUI

struct AddTaskView: View {
    @EnvironmentObject var store: TaskStore
    @Environment(\.dismiss) private var dismiss

    @State private var title = ""
    @State private var category: TaskCategory = .other
    @State private var hasDueDate = false
    @State private var dueDate = Date()
    @State private var hasRecurrence = false
    @State private var recurrence: Recurrence = .weekly
    @State private var notificationEnabled = true

    var body: some View {
        NavigationStack {
            Form {
                Section("タスク情報") {
                    TextField("タスク名", text: $title)
                    Picker("カテゴリ", selection: $category) {
                        ForEach(TaskCategory.allCases, id: \.self) { cat in
                            Text(cat.rawValue).tag(cat)
                        }
                    }
                }

                Section("スケジュール") {
                    Toggle("期限を設定", isOn: $hasDueDate)
                    if hasDueDate {
                        DatePicker("期限", selection: $dueDate, displayedComponents: [.date, .hourAndMinute])
                    }

                    Toggle("繰り返し", isOn: $hasRecurrence)
                    if hasRecurrence {
                        Picker("頻度", selection: $recurrence) {
                            ForEach(Recurrence.allCases, id: \.self) { r in
                                Text(r.rawValue).tag(r)
                            }
                        }
                    }
                }

                Section("通知") {
                    Toggle("プッシュ通知", isOn: $notificationEnabled)
                }
            }
            .navigationTitle("タスク追加")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("キャンセル") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("追加") {
                        let task = HouseholdTask(
                            title: title,
                            category: category,
                            dueDate: hasDueDate ? dueDate : nil,
                            recurrence: hasRecurrence ? recurrence : nil,
                            notificationEnabled: notificationEnabled
                        )
                        store.add(task)
                        dismiss()
                    }
                    .disabled(title.isEmpty)
                }
            }
        }
    }
}
