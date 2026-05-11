import SwiftUI

struct MentorThreadView: View {
    @StateObject private var vm = MentorThreadViewModel()

    var body: some View {
        NavigationStack {
            Group {
                if vm.isLoading && vm.posts.isEmpty {
                    ProgressView()
                } else {
                    List {
                        ForEach(vm.posts) { post in
                            NavigationLink(value: post) {
                                PostRow(post: post)
                            }
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Mentor Q Thread")
            .navigationDestination(for: ThreadPost.self) { ThreadDetailView(post: $0) }
            .task { await vm.loadFeed() }
            .refreshable { await vm.loadFeed() }
        }
    }
}

private struct PostRow: View {
    let post: ThreadPost
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(post.title).font(.headline)
            Text(post.body).font(.subheadline).lineLimit(2).foregroundStyle(.secondary)
            HStack(spacing: 8) {
                Label(post.authorName, systemImage: "person.fill")
                Label("\(post.replies.count)", systemImage: "bubble.right")
                ForEach(post.tags, id: \.self) { tag in
                    Text("#\(tag)")
                        .font(.caption2)
                        .padding(.horizontal, 6).padding(.vertical, 2)
                        .background(Color.indigo.opacity(0.1))
                        .clipShape(Capsule())
                }
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }
}

private struct ThreadDetailView: View {
    let post: ThreadPost
    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    Text(post.title).font(.title3).bold()
                    Text("by \(post.authorName)").font(.caption).foregroundStyle(.secondary)
                    Text(post.body).padding(.top, 4)
                }
            }
            Section("Replies (\(post.replies.count))") {
                ForEach(post.replies) { r in
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(r.authorName).bold()
                            Text("· \(r.authorRole)")
                                .font(.caption).foregroundStyle(.secondary)
                        }
                        Text(r.body)
                    }
                }
            }
        }
        .navigationTitle("Thread")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview { MentorThreadView() }
