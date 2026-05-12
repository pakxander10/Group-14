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
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                header
                Divider()
                repliesSection

                if isMentor {
                    Divider()
                    replyComposer
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
        .navigationTitle("Question")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Header

    private var header: some View {
        VStack(alignment: .leading, spacing: 12) {
            CategoryBadge(category: currentPost.category)

            Text(currentPost.title)
                .font(.title2.bold())
                .foregroundStyle(.primary)

            HStack(spacing: 8) {
                Image(systemName: "person.circle.fill")
                    .foregroundStyle(.secondary)
                Text(currentPost.authorName)
                    .font(.caption.weight(.semibold))
                Text("· Learner")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                UpvoteButton(count: currentPost.upvotes) {
                    viewModel.upvotePost(id: currentPost.id)
                }
            }

            Text(currentPost.body)
                .font(.body)
                .foregroundStyle(.primary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    // MARK: - Replies

    private var repliesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Replies (\(currentPost.replies.count))")
                .font(.headline)

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
                .foregroundStyle(.secondary)
            Text("No replies yet.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(uiColor: .secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Reply composer (mentors only)

    private var replyComposer: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Your reply")
                .font(.headline)

            TextEditor(text: $replyDraft)
                .frame(minHeight: 100)
                .padding(8)
                .background(Color(uiColor: .secondarySystemGroupedBackground),
                            in: RoundedRectangle(cornerRadius: 12))
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
                .disabled(
                    replyDraft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                    || viewModel.isSubmittingReply
                )
            }
        }
    }
}

// MARK: - ReplyCard

private struct ReplyCard: View {
    let reply: ThreadReply
    let onUpvote: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: reply.authorRole == "mentor"
                      ? "checkmark.seal.fill"
                      : "person.circle.fill")
                    .foregroundStyle(reply.authorRole == "mentor"
                                     ? AnyShapeStyle(.tint)
                                     : AnyShapeStyle(.secondary))
                Text(reply.authorName)
                    .font(.subheadline.weight(.semibold))
                if reply.authorRole == "mentor" {
                    Text("Mentor")
                        .font(.caption2.bold())
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(.tint.opacity(0.15), in: Capsule())
                        .foregroundStyle(.tint)
                }
                Spacer()
                UpvoteButton(count: reply.upvotes, action: onUpvote)
            }
            Text(reply.body)
                .font(.subheadline)
                .foregroundStyle(.primary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(uiColor: .secondarySystemGroupedBackground),
                    in: RoundedRectangle(cornerRadius: 12))
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
