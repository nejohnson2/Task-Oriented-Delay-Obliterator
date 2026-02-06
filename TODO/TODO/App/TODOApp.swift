import SwiftUI
import FirebaseAuth

@main
struct TODOApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var authViewModel = AuthViewModel()

    var body: some Scene {
        WindowGroup {
            Group {
                switch authViewModel.authState {
                case .loading:
                    ProgressView("Loading...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                case .signedOut:
                    LoginView()
                case .signedIn:
                    TaskListView()
                        .onAppear {
                            requestNotifications()
                            storeFCMToken()
                        }
                }
            }
            .environmentObject(authViewModel)
            .tint(.orange)
        }
    }

    private func requestNotifications() {
        Task {
            let granted = await NotificationService.shared.requestPermission()
            if granted {
                print("Notification permission granted")
            }
        }
    }

    private func storeFCMToken() {
        guard let userId = Auth.auth().currentUser?.uid,
              let token = NotificationService.shared.fcmToken else { return }
        Task {
            try? await FirestoreService.shared.updateFCMToken(token, userId: userId)
        }
    }
}
