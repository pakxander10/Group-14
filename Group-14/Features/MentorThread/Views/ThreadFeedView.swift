//
//  ThreadFeedView.swift
//  Group-14 — Features/MentorThread/Views
//
//  Reddit-style feed of learner questions + mentor replies. Conditional UI:
//  learners see an "Ask a Question" button; mentors do not.
//

import SwiftUI

struct ThreadFeedView: View {
    @StateObject private var viewModel = ThreadViewModel()
    @AppStorage("userId")   private var userId:   String = ""
    @AppStorage("userRole") private var userRole: String = ""

    @State private var isComposingPost = false

    private var isLearner: Bool { userRole == UserRole.learner.storageValue }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.investBackground.ignoresSafeArea()
                content
            }
            .navigationTitle("Q Thread")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Q Thread")
                        .font(.headline.weight(.bold))
                        .foregroundStyle(Color.investPrimary)
                }
                if isLearner {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            isComposingPost = true
                        } label: {
                            Label("Ask a Question", systemImage: "plus.circle.fill")
                                .foregroundStyle(Color.investPrimary)
                        }
                    }
                }
            }
            .sheet(isPresented: $isComposingPost) {
                ComposePostSheet(viewModel: viewModel, userId: userId)
            }
            .task { viewModel.loadFeed() }
            .refreshable { viewModel.loadFeed() }
        }
        .tint(Color.investPrimary)
    }

    // MARK: - Content

    @ViewBuilder
    private var content: some View {
        if viewModel.isLoading && viewModel.posts.isEmpty {
            ProgressView("Loading…")
                .tint(Color.investPrimary)
        } else if let error = viewModel.errorMessage, viewModel.posts.isEmpty {
            errorState(message: error)
        } else {
            feedList
        }
    }

    private var feedList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(viewModel.posts) { post in
                    NavigationLink {
                        ThreadDetailView(post: post, viewModel: viewModel)
                    } label: {
                        PostCard(
                            post: post,
                            hasUpvoted: viewModel.hasUpvotedPost(post.id, by: userId)
                        ) {
                            viewModel.upvotePost(id: post.id, by: userId)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 24)
        }
    }

    private func errorState(message: String) -> some View {
        VStack(spacing: 12) {
            Image(systemName: "wifi.slash")
                .font(.system(size: 40))
                .foregroundStyle(Color.investTextSecondary)
            Text("Couldn't load feed")
                .font(.headline)
                .foregroundStyle(Color.investTitle)
            Text(message)
                .font(.caption)
                .foregroundStyle(Color.investTextSecondary)
                .multilineTextAlignment(.center)
            Button("Retry") { viewModel.loadFeed() }
                .buttonStyle(.borderedProminent)
                .tint(Color.investPrimary)
        }
        .padding(32)
    }
}

// MARK: - PostCard

private struct PostCard: View {
    let post: ThreadPost
    let hasUpvoted: Bool
    let onUpvote: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                CategoryBadge(category: post.category)
                Spacer()
                Label("\(post.replies.count)", systemImage: "bubble.left.fill")
                    .font(.caption)
                    .foregroundStyle(Color.investTextSecondary)
            }

            Text(post.title)
                .font(.headline)
                .foregroundStyle(Color.investTitle)
                .lineLimit(2)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text(post.body)
                .font(.subheadline)
                .foregroundStyle(Color.investTextSecondary)
                .lineLimit(3)
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: 12) {
                HStack(spacing: 6) {
                    Image(systemName: "person.circle.fill")
                        .foregroundStyle(Color.investTextSecondary)
                    Text(post.authorName)
                        .font(.caption)
                        .foregroundStyle(Color.investTextSecondary)
                }
                Spacer()
                UpvoteButton(count: post.upvotes, hasUpvoted: hasUpvoted, action: onUpvote)
            }
            .padding(.top, 2)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.investSurface)
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(Color.investBorder.opacity(0.6), lineWidth: 1)
                )
        )
    }
}

// MARK: - UpvoteButton

/// Reusable upvote control. `.buttonStyle(.borderless)` lets it live inside a
/// NavigationLink row without consuming the row's tap target.
struct UpvoteButton: View {
    let count: Int
    let hasUpvoted: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Label("\(count)", systemImage: hasUpvoted ? "arrow.up.circle.fill" : "arrow.up.circle")
                .font(.caption.weight(.semibold))
                .labelStyle(.titleAndIcon)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(
                    Capsule()
                        .fill(hasUpvoted ? Color.investPrimary : Color.investHeroBand)
                )
                .foregroundStyle(hasUpvoted ? Color.white : Color.investPrimary)
        }
        .buttonStyle(.borderless)
        .disabled(hasUpvoted)
        .accessibilityLabel(hasUpvoted ? "Upvoted, \(count) total" : "Upvote, \(count) total")
    }
}

// MARK: - CategoryBadge

struct CategoryBadge: View {
    let category: String

    var body: some View {
        Label(category, systemImage: icon)
            .font(.caption.weight(.semibold))
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(backgroundColor, in: Capsule())
            .foregroundStyle(foregroundColor)
    }

    private var icon: String {
        switch category {
        case ThreadCategory.tech.rawValue:      return "laptopcomputer"
        case ThreadCategory.financial.rawValue: return "dollarsign.circle"
        default:                                return "tag"
        }
    }

    private var foregroundColor: Color {
        switch category {
        case ThreadCategory.tech.rawValue:      return .trackTech
        case ThreadCategory.financial.rawValue: return .trackFinancial
        default:                                return .investAccent
        }
    }

    private var backgroundColor: Color {
        switch category {
        case ThreadCategory.tech.rawValue:      return .trackTechBg
        case ThreadCategory.financial.rawValue: return .trackFinancialBg
        default:                                return .investHeroBand
        }
    }
}

// MARK: - ComposePostSheet

private struct ComposePostSheet: View {
    @ObservedObject var viewModel: ThreadViewModel
    let userId: String
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                Color.investBackground.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 16) {
                        categoryCard
                        titleCard
                        questionCard

                        if let error = viewModel.postErrorMessage {
                            errorCard(message: error)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 20)
                }
            }
            .navigationTitle("Ask a Question")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        viewModel.resetComposer()
                        dismiss()
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        viewModel.submitPost(asLearner: userId) {
                            dismiss()
                        }
                    } label: {
                        if viewModel.isSubmittingPost {
                            ProgressView()
                        } else {
                            Text("Post").bold()
                        }
                    }
                    .disabled(!viewModel.canSubmitPost)
                }
            }
        }
        .tint(Color.investPrimary)
    }

    // MARK: - Section cards

    private var categoryCard: some View {
        sectionCard(title: "Category") {
            Picker("Category", selection: $viewModel.newPostCategory) {
                ForEach(ThreadCategory.allCases, id: \.self) { category in
                    Text(category.displayName).tag(category)
                }
            }
            .pickerStyle(.segmented)
        }
    }

    private var titleCard: some View {
        sectionCard(title: "Title") {
            TextField("e.g. How do I start investing?", text: $viewModel.newPostTitle)
                .textFieldStyle(InvestTextFieldStyle())
        }
    }

    private var questionCard: some View {
        sectionCard(title: "Question") {
            TextEditor(text: $viewModel.newPostBody)
                .frame(minHeight: 140)
                .scrollContentBackground(.hidden)
                .padding(10)
                .background(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(Color.investBackground)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .stroke(Color.investBorder, lineWidth: 1)
                        )
                )
                .foregroundStyle(Color.investTextPrimary)
        }
    }

    private func errorCard(message: String) -> some View {
        Text(message)
            .font(.footnote)
            .foregroundStyle(.red)
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color.investSurface)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(Color.red.opacity(0.4), lineWidth: 1)
                    )
            )
    }

    private func sectionCard<Content: View>(
        title: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title.uppercased())
                .font(.caption.weight(.bold))
                .foregroundStyle(Color.investAccent)
                .tracking(0.5)
            content()
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.investSurface)
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(Color.investBorder.opacity(0.6), lineWidth: 1)
                )
        )
    }
}

#Preview {
    ThreadFeedView()
}
