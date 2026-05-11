import Foundation

@MainActor
final class ProfileViewModel: ObservableObject {
    @Published var profile: LearnerProfile?
    @Published var isLoading = false
    @Published var errorMessage: String?

    let userId: String

    init(userId: String = "l1") {
        self.userId = userId
    }

    func load() async {
        isLoading = true
        defer { isLoading = false }
        do {
            profile = try await NetworkManager.shared.get("/profile/\(userId)")
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
