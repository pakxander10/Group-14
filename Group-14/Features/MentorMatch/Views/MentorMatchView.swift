//
//  MentorMatchView.swift
//  Group-14 — Features/MentorMatch/Views
//

import SwiftUI

struct MentorMatchView: View {
    @State private var selectedTrack: String? = nil

    var body: some View {
        NavigationStack {
            ZStack {
                Color.ascendBackground.ignoresSafeArea()

                VStack(spacing: 32) {
                    VStack(spacing: 8) {
                        Text("What do you need most right now?")
                            .font(.title2.bold())
                            .foregroundColor(.ascendTextPrimary)
                            .multilineTextAlignment(.center)
                        Text("We'll match you with the right mentor for your journey.")
                            .font(.subheadline)
                            .foregroundColor(.ascendTextSecondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 48)
                    .padding(.horizontal, 24)

                    VStack(spacing: 16) {
                        NavigationLink(destination: FinancialMatchView()) {
                            TrackCard(
                                emoji: "💰",
                                title: "Financial Guidance",
                                subtitle: "Budgeting, investing, my first paycheck, loans",
                                color: .trackFinancial
                            )
                        }

                        NavigationLink(destination: CareerMatchView()) {
                            TrackCard(
                                emoji: "💻",
                                title: "Career Mentorship",
                                subtitle: "Breaking into finance or tech, landing my first role",
                                color: .trackTech
                            )
                        }
                    }
                    .padding(.horizontal, 20)

                    Spacer()
                }
            }
            .navigationTitle("Find Your Mentor")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

private struct TrackCard: View {
    let emoji: String
    let title: String
    let subtitle: String
    let color: Color

    var body: some View {
        HStack(spacing: 20) {
            Text(emoji)
                .font(.system(size: 40))
                .frame(width: 64, height: 64)
                .background(color.opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: 16))

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.ascendTextPrimary)
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(.ascendTextSecondary)
                    .multilineTextAlignment(.leading)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundColor(.ascendTextSecondary)
                .font(.subheadline)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.ascendSurface)
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(color.opacity(0.4), lineWidth: 1.5)
                )
        )
    }
}

#Preview {
    MentorMatchView()
}
