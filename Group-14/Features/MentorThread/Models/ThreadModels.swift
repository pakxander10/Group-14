//
//  ThreadModels.swift
//  Group-14 — Features/MentorThread/Models
//
//  Plain data (Foundation only). No SwiftUI, no ViewModel imports.
//

import Foundation

// MARK: - User

/// Lightweight identity used by the threading system. Either a learner or a mentor.
/// The richer `LearnerProfile` / `MentorProfile` types remain for profile screens.
struct User: Codable, Identifiable, Equatable {
    let id: String
    let name: String
    let role: String        // "learner" | "mentor"
}

// MARK: - ThreadCategory

/// Mirrors `MentorTrack` rawValues so a post's category lines up with a mentor's track.
enum ThreadCategory: String, Codable, CaseIterable, Equatable {
    case financial = "Financial"
    case tech      = "Tech"

    var displayName: String { rawValue }
}

// MARK: - ThreadReply

struct ThreadReply: Codable, Identifiable, Equatable {
    let id: String
    let postId: String
    let authorId: String
    let authorName: String
    let authorRole: String  // "learner" | "mentor"
    let body: String
    let upvotes: Int
}

// MARK: - ThreadPost

struct ThreadPost: Codable, Identifiable, Equatable {
    let id: String
    let authorId: String
    let authorName: String
    let authorRole: String  // "learner" | "mentor"
    let category: String    // "Financial" | "Tech"
    let title: String
    let body: String
    let upvotes: Int
    let replies: [ThreadReply]
}

// MARK: - Notification

struct InboxNotification: Codable, Identifiable, Equatable {
    let id: String
    let learnerId: String
    let postId: String
    let postTitle: String
    let mentorId: String
    let mentorName: String
    let replyPreview: String
    let createdAt: String   // ISO-8601 UTC
}

// MARK: - Requests

struct CreatePostRequest: Encodable, Equatable {
    let authorId: String
    let category: String    // "Financial" | "Tech"
    let title: String
    let body: String
}

struct CreateReplyRequest: Encodable, Equatable {
    let postId: String
    let authorId: String
    let body: String
}
