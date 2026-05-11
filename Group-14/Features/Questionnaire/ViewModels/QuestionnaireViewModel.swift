//
//  QuestionnaireViewModel.swift
//  Group-14 — Features/Questionnaire/ViewModels
//
//  ⚠️ No SwiftUI import.
//

import Foundation
internal import Combine

// MARK: - QuestionnaireServiceProtocol

protocol QuestionnaireServiceProtocol {
    func submitQuestionnaire(_ request: QuestionnaireRequest) async throws -> MentorProfile
}

// MARK: - QuestionnaireService

final class QuestionnaireService: QuestionnaireServiceProtocol {
    private let network: NetworkManagerProtocol

    init(network: NetworkManagerProtocol = NetworkManager.shared) {
        self.network = network
    }

    func submitQuestionnaire(_ request: QuestionnaireRequest) async throws -> MentorProfile {
        try await network.post("/questionnaire", body: request)
    }
}

// MARK: - QuestionnaireViewModel

@MainActor
final class QuestionnaireViewModel: ObservableObject {
    // MARK: Form State
    @Published var selectedAge: Int = 20
    @Published var selectedBackground: String = ""
    @Published var selectedInterest: String = ""
    @Published var selectedGoal: String = ""
    @Published var currentStep: Int = 0

    // MARK: Result State
    @Published private(set) var matchedMentor: MentorProfile?
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?
    @Published private(set) var isComplete = false

    // MARK: Static option data

    let backgroundOptions: [QuestionnaireOption] = [
        .init(label: "First-Generation Student", value: "first_gen", emoji: "🌱"),
        .init(label: "General / Other",           value: "general",   emoji: "🎓"),
    ]

    let interestOptions: [QuestionnaireOption] = [
        .init(label: "Financial Guidance", value: "financial", emoji: "💰"),
        .init(label: "Tech & Career",      value: "tech",       emoji: "💻"),
    ]

    let goalOptions: [QuestionnaireOption] = [
        .init(label: "Start Investing",   value: "investing",      emoji: "📈"),
        .init(label: "Budgeting Basics",  value: "budgeting",      emoji: "🗂️"),
        .init(label: "Career Growth",     value: "career",         emoji: "🚀"),
        .init(label: "Learn to Code",     value: "coding",         emoji: "👩‍💻"),
        .init(label: "Interview Prep",    value: "interview_prep", emoji: "🎤"),
    ]

    var totalSteps: Int { 4 }

    var canSubmit: Bool {
        !selectedBackground.isEmpty && !selectedInterest.isEmpty && !selectedGoal.isEmpty
    }

    // MARK: Dependencies
    private let service: QuestionnaireServiceProtocol

    init(service: QuestionnaireServiceProtocol = QuestionnaireService()) {
        self.service = service
    }

    // MARK: Intents

    func nextStep() {
        if currentStep < totalSteps - 1 {
            currentStep += 1
        }
    }

    func previousStep() {
        if currentStep > 0 {
            currentStep -= 1
        }
    }

    func submit() {
        guard canSubmit else { return }
        isLoading = true
        errorMessage = nil

        let request = QuestionnaireRequest(
            age: selectedAge,
            background: selectedBackground,
            interest: selectedInterest,
            goal: selectedGoal
        )

        Task {
            defer { isLoading = false }
            do {
                matchedMentor = try await service.submitQuestionnaire(request)
                isComplete = true
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }

    func reset() {
        selectedBackground = ""
        selectedInterest = ""
        selectedGoal = ""
        selectedAge = 20
        currentStep = 0
        matchedMentor = nil
        isComplete = false
        errorMessage = nil
    }
}
