//
//  LearnerProfileCreationViewModel.swift
//  Group-14 — Features/LearnerProfileCreation/ViewModels
//
//  ⚠️ No SwiftUI import — Foundation + Models + Service protocol only.
//

import Foundation
internal import Combine

// MARK: - LearnerProfileServiceProtocol

protocol LearnerProfileServiceProtocol {
    func create(_ request: CreateLearnerRequest) async throws -> LearnerProfile
}

// MARK: - LearnerProfileService (concrete)

final class LearnerProfileService: LearnerProfileServiceProtocol {
    private let network: NetworkManagerProtocol

    init(network: NetworkManagerProtocol = NetworkManager.shared) {
        self.network = network
    }

    func create(_ request: CreateLearnerRequest) async throws -> LearnerProfile {
        try await network.post("/learners", body: request)
    }
}

// MARK: - LearnerProfileCreationViewModel

@MainActor
final class LearnerProfileCreationViewModel: ObservableObject {

    // MARK: State machine

    enum State: Equatable {
        case editing
        case submitting
        case created(LearnerProfile)
        case failed(String)
    }

    // MARK: Form fields

    @Published var name: String = ""
    @Published var profilePicture: Data?
    @Published var typeOfSchool: String = ""
    @Published var graduationYear: Int = Calendar.current.component(.year, from: Date())
    @Published var gender: String = ""
    @Published var occupationMajor: String = ""
    @Published var currentConfidenceScore: Int = 100

    @Published private(set) var state: State = .editing

    // MARK: Derived

    var canSubmit: Bool {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedOccupation = occupationMajor.trimmingCharacters(in: .whitespacesAndNewlines)
        return !trimmedName.isEmpty
            && !typeOfSchool.isEmpty
            && !gender.isEmpty
            && !trimmedOccupation.isEmpty
            && (1...1000).contains(currentConfidenceScore)
    }

    // MARK: Dependencies

    private let service: LearnerProfileServiceProtocol

    init(service: LearnerProfileServiceProtocol? = nil) {
        self.service = service ?? LearnerProfileService()
    }

    // MARK: Intents

    func submit() {
        guard canSubmit else { return }
        state = .submitting

        let request = CreateLearnerRequest(
            name: name.trimmingCharacters(in: .whitespacesAndNewlines),
            profilePicture: profilePicture,
            typeOfSchool: typeOfSchool,
            graduationYear: graduationYear,
            gender: gender,
            occupationMajor: occupationMajor.trimmingCharacters(in: .whitespacesAndNewlines),
            currentConfidenceScore: currentConfidenceScore
        )

        Task {
            do {
                let created = try await service.create(request)
                state = .created(created)
            } catch {
                state = .failed(error.localizedDescription)
            }
        }
    }

    func reset() {
        name = ""
        profilePicture = nil
        typeOfSchool = ""
        graduationYear = Calendar.current.component(.year, from: Date())
        gender = ""
        occupationMajor = ""
        currentConfidenceScore = 100
        state = .editing
    }
}
