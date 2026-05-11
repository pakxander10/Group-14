//
//  ProfileTypeSelectionView.swift
//  Group-14 — Features/Onboarding/Views
//
//  SHARED ENTRY POINT — agreed upon by both developers.
//  This file should not be modified after both features are in progress.
//
//  Contract: calls onSelect(.learner) or onSelect(.mentor) and navigates out.
//  Neither developer needs to touch this file after initial setup.
//

import SwiftUI

// MARK: - ProfileType

enum ProfileType {
    case learner
    case mentor
}

// MARK: - ProfileTypeSelectionView

struct ProfileTypeSelectionView: View {
    /// Callback handed down from the parent (e.g. MainTabView / app root).
    /// The parent decides where to navigate — this view only selects.
    let onSelect: (ProfileType) -> Void

    @State private var hoveredType: ProfileType?

    var body: some View {
        ZStack {
            Color.ascendBackground.ignoresSafeArea()

            VStack(spacing: 40) {
                // ── Header ─────────────────────────────────────────────
                VStack(spacing: 10) {
                    Text("Welcome to Ascend")
                        .font(.largeTitle.bold())
                        .foregroundColor(.ascendTextPrimary)
                    Text("How will you use the app?")
                        .font(.subheadline)
                        .foregroundColor(.ascendTextSecondary)
                }
                .padding(.top, 60)

                // ── Role Cards ─────────────────────────────────────────
                VStack(spacing: 20) {
                    roleCard(
                        type: .learner,
                        emoji: "🌱",
                        title: "I'm a Learner",
                        subtitle: "I'm a young woman or first-gen student looking for financial and career guidance.",
                        gradient: [.ascendPrimary, .ascendAccent]
                    )

                    roleCard(
                        type: .mentor,
                        emoji: "🏅",
                        title: "I'm a Mentor",
                        subtitle: "I'm a Fidelity professional ready to share my knowledge and guide the next generation.",
                        gradient: [.trackFinancial, .trackTech]
                    )
                }
                .padding(.horizontal, 24)

                Spacer()
            }
        }
    }

    // MARK: - Role Card

    private func roleCard(
        type: ProfileType,
        emoji: String,
        title: String,
        subtitle: String,
        gradient: [Color]
    ) -> some View {
        Button {
            withAnimation(.spring(response: 0.4)) {
                onSelect(type)
            }
        } label: {
            HStack(spacing: 20) {
                // Emoji bubble
                ZStack {
                    Circle()
                        .fill(LinearGradient(colors: gradient, startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 64, height: 64)
                    Text(emoji)
                        .font(.system(size: 28))
                }
                .shadow(color: gradient.first?.opacity(0.4) ?? .clear, radius: 10)

                // Text
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.ascendTextPrimary)
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.ascendTextSecondary)
                        .multilineTextAlignment(.leading)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.subheadline.bold())
                    .foregroundColor(.ascendTextSecondary)
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Color.ascendSurface)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .stroke(
                                LinearGradient(colors: gradient, startPoint: .topLeading, endPoint: .bottomTrailing),
                                lineWidth: 1.5
                            )
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ProfileTypeSelectionView { type in
        print("Selected: \(type)")
    }
    .preferredColorScheme(.dark)
}
