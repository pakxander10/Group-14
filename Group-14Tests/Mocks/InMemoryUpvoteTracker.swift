//
//  InMemoryUpvoteTracker.swift
//  Group-14Tests — Mocks
//
//  Test double for UpvoteTracking. Keeps the (userId, id) set in memory so
//  acceptance tests don't pollute UserDefaults.standard between runs.
//

import Foundation
@testable import Group_14

@MainActor
final class InMemoryUpvoteTracker: UpvoteTracking {
    private(set) var votedPosts: Set<String> = []
    private(set) var votedReplies: Set<String> = []

    func hasUpvotedPost(_ postId: String, by userId: String) -> Bool {
        votedPosts.contains(key(userId, postId))
    }

    func recordPostUpvote(_ postId: String, by userId: String) {
        votedPosts.insert(key(userId, postId))
    }

    func hasUpvotedReply(_ replyId: String, by userId: String) -> Bool {
        votedReplies.contains(key(userId, replyId))
    }

    func recordReplyUpvote(_ replyId: String, by userId: String) {
        votedReplies.insert(key(userId, replyId))
    }

    private func key(_ userId: String, _ itemId: String) -> String {
        "\(userId):\(itemId)"
    }
}
