import SwiftUI

struct TaskRowView: View {
    let task: TaskItem
    let onToggleComplete: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            // Completion checkbox
            Button(action: onToggleComplete) {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundStyle(task.isCompleted ? .green : .secondary)
            }
            .buttonStyle(.plain)

            // Task info
            VStack(alignment: .leading, spacing: 4) {
                Text(task.title)
                    .font(.body.weight(.medium))
                    .strikethrough(task.isCompleted)
                    .foregroundStyle(task.isCompleted ? .secondary : .primary)

                HStack(spacing: 8) {
                    // Deadline
                    Label(task.relativeDeadline, systemImage: "clock")
                        .font(.caption)
                        .foregroundStyle(deadlineColor)

                    // Reminder types
                    HStack(spacing: 2) {
                        ForEach(task.reminderTypes) { type in
                            Image(systemName: type.iconName)
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }

            Spacer()

            // Intensity indicator
            if !task.isCompleted {
                IntensityDots(intensity: task.intensity)
            }
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
    }

    private var deadlineColor: Color {
        if task.isCompleted { return .secondary }
        if task.isOverdue { return .red }

        let hours = task.timeRemaining / 3600
        if hours < 24 { return .red }
        if hours < 72 { return .orange }
        return .secondary
    }
}

struct IntensityDots: View {
    let intensity: Int

    var body: some View {
        HStack(spacing: 2) {
            ForEach(0..<5, id: \.self) { index in
                Circle()
                    .fill(index < (intensity + 1) / 2 ? Color.orange : Color.secondary.opacity(0.2))
                    .frame(width: 6, height: 6)
            }
        }
    }
}
