//
//  UserProfile.swift
//  Group-14 — Features/Profile/Models
//
//  Shared domain models used across features.
//  Foundation only — no SwiftUI, no ViewModels.
//

import Foundation

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

// MARK: - QuestionnaireRequest (shared POST body)

struct QuestionnaireRequest: Codable {
    let age: Int
    let background: String
    let interest: String
    let goal: String
}
