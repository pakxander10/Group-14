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
            content
                .navigationTitle("Q Thread")
                .navigationBarTitleDisplayMode(.large)
                .toolbar {
                    if isLearner {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button {
                                isComposingPost = true
                            } label: {
                                Label("Ask a Question", systemImage: "plus.circle.fill")
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
    }

    // MARK: - Content

    @ViewBuilder
    private var content: some View {
        if viewModel.isLoading && viewModel.posts.isEmpty {
            ProgressView("Loading…")
        } else if let error = viewModel.errorMessage, viewModel.posts.isEmpty {
            errorState(message: error)
        } else {
            feedList
        }
    }

    private var feedList: some View {
        List {
            ForEach(viewModel.posts) { post in
                NavigationLink {
                    ThreadDetailView(post: post, viewModel: viewModel)
                } label: {
                    PostRow(post: post)
                }
                .listRowInsets(.init(top: 8, leading: 16, bottom: 8, trailing: 16))
            }
        }
        .listStyle(.insetGrouped)
    }

    private func errorState(message: String) -> some View {
        VStack(spacing: 12) {
            Image(systemName: "wifi.slash")
                .font(.system(size: 40))
                .foregroundStyle(.secondary)
            Text("Couldn't load feed")
                .font(.headline)
            Text(message)
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            Button("Retry") { viewModel.loadFeed() }
                .buttonStyle(.borderedProminent)
        }
        .padding(32)
    }
}

// MARK: - PostRow

private struct PostRow: View {
    let post: ThreadPost

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                CategoryBadge(category: post.category)
                Spacer()
                Label("\(post.replies.count)", systemImage: "bubble.left.fill")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Text(post.title)
                .font(.headline)
                .foregroundStyle(.primary)
                .lineLimit(2)

            Text(post.body)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(3)

            HStack(spacing: 6) {
                Image(systemName: "person.circle.fill")
                    .foregroundStyle(.secondary)
                Text(post.authorName)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.top, 2)
        }
        .padding(.vertical, 6)
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
            .background(.tint.opacity(0.15), in: Capsule())
            .foregroundStyle(.tint)
    }

    private var icon: String {
        switch category {
        case ThreadCategory.tech.rawValue:      return "laptopcomputer"
        case ThreadCategory.financial.rawValue: return "dollarsign.circle"
        default:                                return "tag"
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
            Form {
                Section("Category") {
                    Picker("Category", selection: $viewModel.newPostCategory) {
                        ForEach(ThreadCategory.allCases, id: \.self) { category in
                            Text(category.displayName).tag(category)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section("Title") {
                    TextField("e.g. How do I start investing?", text: $viewModel.newPostTitle)
                }

                Section("Question") {
                    TextEditor(text: $viewModel.newPostBody)
                        .frame(minHeight: 140)
                }

                if let error = viewModel.postErrorMessage {
                    Section {
                        Text(error)
                            .font(.footnote)
                            .foregroundStyle(.red)
                    }
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
    }
}

#Preview {
    ThreadFeedView()
}
