import Foundation

struct LearnerProfile: Codable, Identifiable, Hashable {
    let id: String
    let name: String
    let email: String
    let isFirstGen: Bool
    let interests: [String]
    let confidenceScore: Int
    let track: String?

    enum CodingKeys: String, CodingKey {
        case id, name, email, interests, track
        case isFirstGen = "is_first_gen"
        case confidenceScore = "confidence_score"
    }
}
