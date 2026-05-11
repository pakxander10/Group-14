//
//  LearnerOnboardingModel.swift
//  Group-14 — Features/LearnerOnboarding/Models
//
//  Plain data — Foundation only. No SwiftUI, no ViewModels.
//

import Foundation

// MARK: - LearnerOnboardingData
// Accumulates answers across all questionnaire steps.
// Mapped to QuestionnaireRequest before sending to backend.

struct LearnerOnboardingData {
    // Step 0 — Identity
    var name: String = ""

    // Step 1 — Track selection
    var track: MentorTrack = .financial

    // Step 2 — Demographics
    var isFirstGen: Bool? = nil                          // nil = not answered
    var gender: LearnerGender = .preferNotToSay

    // Step 3 — School / Career
    var schoolType: SchoolType = .fourYear
    var graduationYear: Int = 2026
    var majorOrOccupation: String = ""

    // Step 4 — Intent
    var intent: LearnerIntent = .buildWealth

    // Step 5 — Baseline confidence (self-reported 1–10)
    var baselineConfidence: Int = 5

    // Step 6 — Financial accounts (shown only for Financial track)
    var financialAccounts: Set<FinancialAccount> = []

    // MARK: Derived values for QuestionnaireRequest

    /// Maps to `background` field on the backend
    var backgroundValue: String {
        guard let firstGen = isFirstGen else { return "general" }
        return firstGen ? "first_gen" : "general"
    }

    /// Approximate age from graduation year (used for backend `age` field)
    var approximateAge: Int {
        let graduationAge = 22
        let yearsSinceGrad = max(0, Calendar.current.component(.year, from: Date()) - graduationYear)
        return graduationAge + yearsSinceGrad
    }
}

// MARK: - MentorTrack

enum MentorTrack: String, CaseIterable, Identifiable {
    case financial = "financial"
    case tech      = "tech"

    var id: String { rawValue }
    var displayName: String {
        switch self {
        case .financial: return "Financial Guidance"
        case .tech:      return "Tech Industry Career"
        }
    }
    var subtitle: String {
        switch self {
        case .financial: return "Investing, budgeting, accounts, wealth building"
        case .tech:      return "Breaking into tech, coding, career growth"
        }
    }
    var emoji: String {
        switch self {
        case .financial: return "💰"
        case .tech:      return "💻"
        }
    }
}

// MARK: - LearnerGender

enum LearnerGender: String, CaseIterable, Identifiable {
    case woman          = "woman"
    case nonBinary      = "non_binary"
    case preferNotToSay = "prefer_not_to_say"

    var id: String { rawValue }
    var displayName: String {
        switch self {
        case .woman:          return "Woman"
        case .nonBinary:      return "Non-binary / Gender non-conforming"
        case .preferNotToSay: return "Prefer not to say"
        }
    }
    var emoji: String {
        switch self {
        case .woman:          return "👩"
        case .nonBinary:      return "🧑"
        case .preferNotToSay: return "🔒"
        }
    }
}

// MARK: - SchoolType

enum SchoolType: String, CaseIterable, Identifiable {
    case fourYear        = "four_year"
    case communityCollege = "community_college"
    case tradeSchool     = "trade_school"
    case gradSchool      = "grad_school"
    case notInSchool     = "not_in_school"

    var id: String { rawValue }
    var displayName: String {
        switch self {
        case .fourYear:         return "4-Year University"
        case .communityCollege: return "Community College"
        case .tradeSchool:      return "Trade / Vocational School"
        case .gradSchool:       return "Graduate School"
        case .notInSchool:      return "Not Currently in School"
        }
    }
    var emoji: String {
        switch self {
        case .fourYear:         return "🎓"
        case .communityCollege: return "🏫"
        case .tradeSchool:      return "🔧"
        case .gradSchool:       return "📚"
        case .notInSchool:      return "💼"
        }
    }
}

// MARK: - LearnerIntent ("What brought you here today?")

enum LearnerIntent: String, CaseIterable, Identifiable {
    case buildWealth    = "investing"
    case payOffDebt     = "budgeting"
    case understandMoney = "financial_literacy"
    case landFirstJob   = "career"
    case getPromoted    = "interview_prep"
    case learnToCode    = "coding"

    var id: String { rawValue }
    var displayName: String {
        switch self {
        case .buildWealth:     return "Start building wealth"
        case .payOffDebt:      return "Pay off debt / manage money"
        case .understandMoney: return "Understand my finances"
        case .landFirstJob:    return "Land my first job in tech"
        case .getPromoted:     return "Level up my tech career"
        case .learnToCode:     return "Learn to code / break in"
        }
    }
    var emoji: String {
        switch self {
        case .buildWealth:     return "📈"
        case .payOffDebt:      return "💳"
        case .understandMoney: return "🧾"
        case .landFirstJob:    return "🚀"
        case .getPromoted:     return "⬆️"
        case .learnToCode:     return "👩‍💻"
        }
    }
}

// MARK: - FinancialAccount (multi-select, financial track only)

enum FinancialAccount: String, CaseIterable, Identifiable, Hashable {
    case checking   = "checking"
    case savings    = "savings"
    case retirement401k = "401k"
    case rothIRA    = "roth_ira"
    case brokerage  = "brokerage"
    case none       = "none"

    var id: String { rawValue }
    var displayName: String {
        switch self {
        case .checking:       return "Checking Account"
        case .savings:        return "Savings Account"
        case .retirement401k: return "401(k)"
        case .rothIRA:        return "Roth IRA"
        case .brokerage:      return "Brokerage / Investment Account"
        case .none:           return "None — starting from scratch"
        }
    }
    var emoji: String {
        switch self {
        case .checking:       return "🏦"
        case .savings:        return "🐖"
        case .retirement401k: return "🧓"
        case .rothIRA:        return "📊"
        case .brokerage:      return "📉"
        case .none:           return "0️⃣"
        }
    }
}
