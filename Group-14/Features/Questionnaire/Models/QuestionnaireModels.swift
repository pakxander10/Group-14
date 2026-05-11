//
//  QuestionnaireModels.swift
//  Group-14 — Features/Questionnaire/Models
//

import Foundation

// MARK: - QuestionnaireRequest

struct QuestionnaireRequest: Codable {
    let age: Int
    let background: String      // "first_gen" | "general"
    let interest: String        // "financial" | "tech"
    let goal: String            // "investing" | "budgeting" | "career" | "coding" | "interview_prep"
}

// MARK: - QuestionnaireStep (local UI state, not transmitted)

struct QuestionnaireOption: Identifiable {
    let id = UUID()
    let label: String
    let value: String
    let emoji: String
}
