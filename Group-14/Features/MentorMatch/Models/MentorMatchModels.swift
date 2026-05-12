//
//  MentorMatchModels.swift
//  Group-14 — Features/MentorMatch/Models
//

import Foundation

// MARK: - Shared

struct MatchOption: Identifiable {
    let id = UUID()
    let label: String
    let value: String
    let emoji: String
    var subtitle: String? = nil
}

// MARK: - Financial Match Request

struct FinancialMatchRequest: Codable {
    let intent: String
    let gender: String
    let yearInSchool: String
    let major: String
    let schoolType: String
    let firstGenStatus: String
    let financialStanding: String
    let confidenceLevel: Int
    let financialAccounts: [String]
    let financialConcern: String
    let mentorPreferences: [String]
    let supportStyle: String
}

// MARK: - Career Match Request

struct CareerMatchRequest: Codable {
    let intent: String
    let gender: String
    let yearInSchool: String
    let major: String
    let schoolType: String
    let firstGenStatus: String
    let careerStage: String
    let careerSupport: String
    let confidenceLevel: Int
    let mentorPreferences: [String]
    let supportStyle: String
}

// MARK: - Mock Mentor Pool

let financialMentorPool: [MentorProfile] = [
    MentorProfile(
        id: "f1",
        name: "Marcus Johnson",
        title: "Financial Advisor",
        company: "Fidelity",
        track: "Financial",
        bio: "First-gen college grad who built his financial knowledge from scratch. I help young people navigate their first paycheck, understand investing basics, and build lasting wealth.",
        expertise: ["Budgeting", "Investing", "Student Loans", "401k"],
        yearsExperience: 9,
        avatarInitials: "MJ",
        email: "marcus.johnson@fidelity.com",
        linkedInUrl: "linkedin.com/in/marcusjohnson",
        educationHistory: ["BS Finance, Howard University"]
    ),
    MentorProfile(
        id: "f2",
        name: "Priya Sharma",
        title: "Wealth Management Associate",
        company: "Fidelity",
        track: "Financial",
        bio: "Passionate about financial literacy for first-generation professionals. I specialize in early-career financial planning, Roth IRAs, and making your first dollar work for you.",
        expertise: ["Financial Planning", "Roth IRA", "Salary Negotiation", "Taxes"],
        yearsExperience: 6,
        avatarInitials: "PS",
        email: "priya.sharma@fidelity.com",
        linkedInUrl: "linkedin.com/in/priyasharma",
        educationHistory: ["BS Economics, University of Michigan"]
    ),
]

let careerMentorPool: [MentorProfile] = [
    MentorProfile(
        id: "c1",
        name: "Sarah Chen",
        title: "Senior Software Engineer",
        company: "Fidelity",
        track: "Tech",
        bio: "I broke into tech without a traditional CS background. Now I help early-career engineers navigate their first roles, ace interviews, and build a career they're proud of.",
        expertise: ["Career Growth", "Interview Prep", "iOS", "System Design"],
        yearsExperience: 12,
        avatarInitials: "SC",
        email: "sarah.chen@fidelity.com",
        linkedInUrl: "linkedin.com/in/sarahchen",
        educationHistory: ["BS Computer Science, MIT"]
    ),
    MentorProfile(
        id: "c2",
        name: "Jordan Williams",
        title: "Product Manager",
        company: "Fidelity",
        track: "Tech",
        bio: "First-gen professional who made the jump from finance to tech. I specialize in helping career changers build their roadmap and land roles they didn't think were possible.",
        expertise: ["Career Change", "Product Management", "Resume Building", "Networking"],
        yearsExperience: 7,
        avatarInitials: "JW",
        email: "jordan.williams@fidelity.com",
        linkedInUrl: "linkedin.com/in/jordanwilliams",
        educationHistory: ["BA Business, UT Austin"]
    ),
]
