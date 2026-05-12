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
    func updateLearner(id: String, _ request: UpdateLearnerRequest) async throws -> LearnerProfile
    func updateMentor(id: String, _ request: UpdateMentorRequest) async throws -> MentorProfile
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

    func updateLearner(id: String, _ request: UpdateLearnerRequest) async throws -> LearnerProfile {
        try await network.put("/profile/\(id)", body: request)
    }

    func updateMentor(id: String, _ request: UpdateMentorRequest) async throws -> MentorProfile {
        try await network.put("/mentors/\(id)", body: request)
    }
}

// MARK: - ProfileViewModel

@MainActor
final class ProfileViewModel: ObservableObject {
    // MARK: State
    @Published private(set) var learner: LearnerProfile?
    @Published private(set) var mentor: MentorProfile?
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?

    // Editing drafts. While non-nil, the corresponding edit sheet is visible.
    @Published var editingLearner: LearnerProfile?
    @Published var editingMentor: MentorProfile?
    @Published private(set) var isSaving = false

    // MARK: Dependencies (injected for testability)
    private let service: ProfileServiceProtocol

    init(service: ProfileServiceProtocol? = nil) {
        self.service = service ?? ProfileService()
    }

    // MARK: Loading intents

    func loadLearner(userId: String) {
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

    func loadMentor(userId: String) {
        isLoading = true
        errorMessage = nil

        Task {
            defer { isLoading = false }
            do {
                mentor = try await service.fetchMentor(id: userId)
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }

    // MARK: Editing intents

    func beginEditLearner() {
        guard let learner else { return }
        errorMessage = nil
        editingLearner = learner
    }

    func beginEditMentor() {
        guard let mentor else { return }
        errorMessage = nil
        editingMentor = mentor
    }

    func cancelEdit() {
        editingLearner = nil
        editingMentor = nil
    }

    func saveLearnerEdit() {
        guard let draft = editingLearner else { return }
        isSaving = true
        errorMessage = nil

        let request = UpdateLearnerRequest(
            name: draft.name,
            interest: draft.interest,
            goal: draft.goal,
            occupationMajor: draft.occupationMajor
        )

        Task {
            defer { isSaving = false }
            do {
                let updated = try await service.updateLearner(id: draft.id, request)
                learner = updated
                editingLearner = nil
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }

    func saveMentorEdit() {
        guard let draft = editingMentor else { return }
        isSaving = true
        errorMessage = nil

        let request = UpdateMentorRequest(
            name: draft.name,
            title: draft.title,
            company: draft.company,
            track: draft.track,
            bio: draft.bio,
            expertise: draft.expertise,
            yearsExperience: draft.yearsExperience,
            avatarInitials: draft.avatarInitials,
            email: draft.email,
            linkedInUrl: draft.linkedInUrl,
            educationHistory: draft.educationHistory
        )

        Task {
            defer { isSaving = false }
            do {
                let updated = try await service.updateMentor(id: draft.id, request)
                mentor = updated
                editingMentor = nil
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
}
