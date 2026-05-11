//
//  MentorThreadView.swift
//  Group-14 — Features/MentorThread/Views
//
//  Reddit-style Q&A feed. Replaces the old MentorProfile/MentorProfileView.swift placeholder.
//

import SwiftUI

struct MentorThreadView: View {
    @StateObject private var viewModel = MentorThreadViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                Color.ascendBackground.ignoresSafeArea()

                Group {
                    if viewModel.isLoading {
                        ProgressView("Loading threads…")
                            .tint(.ascendAccent)
                            .foregroundColor(.ascendTextSecondary)
                    } else if let error = viewModel.errorMessage {
                        errorState(message: error)
                    } else {
                        feedList
                    }
                }
            }
            .navigationTitle("Mentor Q Thread")
            .navigationBarTitleDisplayMode(.large)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .task { viewModel.loadFeed() }
        }
    }

    // MARK: - Feed List

    private var feedList: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(viewModel.posts) { post in
                    PostCard(post: post)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
    }

    // MARK: - Error State

    private func errorState(message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "wifi.slash")
                .font(.system(size: 48))
                .foregroundColor(.ascendTextSecondary)
            Text("Couldn't load feed")
                .font(.title3.bold())
                .foregroundColor(.ascendTextPrimary)
            Text(message)
                .font(.caption)
                .foregroundColor(.ascendTextSecondary)
                .multilineTextAlignment(.center)
            Button("Retry") { viewModel.loadFeed() }
                .buttonStyle(.borderedProminent)
                .tint(.ascendAccent)
        }
        .padding(40)
    }
}

// MARK: - PostCard

struct PostCard: View {
    let post: ThreadPost
    @State private var isExpanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // ── Post Header ────────────────────────────────────────────────
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 10) {
                    authorAvatar(name: post.authorName, role: post.authorRole)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(post.authorName)
                            .font(.subheadline.bold())
                            .foregroundColor(.ascendTextPrimary)
                        Text(post.authorRole.capitalized + " · Ascend")
                            .font(.caption)
                            .foregroundColor(.ascendTextSecondary)
                    }

                    Spacer()

                    // Upvote badge
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.up")
                            .font(.caption.bold())
                        Text("\(post.upvotes)")
                            .font(.caption.bold())
                    }
                    .padding(.horizontal, 10).padding(.vertical, 5)
                    .background(Color.ascendPrimary.opacity(0.2))
                    .foregroundColor(.ascendAccent)
                    .clipShape(Capsule())
                }

                Text(post.title)
                    .font(.headline)
                    .foregroundColor(.ascendTextPrimary)
                    .fixedSize(horizontal: false, vertical: true)

                Text(post.body)
                    .font(.subheadline)
                    .foregroundColor(.ascendTextSecondary)
                    .lineLimit(isExpanded ? nil : 3)
                    .fixedSize(horizontal: false, vertical: true)

                if !isExpanded {
                    Button("Read more") {
                        withAnimation(.spring(response: 0.35)) { isExpanded = true }
                    }
                    .font(.caption.bold())
                    .foregroundColor(.ascendAccent)
                }
            }
            .padding(18)

            // ── Replies ────────────────────────────────────────────────────
            if !post.replies.isEmpty {
                Divider().background(Color.ascendBackground).padding(.horizontal, 18)

                VStack(alignment: .leading, spacing: 14) {
                    Label("\(post.replies.count) mentor reply", systemImage: "bubble.left.fill")
                        .font(.caption.bold())
                        .foregroundColor(.ascendAccent)

                    ForEach(post.replies) { reply in
                        ReplyRow(reply: reply)
                    }
                }
                .padding(18)
                .background(Color.ascendCard.opacity(0.5))
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.ascendSurface)
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(Color.ascendPrimary.opacity(0.2), lineWidth: 1)
                )
        )
        .shadow(color: .black.opacity(0.2), radius: 8, y: 4)
    }

    private func authorAvatar(name: String, role: String) -> some View {
        ZStack {
            Circle()
                .fill(role == "mentor"
                    ? LinearGradient(colors: [.ascendPrimary, .ascendAccent], startPoint: .topLeading, endPoint: .bottomTrailing)
                    : LinearGradient(colors: [.ascendSurface, .ascendCard], startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(width: 38, height: 38)

            Text(name.split(separator: " ").prefix(2).compactMap { $0.first.map(String.init) }.joined())
                .font(.caption.bold())
                .foregroundColor(.white)
        }
    }
}

// MARK: - ReplyRow

struct ReplyRow: View {
    let reply: ThreadReply

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Mentor accent stripe
            RoundedRectangle(cornerRadius: 2)
                .fill(reply.authorRole == "mentor" ? Color.ascendAccent : Color.ascendTextSecondary)
                .frame(width: 3)
                .padding(.vertical, 2)

            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(reply.authorName)
                        .font(.caption.bold())
                        .foregroundColor(reply.authorRole == "mentor" ? .ascendAccent : .ascendTextPrimary)

                    if reply.authorRole == "mentor" {
                        Label("Mentor", systemImage: "checkmark.seal.fill")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundColor(.ascendAccent)
                            .padding(.horizontal, 6).padding(.vertical, 2)
                            .background(Color.ascendAccent.opacity(0.15))
                            .clipShape(Capsule())
                    }

                    Spacer()

                    HStack(spacing: 3) {
                        Image(systemName: "arrow.up").font(.system(size: 9, weight: .bold))
                        Text("\(reply.upvotes)").font(.system(size: 10, weight: .bold))
                    }
                    .foregroundColor(.ascendTextSecondary)
                }

                Text(reply.body)
                    .font(.subheadline)
                    .foregroundColor(.ascendTextSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

#Preview {
    MentorThreadView()
        .preferredColorScheme(.dark)
}
