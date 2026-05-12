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
            ZStack {
                Color.investBackground.ignoresSafeArea()
                content
            }
            .navigationTitle("Inbox")
            .navigationBarTitleDisplayMode(.large)
            .task(id: userId) { viewModel.loadInbox(learnerId: userId) }
            .refreshable { viewModel.loadInbox(learnerId: userId) }
        }
        .tint(Color.investPrimary)
    }

    @ViewBuilder
    private var content: some View {
        if viewModel.isLoading && viewModel.notifications.isEmpty {
            ProgressView("Loading…")
                .tint(Color.investPrimary)
        } else if let error = viewModel.errorMessage, viewModel.notifications.isEmpty {
            errorState(message: error)
        } else if viewModel.notifications.isEmpty {
            emptyState
        } else {
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(viewModel.notifications) { notification in
                        NotificationCard(notification: notification)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 24)
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "tray")
                .font(.system(size: 44))
                .foregroundStyle(Color.investTextSecondary)
            Text("No notifications yet")
                .font(.headline)
                .foregroundStyle(Color.investTitle)
            Text("When a mentor replies to one of your questions, you'll see it here.")
                .font(.subheadline)
                .foregroundStyle(Color.investTextSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(40)
    }

    private func errorState(message: String) -> some View {
        VStack(spacing: 12) {
            Image(systemName: "wifi.slash")
                .font(.system(size: 40))
                .foregroundStyle(Color.investTextSecondary)
            Text("Couldn't load inbox")
                .font(.headline)
                .foregroundStyle(Color.investTitle)
            Text(message)
                .font(.caption)
                .foregroundStyle(Color.investTextSecondary)
                .multilineTextAlignment(.center)
            Button("Retry") { viewModel.loadInbox(learnerId: userId) }
                .buttonStyle(.borderedProminent)
                .tint(Color.investPrimary)
        }
        .padding(32)
    }
}

// MARK: - NotificationCard

private struct NotificationCard: View {
    let notification: InboxNotification

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            avatar
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 6) {
                    Text(notification.mentorName)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color.investTextPrimary)
                    Text("replied to your question")
                        .font(.subheadline)
                        .foregroundStyle(Color.investTextSecondary)
                    Spacer(minLength: 0)
                    Circle()
                        .fill(Color.investPrimary)
                        .frame(width: 8, height: 8)
                }
                Text("\u{201C}\(notification.postTitle)\u{201D}")
                    .font(.footnote.weight(.medium))
                    .foregroundStyle(Color.investTitle)
                    .lineLimit(2)
                Text(notification.replyPreview)
                    .font(.footnote)
                    .foregroundStyle(Color.investTextSecondary)
                    .lineLimit(3)
                if let formatted = formattedTimestamp(notification.createdAt) {
                    Text(formatted)
                        .font(.caption2)
                        .foregroundStyle(Color.investTextSecondary)
                }
            }
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

    private var avatar: some View {
        ZStack {
            Circle()
                .fill(Color.investHeroBand)
                .frame(width: 40, height: 40)
            Image(systemName: "checkmark.seal.fill")
                .foregroundStyle(Color.investPrimary)
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
