//
//  LearnerOnboardingViewModel.swift
//  Group-14 — Features/LearnerOnboarding/ViewModels
//
//  ⚠️ No SwiftUI import — pure Foundation + Combine + Models + service protocol.
//  This is what your ATDD tests target.
//

import Foundation
import Combine

// MARK: - LearnerOnboardingServiceProtocol

protocol LearnerOnboardingServiceProtocol {
    func submitLearner(_ data: LearnerOnboardingData) async throws -> MentorProfile
}

// MARK: - LearnerOnboardingService (concrete)

final class LearnerOnboardingService: LearnerOnboardingServiceProtocol {
    private let network: NetworkManagerProtocol

    /// Production init — uses the shared NetworkManager
    init() {
        self.network = NetworkManager.shared
    }

    /// Test init — inject any NetworkManagerProtocol mock
    init(network: NetworkManagerProtocol) {
        self.network = network
    }

    func submitLearner(_ data: LearnerOnboardingData) async throws -> MentorProfile {
        let request = QuestionnaireRequest(
            age: data.approximateAge,
            background: data.backgroundValue,
            interest: data.track.rawValue,
            goal: data.intent.rawValue
        )
        return try await network.post("/questionnaire", body: request)
    }
}

// MARK: - LearnerOnboardingViewModel

@MainActor
final class LearnerOnboardingViewModel: ObservableObject {

    // MARK: Form State
    @Published var data = LearnerOnboardingData()
    @Published private(set) var currentStep: Int = 0

    // MARK: Result State
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var errorMessage: String?
    @Published private(set) var matchedMentor: MentorProfile?
    @Published private(set) var isComplete: Bool = false

    // MARK: Step Configuration
    // Step indices:
    //  0 — Name
    //  1 — Track selection (Financial / Tech)
    //  2 — Demographics (First-gen + Gender)
    //  3 — School / Career (Type + Grad Year + Major)
    //  4 — Intent ("What brought you here?")
    //  5 — Baseline Confidence (slider 1–10)
    //  6 — Financial Accounts (only if financial track)

    var totalSteps: Int {
        data.track == .financial ? 7 : 6   // financial gets extra accounts step
    }

    var canAdvance: Bool {
        switch currentStep {
        case 0: return !data.name.trimmingCharacters(in: .whitespaces).isEmpty
        case 1: return true   // track has a default
        case 2: return data.isFirstGen != nil  // must explicitly pick first-gen answer
        case 3: return !data.majorOrOccupation.trimmingCharacters(in: .whitespaces).isEmpty
        case 4: return true   // intent has a default
        case 5: return true   // slider always has a value
        case 6: return true   // financial accounts can be empty (none selected = starting from scratch)
        default: return false
        }
    }

    var progressFraction: Double {
        Double(currentStep + 1) / Double(totalSteps)
    }

    // MARK: Dependencies
    private let service: LearnerOnboardingServiceProtocol

    init(service: LearnerOnboardingServiceProtocol = LearnerOnboardingService()) {
        self.service = service
    }

    // MARK: Intents

    func nextStep() {
        guard canAdvance else { return }
        if currentStep < totalSteps - 1 {
            currentStep += 1
        }
    }

    func previousStep() {
        if currentStep > 0 { currentStep -= 1 }
    }

    func submit() {
        isLoading = true
        errorMessage = nil

        Task {
            defer { isLoading = false }
            do {
                matchedMentor = try await service.submitLearner(data)
                isComplete = true
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }

    func reset() {
        data = LearnerOnboardingData()
        currentStep = 0
        matchedMentor = nil
        isComplete = false
        errorMessage = nil
    }

    // MARK: Helpers for financial accounts multi-select

    func toggleAccount(_ account: FinancialAccount) {
        if data.financialAccounts.contains(account) {
            data.financialAccounts.remove(account)
        } else {
            // If user picks "none", clear others; if picking something else, remove "none"
            if account == .none {
                data.financialAccounts = [.none]
            } else {
                data.financialAccounts.remove(.none)
                data.financialAccounts.insert(account)
            }
        }
    }
}
