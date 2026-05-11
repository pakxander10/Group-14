//
//  ProfileView.swift
//  Group-14 — Features/Profile/Views
//

import SwiftUI

struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                Color.ascendBackground.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        // ── Header Card ──────────────────────────────────
                        headerCard

                        // ── Info Grid ─────────────────────────────────────
                        if let learner = viewModel.learner {
                            infoGrid(learner: learner)
                        }

                        Spacer(minLength: 40)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                }
            }
            .navigationTitle("")
            .navigationBarHidden(true)
            .task { viewModel.loadProfile() }
            .overlay {
                if viewModel.isLoading {
                    ProgressView()
                        .tint(.ascendAccent)
                        .scaleEffect(1.4)
                }
            }
        }
    }

    // MARK: - Subviews

    private var headerCard: some View {
        VStack(spacing: 16) {
            // Avatar
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.ascendPrimary, .ascendAccent],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 96, height: 96)

                Text(viewModel.learner?.name.initials ?? "SR")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
            }
            .shadow(color: .ascendPrimary.opacity(0.5), radius: 16)

            VStack(spacing: 4) {
                Text(viewModel.learner?.name ?? "Sofia Rodriguez")
                    .font(.title2.bold())
                    .foregroundColor(.ascendTextPrimary)

                Text("Learner · Ascend Member")
                    .font(.subheadline)
                    .foregroundColor(.ascendTextSecondary)
            }

            // Role Badge
            Label("First-Generation Student", systemImage: "star.fill")
                .font(.caption.bold())
                .padding(.horizontal, 14)
                .padding(.vertical, 6)
                .background(Color.ascendPrimary.opacity(0.25))
                .foregroundColor(.ascendAccent)
                .clipShape(Capsule())
        }
        .frame(maxWidth: .infinity)
        .padding(28)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color.ascendSurface)
                .overlay(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .stroke(Color.ascendPrimary.opacity(0.3), lineWidth: 1)
                )
        )
    }

    private func infoGrid(learner: LearnerProfile) -> some View {
        LazyVGrid(columns: [.init(.flexible()), .init(.flexible())], spacing: 16) {
            infoCell(icon: "heart.fill", label: "Interest",
                     value: learner.interest.capitalized)
            infoCell(icon: "flag.fill", label: "Goal",
                     value: learner.goal.replacingOccurrences(of: "_", with: " ").capitalized)
            infoCell(icon: "person.2.fill", label: "Background",
                     value: learner.background == "first_gen" ? "First-Gen" : "General")
            infoCell(icon: "chart.bar.fill", label: "Confidence",
                     value: "\(learner.confidenceScore) / 1000")
        }
    }

    private func infoCell(icon: String, label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.ascendAccent)
                    .font(.caption)
                Text(label)
                    .font(.caption)
                    .foregroundColor(.ascendTextSecondary)
            }
            Text(value)
                .font(.subheadline.bold())
                .foregroundColor(.ascendTextPrimary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.ascendCard)
        )
    }
}

// MARK: - String Extension

private extension String {
    var initials: String {
        split(separator: " ")
            .prefix(2)
            .compactMap { $0.first.map(String.init) }
            .joined()
            .uppercased()
    }
}

#Preview {
    ProfileView()
        .preferredColorScheme(.dark)
}
