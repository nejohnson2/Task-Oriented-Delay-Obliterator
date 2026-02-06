import Foundation
import FirebaseFirestore

enum ReminderType: String, Codable, CaseIterable, Identifiable {
    case push = "push"
    case email = "email"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .push: return "Push Notifications"
        case .email: return "Email"
        }
    }

    var iconName: String {
        switch self {
        case .push: return "bell.fill"
        case .email: return "envelope.fill"
        }
    }
}

struct TaskItem: Identifiable, Codable {
    @DocumentID var id: String?
    var title: String
    var details: String
    var deadline: Date
    var isCompleted: Bool
    var intensity: Int
    var reminderTypes: [ReminderType]
    var createdAt: Date
    var userId: String

    var isOverdue: Bool {
        !isCompleted && deadline < Date()
    }

    var timeRemaining: TimeInterval {
        deadline.timeIntervalSince(Date())
    }

    var relativeDeadline: String {
        if isOverdue {
            let formatter = RelativeDateTimeFormatter()
            formatter.unitsStyle = .full
            return formatter.localizedString(for: deadline, relativeTo: Date())
        }

        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: deadline, relativeTo: Date())
    }

    static func empty(userId: String) -> TaskItem {
        TaskItem(
            title: "",
            details: "",
            deadline: Date().addingTimeInterval(86400), // tomorrow
            isCompleted: false,
            intensity: 5,
            reminderTypes: [.push],
            createdAt: Date(),
            userId: userId
        )
    }
}

struct UserProfile: Codable {
    var email: String
    var fcmToken: String?
    var quietHoursStart: Int // hour (0-23)
    var quietHoursEnd: Int   // hour (0-23)
    var defaultIntensity: Int
    var defaultReminderTypes: [ReminderType]

    static func defaultProfile(email: String) -> UserProfile {
        UserProfile(
            email: email,
            fcmToken: nil,
            quietHoursStart: 22, // 10 PM
            quietHoursEnd: 8,    // 8 AM
            defaultIntensity: 5,
            defaultReminderTypes: [.push]
        )
    }
}
