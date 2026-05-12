//
//  MentorOnboardingModels.swift
//  Group-14 — Features/MentorOnboarding/Models
//
//  Plain data (Foundation only). No SwiftUI, no ViewModel imports.
//

import Foundation

// MARK: - MentorTrack

enum MentorTrack: String, CaseIterable, Codable {
    case financial = "Financial"
    case tech      = "Tech"

    var displayName: String { rawValue }
}

// MARK: - CreateMentorRequest

/// POST /mentors request body.
/// Snake-case conversion is handled by `NetworkManager`'s encoder strategy.
struct CreateMentorRequest: Encodable, Equatable {
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
    let profilePicture: Data?
}
