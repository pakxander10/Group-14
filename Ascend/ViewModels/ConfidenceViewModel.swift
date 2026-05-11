import Foundation

@MainActor
final class ConfidenceViewModel: ObservableObject {
    @Published var score: Int = 500
    @Published var profile: LearnerProfile?
    @Published var errorMessage: String?

    let userId: String

    init(userId: String = "l1") {
        self.userId = userId
    }

    func load() async {
        do {
            let p: LearnerProfile = try await NetworkManager.shared.get("/profile/\(userId)")
            self.profile = p
            self.score = p.confidenceScore
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func save() async {
        do {
            let updated: LearnerProfile = try await NetworkManager.shared.put(
                "/confidence/\(userId)",
                body: ConfidenceUpdate(score: score)
            )
            self.profile = updated
            self.score = updated.confidenceScore
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
