//
//  ConfidenceViewModel.swift
//  Group-14 — Features/Confidence/ViewModels
//
//  Owns the learner's Confidence Score state for the dashboard.
//  The score and the Readiness Ladder are **Finance-track exclusive** —
//  the VM exposes `isEligibleForScoring` so the dashboard can render an
//  "ineligible" state for Tech-track learners without view-level branching
//  on raw strings.
//
//  ⚠️ Foundation only. No SwiftUI imports.
//

import Foundation
internal import Combine

// MARK: - ConfidenceServiceProtocol

protocol ConfidenceServiceProtocol {
    func fetchLearner(id: String) async throws -> LearnerProfile
}

// MARK: - ConfidenceService (concrete)

final class ConfidenceService: ConfidenceServiceProtocol {
    private let network: NetworkManagerProtocol

    init(network: NetworkManagerProtocol = NetworkManager.shared) {
        self.network = network
    }

    func fetchLearner(id: String) async throws -> LearnerProfile {
        try await network.get("/profile/\(id)")
    }
}

// MARK: - ConfidenceViewModel

@MainActor
final class ConfidenceViewModel: ObservableObject {

    // MARK: State
    @Published private(set) var score: Int = 0
    @Published private(set) var interest: String = ""        // "financial" | "tech"
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?

    /// Drives the ring's animated reveal. View sets this via `animateScore()`
    /// after a brief delay so the trim animates from 0 → score on appear.
    @Published var displayScore: Int = 0

    // MARK: Dependencies
    private let service: ConfidenceServiceProtocol

    init(service: ConfidenceServiceProtocol? = nil) {
        self.service = service ?? ConfidenceService()
    }

    // MARK: Computed

    var tier: ConfidenceTier { ConfidenceTier.tier(for: score) }

    var normalizedFraction: Double {
        Double(max(0, min(1000, score))) / 1000.0
    }

    /// True only for Financial-track learners — the score and tiers are exclusive
    /// to the Financial track. Tech learners see an "ineligible" dashboard.
    var isEligibleForScoring: Bool {
        interest.lowercased() == "financial"
    }

    // MARK: Intents

    /// Fetch the learner's profile to populate score + interest.
    /// Safe to call from `.task(id:)` and `.refreshable`.
    func load(userId: String) {
        guard !userId.isEmpty else { return }
        isLoading = true
        errorMessage = nil

        Task {
            defer { isLoading = false }
            do {
                let learner = try await service.fetchLearner(id: userId)
                score = max(0, min(1000, learner.confidenceScore))
                interest = learner.interest
                displayScore = score
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }

    /// View calls this after a small delay on appear so the ring trim animates
    /// from 0 → score. Distinct from `load()` to keep network + animation
    /// concerns separate.
    func animateScore() {
        displayScore = score
    }
}
