import Foundation
import SwiftUI

class TaskStore: ObservableObject {
    @Published var tasks: [HouseholdTask] = []

    private let saveKey = "homekeeper_tasks"

    init() {
        load()
    }

    func add(_ task: HouseholdTask) {
        tasks.append(task)
        if task.notificationEnabled, let dueDate = task.dueDate {
            PushNotificationManager.shared.scheduleNotification(for: task, at: dueDate)
        }
        save()
    }

    func remove(at offsets: IndexSet) {
        let removedTasks = offsets.map { tasks[$0] }
        for task in removedTasks {
            PushNotificationManager.shared.cancelNotification(for: task.id.uuidString)
        }
        tasks.remove(atOffsets: offsets)
        save()
    }

    func toggleComplete(_ task: HouseholdTask) {
        guard let index = tasks.firstIndex(where: { $0.id == task.id }) else { return }
        tasks[index].isCompleted.toggle()
        save()
    }

    private func save() {
        if let data = try? JSONEncoder().encode(tasks) {
            UserDefaults.standard.set(data, forKey: saveKey)
        }
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: saveKey),
              let decoded = try? JSONDecoder().decode([HouseholdTask].self, from: data) else { return }
        tasks = decoded
    }
}
