import SwiftUI

// MARK: - Enums
enum AppTab { case profile, progress, match, qa }
enum UserRole { case learner, mentor }

// MARK: - Colors
struct AppColors {
    static let primary      = Color(hex: "#D4537E")
    static let primaryDark  = Color(hex: "#4B1528")
    static let primaryLight = Color(hex: "#FBEAF0")
    static let success      = Color(hex: "#1D9E75")
    static let successLight = Color(hex: "#E1F5EE")
    static let purple       = Color(hex: "#7F77DD")
    static let purpleLight  = Color(hex: "#EEEDFE")
    static let bg           = Color(hex: "#f9f9f9")
    static let textSecondary = Color(hex: "#666666")
    static let textTertiary  = Color(hex: "#999999")
    static let divider       = Color(hex: "#f0f0f0")
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r = Double((int >> 16) & 0xFF) / 255
        let g = Double((int >> 8)  & 0xFF) / 255
        let b = Double( int        & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }
}

// Models (fill these in as backend is ready)
struct UserProfile {
    var name: String = "Alex Johnson"
    var schoolType: String = "Public University"
    var graduationYear: Int = 2027
    var gender: String = "Female"
    var confidenceScore: Int = 475
    var maxScore: Int = 1000
}

struct QAPost {
    var authorInitials: String
    var authorName: String
    var timeAgo: String
    var question: String
    var likes: Int
    var replyCount: Int
    var mentorName: String?
    var mentorRole: String?
}

// Questionnaire answer- matches Python backend
struct QuestionnairePayload: Codable {
    var track: String        // "financial", "career", "academic"
    var goal: String
    var style: String
    var year: String
    // Add more fields as the questionnaire grows
}
