//
//  ThreadDetailView.swift
//  Group-14 — Features/MentorThread/Views
//
//  Detail of one ThreadPost — shows the question, all replies, and a
//  reply composer that is only visible to mentors.
//

import SwiftUI

struct ThreadDetailView: View {
    let post: ThreadPost
    @ObservedObject var viewModel: ThreadViewModel

    @AppStorage("userId")   private var userId:   String = ""
    @AppStorage("userRole") private var userRole: String = ""

    @State private var replyDraft: String = ""
    @FocusState private var replyFieldFocused: Bool

    private var isMentor: Bool { userRole == UserRole.mentor.storageValue }

    /// Look up the freshest copy of the post from the view model so newly
    /// submitted replies appear without round-tripping props.
    private var currentPost: ThreadPost {
        viewModel.posts.first(where: { $0.id == post.id }) ?? post
    }

    var body: some View {
        ZStack {
            Color.investBackground.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    headerCard
                    repliesSection

                    if isMentor {
                        replyComposerCard
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
            }
        }
        .navigationTitle("Question")
        .navigationBarTitleDisplayMode(.inline)
        .tint(Color.investPrimary)
    }

    // MARK: - Header

    private var headerCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            CategoryBadge(category: currentPost.category)

            Text(currentPost.title)
                .font(.title2.bold())
                .foregroundStyle(Color.investTitle)
                .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: 8) {
                Image(systemName: "person.circle.fill")
                    .foregroundStyle(Color.investTextSecondary)
                Text(currentPost.authorName)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.investTextPrimary)
                Text("· Learner")
                    .font(.caption)
                    .foregroundStyle(Color.investTextSecondary)
                Spacer()
                UpvoteButton(count: currentPost.upvotes) {
                    viewModel.upvotePost(id: currentPost.id)
                }
            }

            Text(currentPost.body)
                .font(.body)
                .foregroundStyle(Color.investTextPrimary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.investSurface)
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(Color.investBorder.opacity(0.6), lineWidth: 1)
                )
        )
    }

    // MARK: - Replies

    private var repliesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Replies (\(currentPost.replies.count))")
                .font(.headline)
                .foregroundStyle(Color.investTitle)
                .padding(.horizontal, 4)

            if currentPost.replies.isEmpty {
                emptyRepliesPlaceholder
            } else {
                ForEach(currentPost.replies) { reply in
                    ReplyCard(reply: reply) {
                        viewModel.upvoteReply(postId: currentPost.id, replyId: reply.id)
                    }
                }
            }
        }
    }

    private var emptyRepliesPlaceholder: some View {
        HStack(spacing: 10) {
            Image(systemName: "bubble.left")
                .foregroundStyle(Color.investTextSecondary)
            Text("No replies yet.")
                .font(.subheadline)
                .foregroundStyle(Color.investTextSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color.investSurface)
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(Color.investBorder.opacity(0.6), lineWidth: 1)
                )
        )
    }

    // MARK: - Reply composer (mentors only)

    private var replyComposerCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Your reply")
                .font(.headline)
                .foregroundStyle(Color.investTitle)

            TextEditor(text: $replyDraft)
                .frame(minHeight: 100)
                .scrollContentBackground(.hidden)
                .padding(10)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color.investBackground)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .stroke(Color.investBorder, lineWidth: 1)
                        )
                )
                .focused($replyFieldFocused)

            if let error = viewModel.replyErrorMessage {
                Text(error)
                    .font(.footnote)
                    .foregroundStyle(.red)
            }

            HStack {
                Spacer()
                Button {
                    let draft = replyDraft
                    viewModel.submitReply(
                        postId: currentPost.id,
                        asMentor: userId,
                        body: draft
                    ) {
                        replyDraft = ""
                        replyFieldFocused = false
                    }
                } label: {
                    if viewModel.isSubmittingReply {
                        ProgressView()
                            .padding(.horizontal, 12)
                    } else {
                        Label("Send Reply", systemImage: "paperplane.fill")
                    }
                }
                .buttonStyle(.borderedProminent)
                .tint(Color.investPrimary)
                .disabled(
                    replyDraft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                    || viewModel.isSubmittingReply
                )
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.investSurface)
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(Color.investBorder.opacity(0.6), lineWidth: 1)
                )
        )
    }
}

// MARK: - ReplyCard

private struct ReplyCard: View {
    let reply: ThreadReply
    let onUpvote: () -> Void

    private var isMentor: Bool { reply.authorRole == "mentor" }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: isMentor ? "checkmark.seal.fill" : "person.circle.fill")
                    .foregroundStyle(isMentor ? Color.investPrimary : Color.investTextSecondary)
                Text(reply.authorName)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.investTextPrimary)
                if isMentor {
                    Text("Mentor")
                        .font(.caption2.bold())
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Color.investHeroBand, in: Capsule())
                        .foregroundStyle(Color.investPrimary)
                }
                Spacer()
                UpvoteButton(count: reply.upvotes, action: onUpvote)
            }
            Text(reply.body)
                .font(.subheadline)
                .foregroundStyle(Color.investTextPrimary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(isMentor ? Color.investHeroBand.opacity(0.55) : Color.investSurface)
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(isMentor ? Color.investBorder : Color.investBorder.opacity(0.6),
                                lineWidth: 1)
                )
        )
    }
}

#Preview {
    NavigationStack {
        ThreadDetailView(
            post: ThreadPost(
                id: "p1",
                authorId: "u1",
                authorName: "Sofia Rodriguez",
                authorRole: "learner",
                category: "Financial",
                title: "How do I start investing?",
                body: "I can save $50/month — is it worth it?",
                upvotes: 24,
                replies: []
            ),
            viewModel: ThreadViewModel()
        )
    }
}
