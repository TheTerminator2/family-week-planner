import Foundation
import UserNotifications

final class NotificationManager: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationManager(); private override init() { super.init() }
    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert,.badge,.sound]) { _,_ in }
        UNUserNotificationCenter.current().delegate = self
    }
    func scheduleStartOfWeekReminder(weekKey: String, dateComponents: DateComponents, taskTitles: [String]) {
        let c = UNMutableNotificationContent(); c.title = "Ugen er i gang"
        let tasks = taskTitles.prefix(6).joined(separator: ", "); c.body = taskTitles.isEmpty ? "Vælg dine ugens opgaver." : "Dine opgaver: " + tasks + (taskTitles.count > 6 ? " …" : "")
        c.sound = .default
        UNUserNotificationCenter.current().add(UNNotificationRequest(identifier: "start_\(weekKey)", content: c, trigger: UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)))
    }
    func scheduleEndOfWeekWarning(weekKey: String, dateComponents: DateComponents) {
        let c = UNMutableNotificationContent(); c.title = "Ugen slutter snart"; c.body = "Husk at færdiggøre dine valgte opgaver for ugen."; c.sound = .default
        UNUserNotificationCenter.current().add(UNNotificationRequest(identifier: "end_\(weekKey)", content: c, trigger: UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)))
    }
    func cancelEndOfWeekWarning(weekKey: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["end_\(weekKey)"])
    }
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification) async -> UNNotificationPresentationOptions { [.list,.banner,.sound] }
}
