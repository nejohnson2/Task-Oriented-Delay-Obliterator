import Combine
import Foundation
import FirebaseAuth

enum AuthState {
    case loading
    case signedOut
    case signedIn
}

@MainActor
class AuthViewModel: ObservableObject {
    @Published var authState: AuthState = .loading
    @Published var currentUser: User?
    @Published var errorMessage: String?

    private var authStateListener: AuthStateDidChangeListenerHandle?

    init() {
        listenToAuthState()
    }

    deinit {
        if let listener = authStateListener {
            Auth.auth().removeStateDidChangeListener(listener)
        }
    }

    private func listenToAuthState() {
        authStateListener = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            Task { @MainActor in
                self?.currentUser = user
                self?.authState = user != nil ? .signedIn : .signedOut
            }
        }
    }

    func signIn(email: String, password: String) async {
        errorMessage = nil
        do {
            try await Auth.auth().signIn(withEmail: email, password: password)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func signUp(email: String, password: String) async {
        errorMessage = nil
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)

            // Create default user profile in Firestore
            let profile = UserProfile.defaultProfile(email: email)
            try await FirestoreService.shared.createUserProfile(profile, userId: result.user.uid)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func resetPassword(email: String) async {
        errorMessage = nil
        do {
            try await Auth.auth().sendPasswordReset(withEmail: email)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func signOut() {
        do {
            try Auth.auth().signOut()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func deleteAccount() async {
        guard let user = currentUser else { return }
        errorMessage = nil
        do {
            // Delete all user data from Firestore
            try await FirestoreService.shared.deleteAllUserData(userId: user.uid)
            // Delete the auth account
            try await user.delete()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
