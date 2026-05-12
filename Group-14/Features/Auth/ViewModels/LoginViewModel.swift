//
//  LoginViewModel.swift
//  Group-14 — Features/Auth/ViewModels
//
//  ⚠️ No SwiftUI import. Foundation + Models + Service protocols only.
//
//  NOTE: The backend has no real authentication. "Log In" here just
//  verifies that a given user-id exists in the appropriate mock dict
//  (learners or mentors). For a demo / MVP this is sufficient; a real
//  auth layer would replace LoginService.
//

import Foundation
internal import Combine

// MARK: - UserRole helper

extension UserRole {
    var storageValue: String {
        switch self {
        case .learner: return "learner"
        case .mentor:  return "mentor"
        }
    }
}

// MARK: - LoginServiceProtocol

protocol LoginServiceProtocol {
    func verifyLearner(id: String) async throws -> LearnerProfile
    func verifyMentor(id: String) async throws -> MentorProfile
}

// MARK: - LoginService

final class LoginService: LoginServiceProtocol {
    private let network: NetworkManagerProtocol

    init(network: NetworkManagerProtocol = NetworkManager.shared) {
        self.network = network
    }

    func verifyLearner(id: String) async throws -> LearnerProfile {
        try await network.get("/profile/\(id)")
    }

    func verifyMentor(id: String) async throws -> MentorProfile {
        let mentors: [MentorProfile] = try await network.get("/mentors")
        guard let mentor = mentors.first(where: { $0.id == id }) else {
            throw NetworkError.serverError(404)
        }
        return mentor
    }
}

// MARK: - LoginViewModel

@MainActor
final class LoginViewModel: ObservableObject {

    enum State: Equatable {
        case editing
        case verifying
        case loggedIn(role: UserRole, id: String)
        case failed(String)
    }

    @Published var role: UserRole = .learner
    @Published var enteredId: String = ""
    @Published private(set) var state: State = .editing

    var canSubmit: Bool {
        !enteredId.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private let service: LoginServiceProtocol

    init(service: LoginServiceProtocol? = nil) {
        self.service = service ?? LoginService()
    }

    func submit() {
        guard canSubmit else { return }
        let trimmed = enteredId.trimmingCharacters(in: .whitespacesAndNewlines)
        state = .verifying

        Task {
            do {
                switch role {
                case .learner:
                    _ = try await service.verifyLearner(id: trimmed)
                case .mentor:
                    _ = try await service.verifyMentor(id: trimmed)
                }
                state = .loggedIn(role: role, id: trimmed)
            } catch {
                state = .failed("No \(role.storageValue) found with id '\(trimmed)'.")
            }
        }
    }

    func reset() {
        enteredId = ""
        state = .editing
    }
}
