import SwiftUI
import FirebaseAuth

struct SettingsView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var settingsViewModel = SettingsViewModel()
    @Environment(\.dismiss) private var dismiss
    @State private var showDeleteConfirmation = false

    private var userId: String {
        authViewModel.currentUser?.uid ?? ""
    }

    var body: some View {
        NavigationStack {
            Form {
                if let profile = settingsViewModel.profile {
                    Section("Quiet Hours") {
                        HStack {
                            Text("Start")
                            Spacer()
                            Picker("", selection: Binding(
                                get: { profile.quietHoursStart },
                                set: { settingsViewModel.profile?.quietHoursStart = $0 }
                            )) {
                                ForEach(0..<24, id: \.self) { hour in
                                    Text(formatHour(hour)).tag(hour)
                                }
                            }
                            .pickerStyle(.menu)
                        }

                        HStack {
                            Text("End")
                            Spacer()
                            Picker("", selection: Binding(
                                get: { profile.quietHoursEnd },
                                set: { settingsViewModel.profile?.quietHoursEnd = $0 }
                            )) {
                                ForEach(0..<24, id: \.self) { hour in
                                    Text(formatHour(hour)).tag(hour)
                                }
                            }
                            .pickerStyle(.menu)
                        }

                        Text("No reminders will be sent during quiet hours.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    Section {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Default Intensity")
                                Spacer()
                                Text("\(profile.defaultIntensity)")
                                    .foregroundStyle(.secondary)
                            }
                            Slider(value: Binding(
                                get: { Double(profile.defaultIntensity) },
                                set: { settingsViewModel.profile?.defaultIntensity = Int($0) }
                            ), in: 1...10, step: 1)
                        }
                    } header: {
                        Text("Defaults for New Tasks")
                    }

                    Section {
                        Toggle(isOn: Binding(
                            get: { profile.defaultReminderTypes.contains(.push) },
                            set: { enabled in
                                if enabled {
                                    if !(settingsViewModel.profile?.defaultReminderTypes.contains(.push) ?? false) {
                                        settingsViewModel.profile?.defaultReminderTypes.append(.push)
                                    }
                                } else {
                                    settingsViewModel.profile?.defaultReminderTypes.removeAll { $0 == .push }
                                }
                            }
                        )) {
                            Label("Push Notifications", systemImage: "bell.fill")
                        }

                        Toggle(isOn: Binding(
                            get: { profile.defaultReminderTypes.contains(.email) },
                            set: { enabled in
                                if enabled {
                                    if !(settingsViewModel.profile?.defaultReminderTypes.contains(.email) ?? false) {
                                        settingsViewModel.profile?.defaultReminderTypes.append(.email)
                                    }
                                } else {
                                    settingsViewModel.profile?.defaultReminderTypes.removeAll { $0 == .email }
                                }
                            }
                        )) {
                            Label("Email", systemImage: "envelope.fill")
                        }
                    } header: {
                        Text("Default Reminder Channels")
                    }

                    Section {
                        Text(authViewModel.currentUser?.email ?? "")
                            .foregroundStyle(.secondary)
                    } header: {
                        Text("Account")
                    }
                }

                Section {
                    Button("Sign Out") {
                        authViewModel.signOut()
                        dismiss()
                    }
                    .foregroundStyle(.red)

                    Button("Delete Account") {
                        showDeleteConfirmation = true
                    }
                    .foregroundStyle(.red)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        Task {
                            await settingsViewModel.saveProfile(userId: userId)
                            dismiss()
                        }
                    }
                    .fontWeight(.semibold)
                }
            }
            .onAppear {
                Task { await settingsViewModel.loadProfile(userId: userId) }
            }
            .alert("Delete Account", isPresented: $showDeleteConfirmation) {
                Button("Delete", role: .destructive) {
                    Task {
                        await authViewModel.deleteAccount()
                        dismiss()
                    }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This will permanently delete your account and all your tasks. This cannot be undone.")
            }
        }
    }

    private func formatHour(_ hour: Int) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h a"
        let date = Calendar.current.date(from: DateComponents(hour: hour)) ?? Date()
        return formatter.string(from: date)
    }
}
