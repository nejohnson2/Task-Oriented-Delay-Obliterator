import SwiftUI
import FirebaseAuth

struct TaskListView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var taskViewModel = TaskViewModel()
    @State private var showAddTask = false
    @State private var editingTask: TaskItem?
    @State private var showSettings = false
    @State private var showCompletedTasks = false
    @State private var newTask: TaskItem = .empty(userId: "")
    @State private var taskToEdit: TaskItem = .empty(userId: "")

    private var userId: String {
        authViewModel.currentUser?.uid ?? ""
    }

    var body: some View {
        NavigationStack {
            Group {
                if taskViewModel.activeTasks.isEmpty && taskViewModel.completedTasks.isEmpty {
                    emptyState
                } else {
                    taskList
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    VStack(spacing: 2) {
                        Text("T.O.D.O")
                            .font(.headline.weight(.black))
                        Text("Task-Oriented Delay Obliterator")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        showSettings = true
                    } label: {
                        Image(systemName: "gear")
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        newTask = .empty(userId: userId)
                        showAddTask = true
                    } label: {
                        Image(systemName: "plus")
                            .fontWeight(.semibold)
                    }
                }
            }
            .sheet(isPresented: $showAddTask) {
                TaskEditView(task: $newTask, isNew: true) { task in
                    Task { await taskViewModel.addTask(task) }
                }
            }
            .sheet(item: $editingTask) { task in
                TaskEditView(task: Binding(
                    get: { taskToEdit },
                    set: { taskToEdit = $0 }
                ), isNew: false) { updated in
                    Task { await taskViewModel.updateTask(updated) }
                }
                .onAppear { taskToEdit = task }
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
            .onAppear {
                taskViewModel.startListening(userId: userId)
            }
            .onDisappear {
                taskViewModel.stopListening()
            }
        }
    }

    // MARK: - Task List

    private var taskList: some View {
        List {
            // Overdue section
            if !taskViewModel.overdueTasks.isEmpty {
                Section {
                    ForEach(taskViewModel.overdueTasks) { task in
                        taskRow(task)
                    }
                } header: {
                    Label("Overdue", systemImage: "exclamationmark.triangle.fill")
                        .foregroundStyle(.red)
                }
            }

            // Active tasks
            let nonOverdueActive = taskViewModel.activeTasks.filter { !$0.isOverdue }
            if !nonOverdueActive.isEmpty {
                Section("Upcoming") {
                    ForEach(nonOverdueActive) { task in
                        taskRow(task)
                    }
                }
            }

            // Completed tasks (collapsible)
            if !taskViewModel.completedTasks.isEmpty {
                Section {
                    DisclosureGroup(isExpanded: $showCompletedTasks) {
                        ForEach(taskViewModel.completedTasks) { task in
                            taskRow(task)
                        }
                    } label: {
                        Text("Completed (\(taskViewModel.completedTasks.count))")
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
    }

    private func taskRow(_ task: TaskItem) -> some View {
        TaskRowView(task: task) {
            Task { await taskViewModel.toggleComplete(task) }
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button(role: .destructive) {
                Task { await taskViewModel.deleteTask(task) }
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
        .swipeActions(edge: .leading, allowsFullSwipe: false) {
            if !task.isCompleted {
                Button {
                    editingTask = task
                } label: {
                    Label("Edit", systemImage: "pencil")
                }
                .tint(.orange)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            if !task.isCompleted {
                editingTask = task
            }
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 64))
                .foregroundStyle(.orange.opacity(0.5))

            Text("No tasks yet")
                .font(.title2.weight(.semibold))

            Text("Tap + to add your first task\nand start obliterating procrastination.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}
