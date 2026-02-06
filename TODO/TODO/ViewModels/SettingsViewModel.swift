import Combine
import Foundation

@MainActor
class SettingsViewModel: ObservableObject {
    @Published var profile: UserProfile?
    @Published var errorMessage: String?
    @Published var isLoading = false

    private let firestoreService = FirestoreService.shared

    func loadProfile(userId: String) async {
        isLoading = true
        do {
            profile = try await firestoreService.getUserProfile(userId: userId)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func saveProfile(userId: String) async {
        guard let profile = profile else { return }
        do {
            try await firestoreService.updateUserProfile(profile, userId: userId)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
