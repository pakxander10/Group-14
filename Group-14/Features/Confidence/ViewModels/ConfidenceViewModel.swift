//
//  ConfidenceViewModel.swift
//  Group-14 — Features/Confidence/ViewModels
//
//  ⚠️ No SwiftUI import.
//

import Foundation

// MARK: - ConfidenceServiceProtocol

protocol ConfidenceServiceProtocol {
    func updateScore(userId: String, delta: Int) async throws -> LearnerProfile
}

// MARK: - ConfidenceService

final class ConfidenceService: ConfidenceServiceProtocol {
    private let network: NetworkManagerProtocol

    init(network: NetworkManagerProtocol = NetworkManager.shared) {
        self.network = network
    }

    func updateScore(userId: String, delta: Int) async throws -> LearnerProfile {
        let body = ConfidenceUpdateRequest(delta: delta)
        return try await network.put("/confidence/\(userId)", body: body)
    }
}

// MARK: - ConfidenceViewModel

@MainActor
final class ConfidenceViewModel: ObservableObject {
    // MARK: State
    @Published private(set) var score: Int = 340
    @Published private(set) var tier: String = "Growing"
    @Published private(set) var isUpdating = false
    @Published private(set) var errorMessage: String?

    // Animated display value (drives the ring animation)
    @Published var displayScore: Int = 0

    private let service: ConfidenceServiceProtocol
    let userId: String

    init(userId: String = "u1", service: ConfidenceServiceProtocol = ConfidenceService()) {
        self.userId = userId
        self.service = service
    }

    // MARK: Computed

    var normalizedFraction: Double { Double(score) / 1000.0 }

    // MARK: Intents

    /// Call on view appear to animate in the score
    func animateScore() {
        displayScore = score
    }

    func boost(delta: Int = 50) {
        applyDelta(delta)
    }

    // MARK: Private

    private func applyDelta(_ delta: Int) {
        isUpdating = true
        errorMessage = nil

        Task {
            defer { isUpdating = false }
            do {
                let updated = try await service.updateScore(userId: userId, delta: delta)
                score = updated.confidenceScore
                tier = ConfidenceScore(userId: userId, score: updated.confidenceScore).tier
                displayScore = score
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
}
