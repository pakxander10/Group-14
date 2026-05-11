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

struct LearnerProfile: Codable, Identifiable {
    let id: String
    let name: String
    let age: Int
    let background: String      // "first_gen" | "general"
    let interest: String        // "financial" | "tech"
    let goal: String
    let confidenceScore: Int
}

// MARK: - MentorProfile

struct MentorProfile: Codable, Identifiable {
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
