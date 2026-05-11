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
    let id: String
    let name: String
    let title: String
    let company: String
    let track: String           // "Financial" | "Tech"
    let bio: String
    let expertise: [String]
    let yearsExperience: Int
    let avatarInitials: String
}
