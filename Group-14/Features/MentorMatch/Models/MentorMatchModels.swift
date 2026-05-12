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
        bio: "I broke into tech via a non-traditional path — no CS degree, just determination. Now I help early-career engineers navigate their first roles, ace interviews, and build a career they're proud of.",
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
    MentorProfile(
        id: "c3",
        name: "Maya Patel",
        title: "Investment Banking Analyst",
        company: "Fidelity",
        track: "Tech",
        bio: "Took the traditional path — top school, direct entry into investment banking. I help ambitious students break into capital markets and understand what the role actually demands day one.",
        expertise: ["Investment Banking", "Capital Markets", "Resume Building", "Interview Prep"],
        yearsExperience: 5,
        avatarInitials: "MP",
        email: "maya.patel@fidelity.com",
        linkedInUrl: "linkedin.com/in/mayapatel",
        educationHistory: ["BS Finance, Wharton School"]
    ),
    MentorProfile(
        id: "c4",
        name: "Alex Rivera",
        title: "Senior Data Scientist",
        company: "Fidelity",
        track: "Tech",
        bio: "First-gen college grad who taught myself Python and broke into data science from a non-STEM background. I help people navigate analytics roles and figure out what skills actually matter.",
        expertise: ["Data Science", "Analytics", "Career Growth", "Interview Prep"],
        yearsExperience: 6,
        avatarInitials: "AR",
        email: "alex.rivera@fidelity.com",
        linkedInUrl: "linkedin.com/in/alexrivera",
        educationHistory: ["BA Economics, UCLA"]
    ),
    MentorProfile(
        id: "c5",
        name: "Chris Thompson",
        title: "Head of Product",
        company: "Fidelity Fintech",
        track: "Tech",
        bio: "I've spent my career at the intersection of finance and technology. I help people who want to break into fintech understand the landscape and position themselves for roles that didn't exist five years ago.",
        expertise: ["Fintech", "Product Management", "Career Growth", "Networking"],
        yearsExperience: 10,
        avatarInitials: "CT",
        email: "chris.thompson@fidelity.com",
        linkedInUrl: "linkedin.com/in/christhompson",
        educationHistory: ["BS Computer Science, Georgia Tech", "MBA, Duke Fuqua"]
    ),
    MentorProfile(
        id: "c6",
        name: "Lisa Zhang",
        title: "VP of Corporate Finance",
        company: "Fidelity",
        track: "Tech",
        bio: "I've hired dozens of analysts and associates across corporate finance and accounting. I know exactly what companies want and I help candidates position themselves to get those offers.",
        expertise: ["Corporate Finance", "Accounting", "Resume Building", "Career Growth"],
        yearsExperience: 14,
        avatarInitials: "LZ",
        email: "lisa.zhang@fidelity.com",
        linkedInUrl: "linkedin.com/in/lisazhang",
        educationHistory: ["BS Accounting, NYU Stern", "MBA, Columbia Business School"]
    ),
    MentorProfile(
        id: "c7",
        name: "Darius Coleman",
        title: "Software Engineering Manager",
        company: "Fidelity",
        track: "Tech",
        bio: "As a Black engineer in tech, I've navigated being underrepresented at every level. I mentor people who look like me and want someone who genuinely understands the extra layer of challenge they face.",
        expertise: ["Career Growth", "System Design", "Interview Prep", "Networking"],
        yearsExperience: 9,
        avatarInitials: "DC",
        email: "darius.coleman@fidelity.com",
        linkedInUrl: "linkedin.com/in/dariuscoleman",
        educationHistory: ["BS Computer Engineering, Howard University"]
    ),
]
