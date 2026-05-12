//
//  ThreadViewModel.swift
//  Group-14 — Features/MentorThread/ViewModels
//
//  Owns the Q Thread feed plus the post and reply composers.
//  ⚠️ Foundation only. No SwiftUI imports.
//

import Foundation
internal import Combine

@MainActor
final class ThreadViewModel: ObservableObject {

    // MARK: - Feed state
    @Published private(set) var posts: [ThreadPost] = []
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?

    // MARK: - Create-post composer state
    @Published var newPostTitle: String = ""
    @Published var newPostBody: String = ""
    @Published var newPostCategory: ThreadCategory = .financial
    @Published private(set) var isSubmittingPost = false
    @Published private(set) var postErrorMessage: String?

    // MARK: - Reply composer state (shared across detail views; body is held by the view)
    @Published private(set) var isSubmittingReply = false
    @Published private(set) var replyErrorMessage: String?

    var canSubmitPost: Bool {
        !newPostTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && !newPostBody.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && !isSubmittingPost
    }

    private let service: ThreadServiceProtocol
    private let tracker: UpvoteTracking

    init(
        service: ThreadServiceProtocol? = nil,
        tracker: UpvoteTracking? = nil
    ) {
        self.service = service ?? ThreadService()
        self.tracker = tracker ?? UpvoteTracker()
    }

    // MARK: - Intents

    func loadFeed() {
        isLoading = true
        errorMessage = nil

        Task {
            defer { isLoading = false }
            do {
                posts = try await service.fetchFeed()
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }

    /// Submit the current composer as a new question on behalf of `learnerId`.
    /// On success the composer is cleared, the feed is reloaded, and `onSuccess` fires.
    func submitPost(asLearner learnerId: String, onSuccess: (() -> Void)? = nil) {
        guard canSubmitPost else { return }

        let title = newPostTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        let body  = newPostBody.trimmingCharacters(in: .whitespacesAndNewlines)
        let request = CreatePostRequest(
            authorId: learnerId,
            category: newPostCategory.rawValue,
            title: title,
            body: body
        )

        isSubmittingPost = true
        postErrorMessage = nil

        Task {
            defer { isSubmittingPost = false }
            do {
                _ = try await service.createPost(request)
                // Refresh the feed inline before signalling success so the dismissed
                // composer reveals an already-up-to-date list.
                posts = try await service.fetchFeed()
                resetComposer()
                onSuccess?()
            } catch {
                postErrorMessage = error.localizedDescription
            }
        }
    }

    /// Submit a mentor reply to a specific post.
    func submitReply(
        postId: String,
        asMentor mentorId: String,
        body: String,
        onSuccess: (() -> Void)? = nil
    ) {
        let trimmed = body.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        let request = CreateReplyRequest(
            postId: postId,
            authorId: mentorId,
            body: trimmed
        )

        isSubmittingReply = true
        replyErrorMessage = nil

        Task {
            defer { isSubmittingReply = false }
            do {
                _ = try await service.createReply(request)
                posts = try await service.fetchFeed()
                onSuccess?()
            } catch {
                replyErrorMessage = error.localizedDescription
            }
        }
    }

    func resetComposer() {
        newPostTitle = ""
        newPostBody = ""
        newPostCategory = .financial
        postErrorMessage = nil
    }

    // MARK: - Upvoting

    /// Has the given learner already upvoted this post? Views consult this so
    /// the upvote button can render in a "voted" state and disable additional
    /// taps.
    func hasUpvotedPost(_ postId: String, by userId: String) -> Bool {
        tracker.hasUpvotedPost(postId, by: userId)
    }

    /// Has the given learner already upvoted this reply?
    func hasUpvotedReply(_ replyId: String, by userId: String) -> Bool {
        tracker.hasUpvotedReply(replyId, by: userId)
    }

    /// Increment the upvote count on a post visible to the user. The call is a
    /// no-op (no service call) when:
    ///   - the post id is not in the local feed,
    ///   - the user id is empty, or
    ///   - this `(userId, postId)` pair has already been recorded.
    /// The local record is only inserted after the service confirms success so
    /// a network failure doesn't permanently lock the user out.
    func upvotePost(id: String, by userId: String) {
        guard !userId.isEmpty,
              posts.contains(where: { $0.id == id }),
              !tracker.hasUpvotedPost(id, by: userId)
        else { return }

        Task {
            do {
                let updated = try await service.upvotePost(id: id)
                if let index = posts.firstIndex(where: { $0.id == id }) {
                    posts[index] = updated
                }
                tracker.recordPostUpvote(id, by: userId)
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }

    /// Increment the upvote count on a reply nested inside `postId`. Same
    /// no-op rules as `upvotePost` — including the one-vote-per-learner check
    /// — apply to the reply id.
    func upvoteReply(postId: String, replyId: String, by userId: String) {
        guard !userId.isEmpty,
              let post = posts.first(where: { $0.id == postId }),
              post.replies.contains(where: { $0.id == replyId }),
              !tracker.hasUpvotedReply(replyId, by: userId)
        else { return }

        Task {
            do {
                let updatedReply = try await service.upvoteReply(postId: postId, replyId: replyId)
                guard let postIndex = posts.firstIndex(where: { $0.id == postId }),
                      let replyIndex = posts[postIndex].replies.firstIndex(where: { $0.id == replyId })
                else { return }

                let post = posts[postIndex]
                var replies = post.replies
                replies[replyIndex] = updatedReply
                posts[postIndex] = ThreadPost(
                    id: post.id,
                    authorId: post.authorId,
                    authorName: post.authorName,
                    authorRole: post.authorRole,
                    category: post.category,
                    title: post.title,
                    body: post.body,
                    upvotes: post.upvotes,
                    replies: replies
                )
                tracker.recordReplyUpvote(replyId, by: userId)
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
}
