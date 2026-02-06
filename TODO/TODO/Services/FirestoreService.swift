import Foundation
import FirebaseFirestore
import FirebaseAuth

class FirestoreService {
    static let shared = FirestoreService()
    private let db = Firestore.firestore()

    private init() {}

    // MARK: - User Profile

    func createUserProfile(_ profile: UserProfile, userId: String) async throws {
        try db.collection("users").document(userId).collection("profile").document("settings").setData(from: profile)
    }

    func getUserProfile(userId: String) async throws -> UserProfile? {
        let doc = try await db.collection("users").document(userId).collection("profile").document("settings").getDocument()
        return try? doc.data(as: UserProfile.self)
    }

    func updateUserProfile(_ profile: UserProfile, userId: String) async throws {
        try db.collection("users").document(userId).collection("profile").document("settings").setData(from: profile, merge: true)
    }

    func updateFCMToken(_ token: String, userId: String) async throws {
        try await db.collection("users").document(userId).collection("profile").document("settings").updateData([
            "fcmToken": token
        ])
    }

    // MARK: - Tasks

    private func tasksCollection(userId: String) -> CollectionReference {
        db.collection("users").document(userId).collection("tasks")
    }

    func addTask(_ task: TaskItem) async throws -> String {
        let ref = try tasksCollection(userId: task.userId).addDocument(from: task)
        return ref.documentID
    }

    func updateTask(_ task: TaskItem) async throws {
        guard let id = task.id else { return }
        try tasksCollection(userId: task.userId).document(id).setData(from: task)
    }

    func deleteTask(_ task: TaskItem) async throws {
        guard let id = task.id else { return }
        try await tasksCollection(userId: task.userId).document(id).delete()
    }

    func listenToTasks(userId: String, completion: @escaping (Result<[TaskItem], Error>) -> Void) -> ListenerRegistration {
        tasksCollection(userId: userId)
            .order(by: "deadline", descending: false)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }

                guard let documents = snapshot?.documents else {
                    completion(.success([]))
                    return
                }

                let tasks = documents.compactMap { doc -> TaskItem? in
                    do {
                        return try doc.data(as: TaskItem.self)
                    } catch {
                        print("Failed to decode task \(doc.documentID): \(error)")
                        return nil
                    }
                }
                completion(.success(tasks))
            }
    }

    // MARK: - Account Deletion

    func deleteAllUserData(userId: String) async throws {
        let taskDocs = try await tasksCollection(userId: userId).getDocuments()
        for doc in taskDocs.documents {
            try await doc.reference.delete()
        }

        try await db.collection("users").document(userId).collection("profile").document("settings").delete()
        try await db.collection("users").document(userId).delete()
    }
}
