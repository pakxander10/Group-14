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
            matchedMentor = financialMentorPool
                .map { ($0, scoreFinancialMentor($0)) }
                .max(by: { $0.1 < $1.1 })?
                .0 ?? financialMentorPool.first
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

    // MARK: - Weighted Scoring

    private func scoreFinancialMentor(_ mentor: MentorProfile) -> Int {
        var score = 0
        let bio = mentor.bio.lowercased()
        let expertise = mentor.expertise.map { $0.lowercased() }
        let title = mentor.title.lowercased()

        // First-gen match (+3)
        if selectedFirstGen == "first_gen" && bio.contains("first-gen") {
            score += 3
        }

        // Experience preference match (+3)
        switch selectedExperiencePreference {
        case "3_5_years":
            if (3...5).contains(mentor.yearsExperience) { score += 3 }
        case "6_10_years":
            if (6...10).contains(mentor.yearsExperience) { score += 3 }
        case "10_plus_years":
            if mentor.yearsExperience >= 10 { score += 3 }
        case "any":
            score += 1
        default: break
        }

        // Financial gap → expertise match (+2)
        let gapKeywords: [String: String] = [
            "taxes_paychecks":    "tax",
            "budgeting":          "budget",
            "saving_investing":   "invest",
            "student_loans":      "student loan",
            "financial_accounts": "financial planning",
            "salary_negotiation": "salary"
        ]
        if let kw = gapKeywords[selectedFinancialGap], expertise.contains(where: { $0.contains(kw) }) {
            score += 2
        }

        // Selected accounts → expertise match (+2 each)
        let accountKeywords: [String: String] = [
            "401k":         "401k",
            "roth_ira":     "roth",
            "student_loans":"student loan",
            "credit_card":  "budget"
        ]
        for account in selectedAccounts {
            if let kw = accountKeywords[account], expertise.contains(where: { $0.contains(kw) }) {
                score += 2
            }
        }

        // Urgent priority → expertise match (+2)
        let priorityKeywords: [String: String] = [
            "rent":       "budget",
            "paycheck":   "tax",
            "debt":       "student loan",
            "investing":  "invest",
            "behind":     "financial planning",
            "no_guidance":"financial planning"
        ]
        if let kw = priorityKeywords[selectedUrgentPriority], expertise.contains(where: { $0.contains(kw) }) {
            score += 2
        }

        // Mentor background → title match (+2)
        let backgroundKeywords: [String: String] = [
            "personal_finance": "financial advisor",
            "banking_wealth":   "wealth",
            "investment":       "investment",
            "corporate_finance":"finance"
        ]
        if let kw = backgroundKeywords[selectedMentorBackground], title.contains(kw) {
            score += 2
        }

        // User situation → mentor experience range match (+2)
        // Students/early-stage users matched to more approachable mentors; working users to senior mentors
        switch selectedSituation {
        case "student_no_income", "part_time_student":
            if mentor.yearsExperience <= 8 { score += 2 }
        case "first_full_time", "recent_grad_solo":
            if (5...12).contains(mentor.yearsExperience) { score += 2 }
        case "working_behind":
            if mentor.yearsExperience >= 8 { score += 2 }
        default: break
        }

        // Communication style → bio keyword match (+1)
        let commKeywords: [String: String] = [
            "direct":   "direct",
            "detailed": "understand",
            "stories":  "navigated",
            "mix":      ""
        ]
        if let kw = commKeywords[selectedCommunicationStyle], !kw.isEmpty, bio.contains(kw) {
            score += 1
        }

        return score
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
            matchedMentor = careerMentorPool
                .map { ($0, scoreCareerMentor($0)) }
                .max(by: { $0.1 < $1.1 })?
                .0 ?? careerMentorPool.first
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

    // MARK: - Weighted Scoring

    private func scoreCareerMentor(_ mentor: MentorProfile) -> Int {
        var score = 0
        let bio = mentor.bio.lowercased()
        let expertise = mentor.expertise.map { $0.lowercased() }

        // First-gen match (+3)
        if selectedFirstGen == "first_gen" && bio.contains("first-gen") {
            score += 3
        }

        // Target industry → expertise/track match (+3)
        let industryKeywords: [String: String] = [
            "investment_banking": "investment banking",
            "wealth_management":  "financial planning",
            "fintech":            "fintech",
            "software_eng":       "ios",
            "data_science":       "data science",
            "corporate_finance":  "corporate finance"
        ]
        if let kw = industryKeywords[selectedTargetIndustry], expertise.contains(where: { $0.contains(kw) }) {
            score += 3
        }

        // Needed support → expertise match (+2)
        let supportKeywords: [String: String] = [
            "roles_pay":      "career growth",
            "resume":         "resume",
            "interviews":     "interview",
            "first_90_days":  "career growth",
            "internal_growth":"career growth",
            "long_term":      "network"
        ]
        if let kw = supportKeywords[selectedNeededSupport], expertise.contains(where: { $0.contains(kw) }) {
            score += 2
        }

        // Company type → company/bio match (+2)
        let companyKeywords: [String: String] = [
            "large_bank":    "fidelity",
            "fintech_startup":"fintech",
            "big_tech":      "tech",
            "consulting":    "advisor"
        ]
        if let kw = companyKeywords[selectedCompanyType],
           mentor.company.lowercased().contains(kw) || bio.contains(kw) {
            score += 2
        }

        // Mentor career path → bio keyword match (+2)
        let pathKeywords: [String: String] = [
            "traditional":       "took the traditional path",
            "non_traditional":   "non-traditional path",
            "underrepresented":  "underrepresented",
            "hiring_experience": "hired"
        ]
        if let kw = pathKeywords[selectedMentorCareerPath], bio.contains(kw) {
            score += 2
        }

        // Career switch → mentor with career-change expertise (+2)
        if selectedCareerStage == "career_switch",
           expertise.contains(where: { $0.contains("career change") || $0.contains("career switch") }) {
            score += 2
        }

        // Role clarity — low clarity users matched to mentors with broad expertise (+2)
        if selectedRoleClarity == "no_idea" || selectedRoleClarity == "industry_only" {
            if expertise.count >= 4 { score += 2 }
        }
        // High clarity users matched to mentors with a specific matching title (+2)
        if selectedRoleClarity == "very_clear",
           expertise.contains(where: { $0.contains(selectedTargetIndustry.replacingOccurrences(of: "_", with: " ")) }) {
            score += 2
        }

        // Education background → mentor path match (+2)
        // Self-taught/bootcamp users prioritised toward non-traditional mentors
        if selectedEducationBackground == "self_taught", bio.contains("without a traditional") {
            score += 2
        }
        // Grad-level users matched to mentors whose bio/education reflects advanced credentials
        if (selectedEducationBackground == "pursuing_masters" || selectedEducationBackground == "masters_done"),
           let edu = mentor.educationHistory, edu.joined().lowercased().contains("mba") || edu.joined().lowercased().contains("master") {
            score += 2
        }

        return score
    }
}
