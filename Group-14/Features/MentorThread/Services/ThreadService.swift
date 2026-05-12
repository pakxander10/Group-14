//
//  ThreadService.swift
//  Group-14 — Features/MentorThread/Services
//
//  Protocol + concrete network implementation for the Q Thread + Inbox feature.
//  ⚠️ Foundation only. No SwiftUI imports.
//

import Foundation

// MARK: - ThreadServiceProtocol

/// All interactions a thread/inbox feature needs from the backend. ViewModels
/// depend on this protocol (never the concrete type) so they can be mocked
/// in acceptance tests.
protocol ThreadServiceProtocol {
    func fetchFeed() async throws -> [ThreadPost]
    func createPost(_ request: CreatePostRequest) async throws -> ThreadPost
    func createReply(_ request: CreateReplyRequest) async throws -> ThreadReply
    func fetchInbox(learnerId: String) async throws -> [InboxNotification]
    func upvotePost(id: String) async throws -> ThreadPost
    func upvoteReply(postId: String, replyId: String) async throws -> ThreadReply
}

/// Empty body for POST endpoints that expect no payload (e.g. upvote actions).
struct EmptyBody: Encodable, Equatable {}

// MARK: - ThreadService (concrete)

final class ThreadService: ThreadServiceProtocol {
    private let network: NetworkManagerProtocol

    init(network: NetworkManagerProtocol = NetworkManager.shared) {
        self.network = network
    }

    func fetchFeed() async throws -> [ThreadPost] {
        try await network.get("/feed")
    }

    func createPost(_ request: CreatePostRequest) async throws -> ThreadPost {
        try await network.post("/posts", body: request)
    }

    func createReply(_ request: CreateReplyRequest) async throws -> ThreadReply {
        try await network.post("/replies", body: request)
    }

    func fetchInbox(learnerId: String) async throws -> [InboxNotification] {
        try await network.get("/inbox/\(learnerId)")
    }

    func upvotePost(id: String) async throws -> ThreadPost {
        try await network.post("/posts/\(id)/upvote", body: EmptyBody())
    }

    func upvoteReply(postId: String, replyId: String) async throws -> ThreadReply {
        try await network.post("/posts/\(postId)/replies/\(replyId)/upvote", body: EmptyBody())
    }
}
