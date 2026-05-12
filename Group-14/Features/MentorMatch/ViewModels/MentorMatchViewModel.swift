//
//  MentorMatchViewModel.swift
//  Group-14 — Features/MentorMatch/ViewModels
//

import Foundation
internal import Combine

// MARK: - Financial Match ViewModel

@MainActor
final class FinancialMatchViewModel: ObservableObject {

    // Step 0 — Intent
    @Published var selectedIntent: String = ""

    // Step 1 — Who You Are
    @Published var selectedGender: String = ""
    @Published var selectedYear: String = ""
    @Published var selectedMajor: String = ""
    @Published var selectedSchoolType: String = ""

    // Step 2 — First-Gen Status
    @Published var selectedFirstGen: String = ""

    // Step 3 — Financial Standing
    @Published var selectedFinancialStanding: String = ""

    // Step 4 — Confidence
    @Published var selectedConfidence: Int = 3

    // Step 5 — Financial Accounts + Concern
    @Published var selectedFinancialAccounts: Set<String> = []
    @Published var selectedFinancialConcern: String = ""

    // Step 6 — Mentor Preferences
    @Published var selectedMentorPreferences: Set<String> = []
    @Published var selectedSupportStyle: String = ""

    @Published var currentStep: Int = 0
    @Published private(set) var matchedMentor: MentorProfile?
    @Published private(set) var isLoading = false
    @Published private(set) var isComplete = false

    let totalSteps = 7

    var canAdvance: Bool {
        switch currentStep {
        case 0: return !selectedIntent.isEmpty
        case 1: return !selectedGender.isEmpty && !selectedYear.isEmpty && !selectedSchoolType.isEmpty
        case 2: return !selectedFirstGen.isEmpty
        case 3: return !selectedFinancialStanding.isEmpty
        case 4: return true
        case 5: return !selectedFinancialConcern.isEmpty
        case 6: return !selectedMentorPreferences.isEmpty && !selectedSupportStyle.isEmpty
        default: return true
        }
    }

    func toggleFinancialAccount(_ value: String) {
        if selectedFinancialAccounts.contains(value) {
            selectedFinancialAccounts.remove(value)
        } else {
            selectedFinancialAccounts.insert(value)
        }
    }

    func toggleMentorPreference(_ value: String) {
        if selectedMentorPreferences.contains(value) {
            selectedMentorPreferences.remove(value)
        } else if selectedMentorPreferences.count < 2 {
            selectedMentorPreferences.insert(value)
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
        selectedIntent = ""
        selectedGender = ""
        selectedYear = ""
        selectedMajor = ""
        selectedSchoolType = ""
        selectedFirstGen = ""
        selectedFinancialStanding = ""
        selectedConfidence = 3
        selectedFinancialAccounts = []
        selectedFinancialConcern = ""
        selectedMentorPreferences = []
        selectedSupportStyle = ""
        currentStep = 0
        matchedMentor = nil
        isLoading = false
        isComplete = false
    }
}

// MARK: - Career Match ViewModel

@MainActor
final class CareerMatchViewModel: ObservableObject {

    // Step 0 — Intent
    @Published var selectedIntent: String = ""

    // Step 1 — Who You Are
    @Published var selectedGender: String = ""
    @Published var selectedYear: String = ""
    @Published var selectedMajor: String = ""
    @Published var selectedSchoolType: String = ""

    // Step 2 — First-Gen Status
    @Published var selectedFirstGen: String = ""

    // Step 3 — Career Stage + Support
    @Published var selectedCareerStage: String = ""
    @Published var selectedCareerSupport: String = ""

    // Step 4 — Confidence
    @Published var selectedConfidence: Int = 3

    // Step 5 — Mentor Preferences
    @Published var selectedMentorPreferences: Set<String> = []
    @Published var selectedSupportStyle: String = ""

    @Published var currentStep: Int = 0
    @Published private(set) var matchedMentor: MentorProfile?
    @Published private(set) var isLoading = false
    @Published private(set) var isComplete = false

    let totalSteps = 6

    var canAdvance: Bool {
        switch currentStep {
        case 0: return !selectedIntent.isEmpty
        case 1: return !selectedGender.isEmpty && !selectedYear.isEmpty && !selectedSchoolType.isEmpty
        case 2: return !selectedFirstGen.isEmpty
        case 3: return !selectedCareerStage.isEmpty && !selectedCareerSupport.isEmpty
        case 4: return true
        case 5: return !selectedMentorPreferences.isEmpty && !selectedSupportStyle.isEmpty
        default: return true
        }
    }

    func toggleMentorPreference(_ value: String) {
        if selectedMentorPreferences.contains(value) {
            selectedMentorPreferences.remove(value)
        } else if selectedMentorPreferences.count < 2 {
            selectedMentorPreferences.insert(value)
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
        selectedIntent = ""
        selectedGender = ""
        selectedYear = ""
        selectedMajor = ""
        selectedSchoolType = ""
        selectedFirstGen = ""
        selectedCareerStage = ""
        selectedCareerSupport = ""
        selectedConfidence = 3
        selectedMentorPreferences = []
        selectedSupportStyle = ""
        currentStep = 0
        matchedMentor = nil
        isLoading = false
        isComplete = false
    }
}
