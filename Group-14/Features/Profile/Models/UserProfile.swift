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
    let name: String
    let age: Int
    let background: String      // "first_gen" | "general"
    let interest: String        // "financial" | "tech"
    let goal: String
    let confidenceScore: Int

    // Optional onboarding fields — keep optional so existing GET /profile/{id}
    // responses (which do not include them) continue to decode.
    let profilePicture: Data?
    let typeOfSchool: String?
    let graduationYear: Int?
    let gender: String?
    let occupationMajor: String?
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
