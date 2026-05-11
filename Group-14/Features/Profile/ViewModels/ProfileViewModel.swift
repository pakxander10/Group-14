//
//  ProfileViewModel.swift
//  Group-14 — Features/Profile/ViewModels
//
//  ⚠️ No SwiftUI import — pure Foundation + Models + service protocol only.
//

import Foundation
internal import Combine

// MARK: - ProfileServiceProtocol

protocol ProfileServiceProtocol {
    func fetchLearner(id: String) async throws -> LearnerProfile
    func fetchMentor(id: String) async throws -> MentorProfile
}

// MARK: - ProfileService (concrete)

final class ProfileService: ProfileServiceProtocol {
    private let network: NetworkManagerProtocol

    init(network: NetworkManagerProtocol = NetworkManager.shared) {
        self.network = network
    }

    func fetchLearner(id: String) async throws -> LearnerProfile {
        try await network.get("/profile/\(id)")
    }

    func fetchMentor(id: String) async throws -> MentorProfile {
        // For MVP the matched mentor is stored after questionnaire; reuse GET /mentors
        let mentors: [MentorProfile] = try await network.get("/mentors")
        guard let mentor = mentors.first(where: { $0.id == id }) else {
            throw NetworkError.unknown(URLError(.badServerResponse))
        }
        return mentor
    }
}

// MARK: - ProfileViewModel

@MainActor
final class ProfileViewModel: ObservableObject {
    // MARK: State
    @Published private(set) var learner: LearnerProfile?
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?

    // MARK: Dependencies (injected for testability)
    private let service: ProfileServiceProtocol

    init(service: ProfileServiceProtocol? = nil) {
        self.service = service ?? ProfileService()
    }

    // MARK: Intents

    func loadProfile(userId: String = "u1") {
        isLoading = true
        errorMessage = nil

        Task {
            defer { isLoading = false }
            do {
                learner = try await service.fetchLearner(id: userId)
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
}
