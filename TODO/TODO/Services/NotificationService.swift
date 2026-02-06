import Combine
import Foundation
import UserNotifications
import FirebaseMessaging

class NotificationService: NSObject, ObservableObject {
    static let shared = NotificationService()

    @Published var fcmToken: String?

    override private init() {
        super.init()
    }

    func requestPermission() async -> Bool {
        do {
            let granted = try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound])
            return granted
        } catch {
            print("Notification permission error: \(error)")
            return false
        }
    }

    func setupFCM() {
        Messaging.messaging().delegate = self
    }

    // MARK: - Local Notification Fallback

    func scheduleLocalReminder(for task: TaskItem) {
        guard !task.isCompleted, let taskId = task.id else { return }

        // Remove existing notifications for this task
        removeLocalReminders(for: taskId)

        // Schedule a reminder at a random time before the deadline
        let timeRemaining = task.deadline.timeIntervalSince(Date())
        guard timeRemaining > 0 else { return }

        // Schedule up to 3 local notifications as fallback
        let count = min(3, max(1, task.intensity / 3))
        for i in 0..<count {
            let randomOffset = Double.random(in: 0.1...0.9) * timeRemaining
            let triggerDate = Date().addingTimeInterval(randomOffset)

            let content = UNMutableNotificationContent()
            content.title = "T.O.D.O"
            content.body = Self.randomMessage(for: task)
            content.sound = .default
            content.badge = 1

            let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: triggerDate)
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)

            let request = UNNotificationRequest(
                identifier: "\(taskId)-local-\(i)",
                content: content,
                trigger: trigger
            )

            UNUserNotificationCenter.current().add(request)
        }
    }

    func removeLocalReminders(for taskId: String) {
        let identifiers = (0..<10).map { "\(taskId)-local-\($0)" }
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
    }

    func removeAllLocalReminders() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }

    // MARK: - Message Templates

    static func randomMessage(for task: TaskItem) -> String {
        let timeRemaining = task.timeRemaining
        let hours = timeRemaining / 3600

        let messages: [String]
        if timeRemaining <= 0 {
            messages = [
                "'\(task.title)' is OVERDUE! Time to get it done.",
                "Past deadline: '\(task.title)'. Don't let it slip further!",
                "OVERDUE ALERT: '\(task.title)' needed your attention yesterday!"
            ]
        } else if hours < 24 {
            messages = [
                "FINAL CALL: '\(task.title)' is due in less than a day!",
                "Hours left for '\(task.title)'. Lock in now!",
                "'\(task.title)' deadline is TODAY. You've got this!"
            ]
        } else if hours < 72 {
            messages = [
                "'\(task.title)' is coming up soon. Time to make progress!",
                "Don't wait — '\(task.title)' is due \(task.relativeDeadline).",
                "Getting close! '\(task.title)' needs your attention."
            ]
        } else {
            messages = [
                "Friendly nudge: '\(task.title)' is on your list.",
                "Have you thought about '\(task.title)' today?",
                "You've got this! '\(task.title)' is due \(task.relativeDeadline)."
            ]
        }

        return messages.randomElement() ?? messages[0]
    }
}

// MARK: - FCM Delegate

extension NotificationService: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        self.fcmToken = fcmToken
    }
}
