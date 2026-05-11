import SwiftUI

struct QAView: View {
    @State private var questionText = ""
    @State private var postWithName = true

    // TODO: replace with real posts from backend
    let mockPosts = [
        QAPost(authorInitials: "AJ", authorName: "Alex J.", timeAgo: "2h ago",
               question: "How do I start building an emergency fund when I'm living paycheck to paycheck?",
               likes: 12, replyCount: 1,
               mentorName: "Dr. Sarah Chen", mentorRole: "Principal Engineer at Fidelity"),
        QAPost(authorInitials: "MR", authorName: "Maya R.", timeAgo: "4h ago",
               question: "What's the difference between a Roth IRA and a traditional IRA as a college student?",
               likes: 8, replyCount: 2,
               mentorName: "James Kim, CFA", mentorRole: "Investment Analyst · Goldman"),
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {

                // Compose box
                AppCard {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack(spacing: 6) {
                            Image(systemName: "message.circle")
                                .foregroundColor(AppColors.primary)
                            Text("Ask a question")
                                .font(.system(size: 14, weight: .medium))
                        }

                        TextEditor(text: $questionText)
                            .font(.system(size: 13))
                            .foregroundColor(questionText.isEmpty ? AppColors.textTertiary : .primary)
                            .frame(minHeight: 70)
                            .padding(8)
                            .background(Color(hex: "#fafafa"))
                            .cornerRadius(10)
                            .overlay(RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray.opacity(0.15), lineWidth: 0.5))

                        HStack {
                            // Anonymous toggle
                            Button(action: { postWithName.toggle() }) {
                                HStack(spacing: 5) {
                                    Image(systemName: postWithName ? "eye" : "eye.slash")
                                        .font(.system(size: 12))
                                    Text(postWithName ? "With name" : "Anonymous")
                                        .font(.system(size: 12))
                                }
                                .foregroundColor(AppColors.textSecondary)
                                .padding(.horizontal, 10).padding(.vertical, 5)
                                .background(Color(hex: "#f5f5f5"))
                                .cornerRadius(10)
                            }

                            Spacer()

                            // Post button
                            Button(action: postQuestion) {
                                HStack(spacing: 4) {
                                    Image(systemName: "paperplane")
                                        .font(.system(size: 12))
                                    Text("Post")
                                        .font(.system(size: 13, weight: .medium))
                                }
                                .foregroundColor(.white)
                                .padding(.horizontal, 16).padding(.vertical, 7)
                                .background(questionText.isEmpty ? Color.gray.opacity(0.3) : AppColors.primary)
                                .cornerRadius(10)
                            }
                            .disabled(questionText.isEmpty)
                        }
                    }
                    .padding(14)
                }

                // Posts feed
                ForEach(mockPosts, id: \.authorName) { post in
                    QAPostCard(post: post)
                }

            }
            .padding(16)
        }
        .background(AppColors.bg)
    }

    func postQuestion() {
        // TODO: POST to backend
        questionText = ""
    }
}

struct QAPostCard: View {
    let post: QAPost

    var body: some View {
        AppCard {
            VStack(alignment: .leading, spacing: 8) {
                // Author row
                HStack(spacing: 8) {
                    Text(post.authorInitials)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(AppColors.primaryMid)
                        .frame(width: 30, height: 30)
                        .background(AppColors.primaryLight)
                        .clipShape(Circle())

                    VStack(alignment: .leading, spacing: 1) {
                        Text(post.authorName).font(.system(size: 13, weight: .medium))
                        Text(post.timeAgo).font(.system(size: 10)).foregroundColor(AppColors.textTertiary)
                    }
                    Spacer()
                }

                // Question text
                Text(post.question)
                    .font(.system(size: 13))
                    .lineSpacing(3)

                // Footer
                HStack(spacing: 14) {
                    HStack(spacing: 4) {
                        Image(systemName: "hand.thumbsup")
                            .font(.system(size: 12))
                        Text("\(post.likes)")
                            .font(.system(size: 12))
                    }
                    .foregroundColor(AppColors.textTertiary)

                    Text("\(post.replyCount) \(post.replyCount == 1 ? "reply" : "replies")")
                        .font(.system(size: 12))
                        .foregroundColor(AppColors.textTertiary)
                }

                // Mentor reply preview
                if let mentorName = post.mentorName {
                    HStack(spacing: 8) {
                        Text(String(mentorName.prefix(3).uppercased()))
                            .font(.system(size: 9, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 26, height: 26)
                            .background(AppColors.primary)
                            .cornerRadius(6)

                        VStack(alignment: .leading, spacing: 1) {
                            HStack(spacing: 5) {
                                Text(mentorName).font(.system(size: 12, weight: .medium))
                                Text("MENTOR")
                                    .font(.system(size: 9, weight: .semibold))
                                    .foregroundColor(AppColors.primary)
                                    .padding(.horizontal, 5).padding(.vertical, 1)
                                    .background(AppColors.primaryLight)
                                    .cornerRadius(4)
                            }
                            if let role = post.mentorRole {
                                Text(role).font(.system(size: 10)).foregroundColor(AppColors.textTertiary)
                            }
                        }
                    }
                    .padding(10)
                    .background(Color(hex: "#f9f9f9"))
                    .cornerRadius(10)
                }
            }
            .padding(14)
        }
    }
}
