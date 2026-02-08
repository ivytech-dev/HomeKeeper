import Foundation
import UserNotifications

final class PushNotificationManager {
    static let shared = PushNotificationManager()

    private let center = UNUserNotificationCenter.current()

    private init() {}

    func requestAuthorization() {
        center.requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if let error = error {
                print("Notification authorization error: \(error.localizedDescription)")
            }
        }
    }

    func scheduleNotification(for task: HouseholdTask, at date: Date) {
        let content = UNMutableNotificationContent()
        content.title = "HomeKeeper"
        content.body = "\(task.category.rawValue): \(task.title)"
        content.sound = .default
        content.userInfo = ["taskId": task.id.uuidString]

        let components = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: date
        )
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(
            identifier: task.id.uuidString,
            content: content,
            trigger: trigger
        )

        center.add(request)
    }

    func scheduleRecurringNotification(for task: HouseholdTask, recurrence: Recurrence, at date: Date) {
        let content = UNMutableNotificationContent()
        content.title = "HomeKeeper"
        content.body = "\(task.category.rawValue): \(task.title)"
        content.sound = .default
        content.userInfo = ["taskId": task.id.uuidString]

        var components: DateComponents
        switch recurrence {
        case .daily:
            components = Calendar.current.dateComponents([.hour, .minute], from: date)
        case .weekly:
            components = Calendar.current.dateComponents([.weekday, .hour, .minute], from: date)
        case .biweekly:
            components = Calendar.current.dateComponents([.weekday, .hour, .minute], from: date)
        case .monthly:
            components = Calendar.current.dateComponents([.day, .hour, .minute], from: date)
        }

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(
            identifier: task.id.uuidString,
            content: content,
            trigger: trigger
        )

        center.add(request)
    }

    func cancelNotification(for identifier: String) {
        center.removePendingNotificationRequests(withIdentifiers: [identifier])
    }

    func cancelAllNotifications() {
        center.removeAllPendingNotificationRequests()
    }
}
