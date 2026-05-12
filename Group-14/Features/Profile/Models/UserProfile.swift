//
//  UserProfile.swift
//  Group-14 — Features/Profile/Models
//
//  Plain data structs (Foundation only) — no SwiftUI, no ViewModels.
//

import Foundation

// MARK: - UserRole

enum UserRole: String, Codable {
    case learner
    case mentor
}

// MARK: - LearnerProfile

struct LearnerProfile: Codable, Identifiable, Equatable {
    let id: String
    var name: String
    let age: Int
    let background: String      // "first_gen" | "general"
    var interest: String        // "financial" | "tech"
    var goal: String
    let confidenceScore: Int

    // Optional onboarding fields — keep optional so existing GET /profile/{id}
    // responses (which do not include them) continue to decode.
    var profilePicture: Data?
    var typeOfSchool: String?
    var graduationYear: Int?
    var gender: String?
    var occupationMajor: String?
}

// MARK: - MentorProfile

struct MentorProfile: Codable, Identifiable, Equatable {
    var id: String
    var name: String
    var title: String
    var company: String
    var track: String           // "Financial" | "Tech"
    var bio: String
    var expertise: [String]
    var yearsExperience: Int
    var avatarInitials: String
    var email: String?
    var linkedInUrl: String?
    var educationHistory: [String]?
    var profilePicture: Data?
}

// MARK: - Update requests (PUT bodies)

struct UpdateLearnerRequest: Encodable, Equatable {
    let name: String
    let interest: String
    let goal: String
    let occupationMajor: String?
}

struct UpdateMentorRequest: Encodable, Equatable {
    let name: String
    let title: String
    let company: String
    let track: String
    let bio: String
    let expertise: [String]
    let yearsExperience: Int
    let avatarInitials: String
    let email: String?
    let linkedInUrl: String?
    let educationHistory: [String]?
}
