import Combine
import Foundation
import FirebaseFirestore

@MainActor
class TaskViewModel: ObservableObject {
    @Published var tasks: [TaskItem] = []
    @Published var errorMessage: String?

    private var listener: ListenerRegistration?
    private let firestoreService = FirestoreService.shared
    private let notificationService = NotificationService.shared

    var activeTasks: [TaskItem] {
        tasks.filter { !$0.isCompleted }
    }

    var completedTasks: [TaskItem] {
        tasks.filter { $0.isCompleted }
    }

    var overdueTasks: [TaskItem] {
        tasks.filter { $0.isOverdue }
    }

    func startListening(userId: String) {
        listener = firestoreService.listenToTasks(userId: userId) { [weak self] result in
            Task { @MainActor in
                switch result {
                case .success(let tasks):
                    self?.tasks = tasks
                    // Refresh local notification fallbacks
                    self?.scheduleLocalNotifications(for: tasks)
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }

    func stopListening() {
        listener?.remove()
        listener = nil
    }

    func addTask(_ task: TaskItem) async {
        do {
            _ = try await firestoreService.addTask(task)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func updateTask(_ task: TaskItem) async {
        do {
            try await firestoreService.updateTask(task)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func deleteTask(_ task: TaskItem) async {
        if let taskId = task.id {
            notificationService.removeLocalReminders(for: taskId)
        }
        do {
            try await firestoreService.deleteTask(task)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func toggleComplete(_ task: TaskItem) async {
        var updated = task
        updated.isCompleted.toggle()

        if updated.isCompleted, let taskId = updated.id {
            notificationService.removeLocalReminders(for: taskId)
        }

        await updateTask(updated)
    }

    private func scheduleLocalNotifications(for tasks: [TaskItem]) {
        notificationService.removeAllLocalReminders()
        for task in tasks where !task.isCompleted {
            notificationService.scheduleLocalReminder(for: task)
        }
    }
}
