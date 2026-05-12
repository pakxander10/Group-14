//
//  MockThreadService.swift
//  Group-14Tests — Mocks
//
//  In-memory mock of ThreadServiceProtocol. Mirrors the backend's side-effects
//  in `createReply` (append notification + bump learner confidence) so the
//  acceptance tests don't need a running FastAPI server.
//

import Foundation
@testable import Group_14

final class MockThreadService: ThreadServiceProtocol {

    // MARK: - State (introspectable by tests)
    var posts: [String: ThreadPost] = [:]
    var notifications: [String: [InboxNotification]] = [:]
    var learnerScores: [String: Int] = [:]
    var learnerNames: [String: String] = [:]
    var mentorNames: [String: String] = [:]

    var throwOnNext: Error?

    static let mentorReplyConfidenceBoost = 10

    init() {}

    // MARK: - Seeding helpers

    func seedLearner(id: String, name: String, score: Int) {
        learnerNames[id] = name
        learnerScores[id] = score
        notifications[id] = notifications[id] ?? []
    }

    func seedMentor(id: String, name: String) {
        mentorNames[id] = name
    }

    // MARK: - ThreadServiceProtocol

    func fetchFeed() async throws -> [ThreadPost] {
        if let err = throwOnNext { throwOnNext = nil; throw err }
        return Array(posts.values).sorted { $0.upvotes > $1.upvotes }
    }

    func createPost(_ request: CreatePostRequest) async throws -> ThreadPost {
        if let err = throwOnNext { throwOnNext = nil; throw err }
        let newId = "p_\(posts.count + 1)"
        let post = ThreadPost(
            id: newId,
            authorId: request.authorId,
            authorName: learnerNames[request.authorId] ?? "Unknown",
            authorRole: "learner",
            category: request.category,
            title: request.title,
            body: request.body,
            upvotes: 0,
            replies: []
        )
        posts[newId] = post
        return post
    }

    func createReply(_ request: CreateReplyRequest) async throws -> ThreadReply {
        if let err = throwOnNext { throwOnNext = nil; throw err }
        guard var post = posts[request.postId] else {
            throw NSError(domain: "MockThreadService", code: 404,
                          userInfo: [NSLocalizedDescriptionKey: "Post not found"])
        }
        let mentorName = mentorNames[request.authorId] ?? "Unknown Mentor"
        let reply = ThreadReply(
            id: "r_\(post.replies.count + 1)",
            postId: post.id,
            authorId: request.authorId,
            authorName: mentorName,
            authorRole: "mentor",
            body: request.body,
            upvotes: 0
        )

        // Append reply (re-construct because struct fields are `let`).
        let updatedPost = ThreadPost(
            id: post.id,
            authorId: post.authorId,
            authorName: post.authorName,
            authorRole: post.authorRole,
            category: post.category,
            title: post.title,
            body: post.body,
            upvotes: post.upvotes,
            replies: post.replies + [reply]
        )
        posts[post.id] = updatedPost
        post = updatedPost

        // Side-effects when the original poster is a learner — same as backend.
        if post.authorRole == "learner" {
            let learnerId = post.authorId

            // 1. Append notification
            let notif = InboxNotification(
                id: "n_\((notifications[learnerId] ?? []).count + 1)",
                learnerId: learnerId,
                postId: post.id,
                postTitle: post.title,
                mentorId: request.authorId,
                mentorName: mentorName,
                replyPreview: String(reply.body.prefix(140)),
                createdAt: ISO8601DateFormatter().string(from: Date())
            )
            notifications[learnerId, default: []].append(notif)

            // 2. Bump confidence score, clamped 1...1000.
            let current = learnerScores[learnerId] ?? 0
            learnerScores[learnerId] = max(1, min(1000, current + Self.mentorReplyConfidenceBoost))
        }

        return reply
    }

    func fetchInbox(learnerId: String) async throws -> [InboxNotification] {
        if let err = throwOnNext { throwOnNext = nil; throw err }
        return (notifications[learnerId] ?? []).sorted { $0.createdAt > $1.createdAt }
    }
}
