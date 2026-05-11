//
//  ConfidenceScore.swift
//  Group-14 — Features/Confidence/Models
//

import Foundation

// MARK: - ConfidenceScore

struct ConfidenceScore: Codable {
    let userId: String
    let score: Int              // 1–1000

    // MARK: Display helpers (pure computation, no SwiftUI)

    var tier: String {
        switch score {
        case 1..<200:    return "Emerging"
        case 200..<400:  return "Growing"
        case 400..<600:  return "Developing"
        case 600..<800:  return "Confident"
        default:         return "Ascended"
        }
    }

    var normalizedFraction: Double {
        Double(score) / 1000.0
    }
}

// MARK: - ConfidenceUpdateRequest

struct ConfidenceUpdateRequest: Codable {
    let delta: Int
}
