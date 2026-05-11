import Foundation

@MainActor
final class MentorThreadViewModel: ObservableObject {
    @Published var posts: [ThreadPost] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    func loadFeed() async {
        isLoading = true
        defer { isLoading = false }
        do {
            posts = try await NetworkManager.shared.get("/feed")
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
