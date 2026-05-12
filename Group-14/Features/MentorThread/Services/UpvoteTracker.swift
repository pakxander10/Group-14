//
//  UpvoteTracker.swift
//  Group-14 — Features/MentorThread/Services
//
//  Records which (userId, postId/replyId) pairs the user has already upvoted
//  so the thread VM can prevent the same learner from re-voting on the same
//  item. The mock backend is single-user, so this is a client-side gate;
//  swapping in a real auth-backed API would move this enforcement server-side.
//

import Foundation

@MainActor
protocol UpvoteTracking {
    func hasUpvotedPost(_ postId: String, by userId: String) -> Bool
    func recordPostUpvote(_ postId: String, by userId: String)

    func hasUpvotedReply(_ replyId: String, by userId: String) -> Bool
    func recordReplyUpvote(_ replyId: String, by userId: String)
}

@MainActor
final class UpvoteTracker: UpvoteTracking {
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func hasUpvotedPost(_ postId: String, by userId: String) -> Bool {
        contains(in: postsKey(userId), value: postId)
    }

    func recordPostUpvote(_ postId: String, by userId: String) {
        insert(into: postsKey(userId), value: postId)
    }

    func hasUpvotedReply(_ replyId: String, by userId: String) -> Bool {
        contains(in: repliesKey(userId), value: replyId)
    }

    func recordReplyUpvote(_ replyId: String, by userId: String) {
        insert(into: repliesKey(userId), value: replyId)
    }

    private func contains(in key: String, value: String) -> Bool {
        (defaults.stringArray(forKey: key) ?? []).contains(value)
    }

    private func insert(into key: String, value: String) {
        var ids = Set(defaults.stringArray(forKey: key) ?? [])
        ids.insert(value)
        defaults.set(Array(ids), forKey: key)
    }

    private func postsKey(_ userId: String) -> String { "investinme.upvotedPosts.\(userId)" }
    private func repliesKey(_ userId: String) -> String { "investinme.upvotedReplies.\(userId)" }
}
