//
//  ThreadModels.swift
//  Group-14 — Features/MentorThread/Models
//

import Foundation

// MARK: - ThreadReply

struct ThreadReply: Codable, Identifiable {
    let id: String
    let authorName: String
    let authorRole: String      // "learner" | "mentor"
    let body: String
    let upvotes: Int
}

// MARK: - ThreadPost

struct ThreadPost: Codable, Identifiable {
    let id: String
    let authorName: String
    let authorRole: String
    let title: String
    let body: String
    let upvotes: Int
    let replies: [ThreadReply]
}
