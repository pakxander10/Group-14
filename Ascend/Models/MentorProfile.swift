import Foundation

struct MentorProfile: Codable, Identifiable, Hashable {
    let id: String
    let name: String
    let title: String
    let company: String
    let track: String          // "Financial" | "Tech"
    let yearsExperience: Int
    let bio: String
    let specialties: [String]

    enum CodingKeys: String, CodingKey {
        case id, name, title, company, track, bio, specialties
        case yearsExperience = "years_experience"
    }
}
