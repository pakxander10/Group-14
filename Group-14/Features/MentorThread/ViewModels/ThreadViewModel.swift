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

    init(service: ThreadServiceProtocol? = nil) {
        self.service = service ?? ThreadService()
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
}
