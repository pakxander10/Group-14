//
//  LearnerProfileCreationModels.swift
//  Group-14 — Features/LearnerProfileCreation/Models
//
//  Plain data (Foundation only). No SwiftUI, no ViewModel imports.
//

import Foundation

// MARK: - SchoolType

enum SchoolType: String, CaseIterable, Codable {
    case highSchool       = "High School"
    case communityCollege = "Community College"
    case fourYear         = "4-Year University"
    case graduate         = "Graduate School"
    case other            = "Other"

    var displayName: String { rawValue }
}

// MARK: - Gender

enum Gender: String, CaseIterable, Codable {
    case woman           = "Woman"
    case man             = "Man"
    case nonBinary       = "Non-Binary"
    case preferNotToSay  = "Prefer Not to Say"

    var displayName: String { rawValue }
}

// MARK: - CreateLearnerRequest

/// POST /learners request body.
/// Snake-case conversion is handled by `NetworkManager`'s encoder strategy.
struct CreateLearnerRequest: Encodable, Equatable {
    let name: String
    let profilePicture: Data?
    let typeOfSchool: String
    let graduationYear: Int
    let gender: String
    let occupationMajor: String
    let currentConfidenceScore: Int
}
