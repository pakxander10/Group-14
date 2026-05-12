//
//  MentorMatchViewModel.swift
//  Group-14 — Features/MentorMatch/ViewModels
//

import Foundation
internal import Combine

// MARK: - Financial Match ViewModel

@MainActor
final class FinancialMatchViewModel: ObservableObject {

    // Screen 1 — Where You're Starting From
    @Published var selectedSituation: String = ""

    // Screen 2 — Biggest Financial Gap
    @Published var selectedFinancialGap: String = ""

    // Screen 3 — Accounts (multi-select)
    @Published var selectedAccounts: Set<String> = []

    // Screen 4 — Most Urgent Priority
    @Published var selectedUrgentPriority: String = ""

    // Screen 5 — First-Gen Status
    @Published var selectedFirstGen: String = ""

    // Screen 6 — Preferred Mentor Background
    @Published var selectedMentorBackground: String = ""

    // Screen 7 — Mentor Experience Preference
    @Published var selectedExperiencePreference: String = ""

    // Screen 8 — Communication Style
    @Published var selectedCommunicationStyle: String = ""

    // Screen 9 — Confidence Baseline (seeds confidence score)
    @Published var selectedConfidence: Int = 3

    @Published var currentStep: Int = 0
    @Published private(set) var matchedMentor: MentorProfile?
    @Published private(set) var isLoading = false
    @Published private(set) var isComplete = false

    let totalSteps = 9

    var canAdvance: Bool {
        switch currentStep {
        case 0: return !selectedSituation.isEmpty
        case 1: return !selectedFinancialGap.isEmpty
        case 2: return !selectedAccounts.isEmpty
        case 3: return !selectedUrgentPriority.isEmpty
        case 4: return !selectedFirstGen.isEmpty
        case 5: return !selectedMentorBackground.isEmpty
        case 6: return !selectedExperiencePreference.isEmpty
        case 7: return !selectedCommunicationStyle.isEmpty
        case 8: return true
        default: return true
        }
    }

    func toggleAccount(_ value: String) {
        if selectedAccounts.contains(value) {
            selectedAccounts.remove(value)
        } else {
            selectedAccounts.insert(value)
        }
    }

    func nextStep() {
        if currentStep < totalSteps - 1 { currentStep += 1 }
    }

    func previousStep() {
        if currentStep > 0 { currentStep -= 1 }
    }

    func submit() {
        isLoading = true
        Task {
            try? await Task.sleep(nanoseconds: 1_500_000_000)
            matchedMentor = financialMentorPool.first
            isLoading = false
            isComplete = true
        }
    }

    func reset() {
        selectedSituation = ""
        selectedFinancialGap = ""
        selectedAccounts = []
        selectedUrgentPriority = ""
        selectedFirstGen = ""
        selectedMentorBackground = ""
        selectedExperiencePreference = ""
        selectedCommunicationStyle = ""
        selectedConfidence = 3
        currentStep = 0
        matchedMentor = nil
        isLoading = false
        isComplete = false
    }
}

// MARK: - Career Match ViewModel

@MainActor
final class CareerMatchViewModel: ObservableObject {

    // Screen 1 — Where You Are in Your Career
    @Published var selectedCareerStage: String = ""

    // Screen 2 — Target Industry
    @Published var selectedTargetIndustry: String = ""

    // Screen 3 — Role Clarity
    @Published var selectedRoleClarity: String = ""

    // Screen 4 — Most Needed Support
    @Published var selectedNeededSupport: String = ""

    // Screen 5 — Education Background
    @Published var selectedEducationBackground: String = ""

    // Screen 6 — First-Generation Status
    @Published var selectedFirstGen: String = ""

    // Screen 7 — Company Type Preference
    @Published var selectedCompanyType: String = ""

    // Screen 8 — Mentor Career Path Preference
    @Published var selectedMentorCareerPath: String = ""

    // Screen 9 — Confidence Baseline (seeds confidence score)
    @Published var selectedConfidence: Int = 3

    @Published var currentStep: Int = 0
    @Published private(set) var matchedMentor: MentorProfile?
    @Published private(set) var isLoading = false
    @Published private(set) var isComplete = false

    let totalSteps = 9

    var canAdvance: Bool {
        switch currentStep {
        case 0: return !selectedCareerStage.isEmpty
        case 1: return !selectedTargetIndustry.isEmpty
        case 2: return !selectedRoleClarity.isEmpty
        case 3: return !selectedNeededSupport.isEmpty
        case 4: return !selectedEducationBackground.isEmpty
        case 5: return !selectedFirstGen.isEmpty
        case 6: return !selectedCompanyType.isEmpty
        case 7: return !selectedMentorCareerPath.isEmpty
        case 8: return true
        default: return true
        }
    }

    func nextStep() {
        if currentStep < totalSteps - 1 { currentStep += 1 }
    }

    func previousStep() {
        if currentStep > 0 { currentStep -= 1 }
    }

    func submit() {
        isLoading = true
        Task {
            try? await Task.sleep(nanoseconds: 1_500_000_000)
            matchedMentor = careerMentorPool.first
            isLoading = false
            isComplete = true
        }
    }

    func reset() {
        selectedCareerStage = ""
        selectedTargetIndustry = ""
        selectedRoleClarity = ""
        selectedNeededSupport = ""
        selectedEducationBackground = ""
        selectedFirstGen = ""
        selectedCompanyType = ""
        selectedMentorCareerPath = ""
        selectedConfidence = 3
        currentStep = 0
        matchedMentor = nil
        isLoading = false
        isComplete = false
    }
}
