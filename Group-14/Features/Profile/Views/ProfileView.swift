//
//  ProfileView.swift
//  Group-14 — Features/Profile/Views
//

import SwiftUI

struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    @AppStorage("userId")   private var userId:   String = ""
    @AppStorage("userRole") private var userRole: String = ""
    @State private var showingSignOutConfirmation = false

    private var isMentor: Bool { userRole == UserRole.mentor.storageValue }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.ascendBackground.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        if isMentor {
                            mentorContent
                        } else {
                            learnerContent
                        }

                        signOutButton
                        Spacer(minLength: 40)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                }
            }
            .navigationTitle("")
            .navigationBarHidden(true)
            .task(id: "\(userRole)|\(userId)") {
                guard !userId.isEmpty else { return }
                if isMentor {
                    viewModel.loadMentor(userId: userId)
                } else {
                    viewModel.loadLearner(userId: userId)
                }
            }
            .overlay {
                if viewModel.isLoading {
                    ProgressView()
                        .tint(.ascendAccent)
                        .scaleEffect(1.4)
                }
            }
        }
    }

    // MARK: - Sign Out

    private var signOutButton: some View {
        Button(role: .destructive) {
            showingSignOutConfirmation = true
        } label: {
            Label("Sign Out", systemImage: "rectangle.portrait.and.arrow.right")
                .font(.subheadline.bold())
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color.ascendSurface)
                )
                .foregroundColor(.red)
        }
        .padding(.top, 8)
        .confirmationDialog(
            "Sign out of Ascend?",
            isPresented: $showingSignOutConfirmation,
            titleVisibility: .visible
        ) {
            Button("Sign Out", role: .destructive) {
                userId = ""
                userRole = ""
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("You'll be returned to the welcome screen.")
        }
    }

    // MARK: - Learner

    @ViewBuilder
    private var learnerContent: some View {
        learnerHeaderCard
        if let learner = viewModel.learner {
            learnerInfoGrid(learner: learner)
        }
    }

    private var learnerHeaderCard: some View {
        VStack(spacing: 16) {
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

                Text(viewModel.learner?.name.initials ?? "—")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
            }
            .shadow(color: .ascendPrimary.opacity(0.5), radius: 16)

            VStack(spacing: 4) {
                Text(viewModel.learner?.name ?? "Loading…")
                    .font(.title2.bold())
                    .foregroundColor(.ascendTextPrimary)

                Text("Learner · Ascend Member")
                    .font(.subheadline)
                    .foregroundColor(.ascendTextSecondary)
            }

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

    private func learnerInfoGrid(learner: LearnerProfile) -> some View {
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

    // MARK: - Mentor

    @ViewBuilder
    private var mentorContent: some View {
        mentorHeaderCard
        if let mentor = viewModel.mentor {
            mentorDetails(mentor: mentor)
        }
    }

    private var mentorHeaderCard: some View {
        VStack(spacing: 16) {
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

                Text(viewModel.mentor?.avatarInitials ?? "—")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
            }
            .shadow(color: .ascendPrimary.opacity(0.5), radius: 16)

            VStack(spacing: 4) {
                Text(viewModel.mentor?.name ?? "Loading…")
                    .font(.title2.bold())
                    .foregroundColor(.ascendTextPrimary)

                Text(viewModel.mentor.map { "\($0.title) · \($0.company)" } ?? "Mentor · Ascend")
                    .font(.subheadline)
                    .foregroundColor(.ascendTextSecondary)
                    .multilineTextAlignment(.center)
            }

            if let track = viewModel.mentor?.track {
                Label(track, systemImage: "sparkles")
                    .font(.caption.bold())
                    .padding(.horizontal, 14)
                    .padding(.vertical, 6)
                    .background(Color.ascendPrimary.opacity(0.25))
                    .foregroundColor(.ascendAccent)
                    .clipShape(Capsule())
            }
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

    private func mentorDetails(mentor: MentorProfile) -> some View {
        VStack(spacing: 16) {
            LazyVGrid(columns: [.init(.flexible()), .init(.flexible())], spacing: 16) {
                infoCell(icon: "briefcase.fill", label: "Experience",
                         value: "\(mentor.yearsExperience) yrs")
                infoCell(icon: "sparkles", label: "Track",
                         value: mentor.track)
            }

            sectionCard(title: "Bio") {
                Text(mentor.bio)
                    .font(.subheadline)
                    .foregroundColor(.ascendTextPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            sectionCard(title: "Expertise") {
                Text(mentor.expertise.joined(separator: " · "))
                    .font(.subheadline)
                    .foregroundColor(.ascendTextPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            if let education = mentor.educationHistory, !education.isEmpty {
                sectionCard(title: "Education") {
                    VStack(alignment: .leading, spacing: 4) {
                        ForEach(education, id: \.self) { entry in
                            Text("• \(entry)")
                                .font(.subheadline)
                                .foregroundColor(.ascendTextPrimary)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
    }

    private func sectionCard<Content: View>(title: String,
                                            @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption.bold())
                .foregroundColor(.ascendTextSecondary)
            content()
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.ascendCard)
        )
    }

    // MARK: - Shared

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
