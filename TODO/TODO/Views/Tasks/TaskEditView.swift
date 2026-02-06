import SwiftUI

struct TaskEditView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var task: TaskItem
    let isNew: Bool
    let onSave: (TaskItem) -> Void

    @State private var title: String = ""
    @State private var details: String = ""
    @State private var deadline: Date = Date()
    @State private var intensity: Double = 5
    @State private var pushEnabled: Bool = true
    @State private var emailEnabled: Bool = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Task") {
                    TextField("What needs to get done?", text: $title)

                    ZStack(alignment: .topLeading) {
                        if details.isEmpty {
                            Text("Details (optional)")
                                .foregroundStyle(.tertiary)
                                .padding(.top, 8)
                        }
                        TextEditor(text: $details)
                            .frame(minHeight: 80)
                    }
                }

                Section("Deadline") {
                    DatePicker("Due", selection: $deadline, in: Date()..., displayedComponents: [.date, .hourAndMinute])
                }

                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Intensity")
                            Spacer()
                            Text(intensityLabel)
                                .foregroundStyle(.secondary)
                                .font(.subheadline)
                        }

                        Slider(value: $intensity, in: 1...10, step: 1)
                            .tint(intensityColor)

                        Text("Controls how aggressively you'll be reminded as the deadline approaches.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                } header: {
                    Text("Reminder Intensity")
                }

                Section("Reminder Channels") {
                    Toggle(isOn: $pushEnabled) {
                        Label("Push Notifications", systemImage: "bell.fill")
                    }

                    Toggle(isOn: $emailEnabled) {
                        Label("Email", systemImage: "envelope.fill")
                    }
                }
            }
            .navigationTitle(isNew ? "New Task" : "Edit Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveTask()
                    }
                    .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
                    .fontWeight(.semibold)
                }
            }
            .onAppear {
                title = task.title
                details = task.details
                deadline = task.deadline
                intensity = Double(task.intensity)
                pushEnabled = task.reminderTypes.contains(.push)
                emailEnabled = task.reminderTypes.contains(.email)
            }
        }
    }

    private var intensityLabel: String {
        let level = Int(intensity)
        switch level {
        case 1...2: return "Gentle (\(level))"
        case 3...4: return "Moderate (\(level))"
        case 5...6: return "Firm (\(level))"
        case 7...8: return "Aggressive (\(level))"
        case 9...10: return "Relentless (\(level))"
        default: return "\(level)"
        }
    }

    private var intensityColor: Color {
        let level = Int(intensity)
        switch level {
        case 1...3: return .green
        case 4...6: return .orange
        case 7...10: return .red
        default: return .orange
        }
    }

    private func saveTask() {
        var updated = task
        updated.title = title.trimmingCharacters(in: .whitespaces)
        updated.details = details.trimmingCharacters(in: .whitespaces)
        updated.deadline = deadline
        updated.intensity = Int(intensity)

        var types: [ReminderType] = []
        if pushEnabled { types.append(.push) }
        if emailEnabled { types.append(.email) }
        if types.isEmpty { types.append(.push) } // at least one required
        updated.reminderTypes = types

        onSave(updated)
        dismiss()
    }
}
