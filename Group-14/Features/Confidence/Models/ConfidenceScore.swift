//
//  ConfidenceScore.swift
//  Group-14 — Features/Confidence/Models
//
//  Plain data + pure computation (Foundation only).
//  The Confidence Score is a 0–1000 readiness measure scoped to the
//  **Financial track only**; Tech-track learners are outside this ladder.
//

import Foundation

// MARK: - ConfidenceTier

/// The five Financial Readiness tiers. Each tier carries a real-world prompt
/// that names the concrete next step the learner is "ready to do."
enum ConfidenceTier: Int, CaseIterable, Codable {
    case foundation   // 0…249
    case safetyNet    // 250…499
    case strategist   // 500…749
    case investor     // 750…999
    case ascended     // 1000

    var displayName: String {
        switch self {
        case .foundation: return "The Foundation"
        case .safetyNet:  return "The Safety Net"
        case .strategist: return "The Strategist"
        case .investor:   return "The Investor"
        case .ascended:   return "Ascended"
        }
    }

    var readinessPrompt: String {
        switch self {
        case .foundation: return "Ready to set up a basic budget."
        case .safetyNet:  return "Ready to open a High-Yield Savings Account (HYSA)."
        case .strategist: return "Ready to review employer benefits like 401(k) matches."
        case .investor:   return "Ready to open a brokerage account."
        case .ascended:   return "Graduation! You have mastered the basics."
        }
    }

    var range: ClosedRange<Int> {
        switch self {
        case .foundation: return 0...249
        case .safetyNet:  return 250...499
        case .strategist: return 500...749
        case .investor:   return 750...999
        case .ascended:   return 1000...1000
        }
    }

    /// Lowest score that enters this tier — used for "next milestone" UI math.
    var threshold: Int { range.lowerBound }

    static func tier(for score: Int) -> ConfidenceTier {
        let clamped = max(0, min(1000, score))
        return ConfidenceTier.allCases.first { $0.range.contains(clamped) } ?? .foundation
    }
}

// MARK: - ConfidenceScore

struct ConfidenceScore: Codable, Equatable {
    let userId: String
    let score: Int              // 0–1000

    var tier: ConfidenceTier { ConfidenceTier.tier(for: score) }

    var normalizedFraction: Double {
        Double(max(0, min(1000, score))) / 1000.0
    }
}
