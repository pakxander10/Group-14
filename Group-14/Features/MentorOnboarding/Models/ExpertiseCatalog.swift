//
//  ExpertiseCatalog.swift
//  Group-14 — Features/MentorOnboarding/Models
//
//  Curated, track-aware list of predetermined expertise tags that mentors
//  choose from when building their profile. Foundation only.
//

import Foundation

enum ExpertiseCatalog {

    static let financialTerms: [String] = [
        "Budgeting",
        "Checking",
        "Savings",
        "High-Yield Savings",
        "Emergency Fund",
        "Credit Cards",
        "Credit Score",
        "Student Loans",
        "Debt Payoff",
        "Roth IRA",
        "Traditional IRA",
        "401k",
        "HSA",
        "Index Funds",
        "ETFs",
        "Stocks",
        "Bonds",
        "Investing",
        "Taxes",
        "Tax Filing",
        "Financial Planning",
        "Retirement Planning",
        "Salary Negotiation",
        "First Paycheck",
        "Renting vs. Buying",
        "Mortgages",
        "Insurance",
        "Estate Planning"
    ]

    static let techTerms: [String] = [
        "Career Growth",
        "Career Change",
        "Interview Prep",
        "Behavioral Interviews",
        "Technical Interviews",
        "System Design",
        "Resume Building",
        "Networking",
        "Product Management",
        "iOS",
        "Android",
        "Web Development",
        "Frontend",
        "Backend",
        "Full Stack",
        "Data Science",
        "Machine Learning",
        "DevOps",
        "Cloud",
        "Cybersecurity",
        "UX Design",
        "Software Engineering",
        "Internship Search",
        "Mentorship",
        "Mock Interviews",
        "Open Source"
    ]

    /// Returns the term pool for the given track string.
    /// - `"Financial"` → financial pool
    /// - `"Tech"` → tech pool
    /// - empty / unknown → merged pool (de-duplicated, sorted)
    static func terms(for track: String) -> [String] {
        switch track {
        case MentorTrack.financial.rawValue: return financialTerms
        case MentorTrack.tech.rawValue:      return techTerms
        default:
            // Merge + de-dupe while preserving stable ordering.
            var seen = Set<String>()
            var merged: [String] = []
            for term in financialTerms + techTerms where seen.insert(term).inserted {
                merged.append(term)
            }
            return merged
        }
    }

    /// True when `term` is part of either curated pool. Comparison is
    /// case-insensitive but the stored value should always come from the pool.
    static func isKnown(_ term: String) -> Bool {
        let normalized = term.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        return (financialTerms + techTerms).contains { $0.lowercased() == normalized }
    }
}
