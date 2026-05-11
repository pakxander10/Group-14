import Foundation

struct QuestionnaireAnswers: Codable {
    let learnerId: String
    let isFirstGen: Bool
    let interestTrack: String      // "Financial" | "Tech"
    let financialGoals: [String]
    let careerGoals: [String]
    let preferredExperienceYears: Int

    enum CodingKeys: String, CodingKey {
        case learnerId = "learner_id"
        case isFirstGen = "is_first_gen"
        case interestTrack = "interest_track"
        case financialGoals = "financial_goals"
        case careerGoals = "career_goals"
        case preferredExperienceYears = "preferred_experience_years"
    }
}

struct ConfidenceUpdate: Codable {
    let score: Int
}
