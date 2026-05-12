//
//  InboxView.swift
//  Group-14 — Features/MentorThread/Views
//
//  Learner-only inbox of mentor-reply notifications.
//

import SwiftUI

struct InboxView: View {
    @StateObject private var viewModel = InboxViewModel()
    @AppStorage("userId") private var userId: String = ""

    var body: some View {
        NavigationStack {
            content
                .navigationTitle("Inbox")
                .navigationBarTitleDisplayMode(.large)
                .task(id: userId) { viewModel.loadInbox(learnerId: userId) }
                .refreshable { viewModel.loadInbox(learnerId: userId) }
        }
    }

    @ViewBuilder
    private var content: some View {
        if viewModel.isLoading && viewModel.notifications.isEmpty {
            ProgressView("Loading…")
        } else if let error = viewModel.errorMessage, viewModel.notifications.isEmpty {
            errorState(message: error)
        } else if viewModel.notifications.isEmpty {
            emptyState
        } else {
            List(viewModel.notifications) { notification in
                NotificationRow(notification: notification)
                    .listRowInsets(.init(top: 10, leading: 16, bottom: 10, trailing: 16))
            }
            .listStyle(.insetGrouped)
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "tray")
                .font(.system(size: 44))
                .foregroundStyle(.secondary)
            Text("No notifications yet")
                .font(.headline)
            Text("When a mentor replies to one of your questions, you'll see it here.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(40)
    }

    private func errorState(message: String) -> some View {
        VStack(spacing: 12) {
            Image(systemName: "wifi.slash")
                .font(.system(size: 40))
                .foregroundStyle(.secondary)
            Text("Couldn't load inbox")
                .font(.headline)
            Text(message)
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            Button("Retry") { viewModel.loadInbox(learnerId: userId) }
                .buttonStyle(.borderedProminent)
        }
        .padding(32)
    }
}

// MARK: - NotificationRow

private struct NotificationRow: View {
    let notification: InboxNotification

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            avatar
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 6) {
                    Text(notification.mentorName)
                        .font(.subheadline.weight(.semibold))
                    Text("replied to your question")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Text("\u{201C}\(notification.postTitle)\u{201D}")
                    .font(.footnote.weight(.medium))
                    .foregroundStyle(.primary)
                    .lineLimit(2)
                Text(notification.replyPreview)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .lineLimit(3)
                if let formatted = formattedTimestamp(notification.createdAt) {
                    Text(formatted)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.vertical, 4)
    }

    private var avatar: some View {
        ZStack {
            Circle()
                .fill(.tint.opacity(0.15))
                .frame(width: 38, height: 38)
            Image(systemName: "checkmark.seal.fill")
                .foregroundStyle(.tint)
        }
    }

    private func formattedTimestamp(_ iso: String) -> String? {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        let date = formatter.date(from: iso) ?? ISO8601DateFormatter().date(from: iso)
        guard let date else { return nil }
        let relative = RelativeDateTimeFormatter()
        relative.unitsStyle = .short
        return relative.localizedString(for: date, relativeTo: Date())
    }
}

#Preview {
    InboxView()
}
