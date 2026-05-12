//
//  MockThreadService.swift
//  Group-14Tests — Mocks
//
//  In-memory mock of ThreadServiceProtocol. Mirrors the backend's
//  Finance-exclusive scoring spec so acceptance tests don't need a
//  running FastAPI server.
//
//    First Financial post  → +25 to learner
//    Subsequent Finance    → +5
//    Mentor reply (Finance only) → +10 to post author
//    Anything on the Tech track  → 0 delta
//

import Foundation
@testable import Group_14

final class MockThreadService: ThreadServiceProtocol {

    // MARK: - State (introspectable by tests)
    var posts: [String: ThreadPost] = [:]
    var notifications: [String: [InboxNotification]] = [:]
    var learnerScores: [String: Int] = [:]
    var learnerNames: [String: String] = [:]
    var learnerInterests: [String: String] = [:]   // "financial" | "tech"
    var mentorNames: [String: String] = [:]

    var throwOnNext: Error?

    // Scoring constants — mirror the backend's planned constants exactly.
    static let mentorReplyConfidenceBoost = 10
    static let firstFinancePostBonus     = 25
    static let subsequentFinancePostBonus = 5

    init() {}

    // MARK: - Seeding helpers

    /// `interest` is required so tests are explicit about the track.
    /// Values are normalized to lowercase to match `LearnerProfile.interest`.
    func seedLearner(id: String, name: String, interest: String, score: Int) {
        learnerNames[id] = name
        learnerInterests[id] = interest.lowercased()
        learnerScores[id] = score
        notifications[id] = notifications[id] ?? []
    }

    func seedMentor(id: String, name: String) {
        mentorNames[id] = name
    }

    /// Insert a fully-formed post without running the createPost scoring side-effects.
    /// Useful for tests that want to isolate a downstream behavior (e.g. mentor reply).
    @discardableResult
    func seedPost(
        id: String = "p_seed",
        authorId: String,
        category: String,
        title: String = "Seed question",
        body: String = "Seed body"
    ) -> ThreadPost {
        let post = ThreadPost(
            id: id,
            authorId: authorId,
            authorName: learnerNames[authorId] ?? "Unknown",
            authorRole: "learner",
            category: category,
            title: title,
            body: body,
            upvotes: 0,
            replies: []
        )
        posts[id] = post
        return post
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

        // Finance-exclusive scoring: both the author and the post must be Financial.
        let interest = (learnerInterests[request.authorId] ?? "").lowercased()
        if interest == "financial" && request.category.lowercased() == "financial" {
            let priorPosts = posts.values.filter {
                $0.authorId == request.authorId && $0.id != newId
            }.count
            let bonus = priorPosts == 0
                ? Self.firstFinancePostBonus
                : Self.subsequentFinancePostBonus
            let current = learnerScores[request.authorId] ?? 0
            learnerScores[request.authorId] = max(0, min(1000, current + bonus))
        }

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

            // 1. Notification always fires (Tech learners still want to see replies).
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

            // 2. Confidence bump is Finance-exclusive: gate on post.category.
            if post.category.lowercased() == "financial" {
                let current = learnerScores[learnerId] ?? 0
                learnerScores[learnerId] = max(0, min(1000, current + Self.mentorReplyConfidenceBoost))
            }
        }

        return reply
    }

    func fetchInbox(learnerId: String) async throws -> [InboxNotification] {
        if let err = throwOnNext { throwOnNext = nil; throw err }
        return (notifications[learnerId] ?? []).sorted { $0.createdAt > $1.createdAt }
    }
}
