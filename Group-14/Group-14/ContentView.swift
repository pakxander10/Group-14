//
//  ContentView.swift
//  Group-14
//
//  Root router — shows the profile-type selector, then navigates
//  to LearnerOnboardingView (Xander) or MentorOnboardingView (partner).
//

import SwiftUI

struct ContentView: View {
    /// nil = not chosen yet; set after ProfileTypeSelectionView fires onSelect
    @State private var selectedRole: ProfileType? = nil
    @State private var onboardingComplete = false

    var body: some View {
        Group {
            if onboardingComplete {
                // Both flows land here — the main app experience
                MainTabView()
                    .transition(.move(edge: .trailing).combined(with: .opacity))
            } else if let role = selectedRole {
                switch role {
                case .learner:
                    // ── YOUR code (Xander) ──────────────────────────────
                    LearnerOnboardingView {
                        withAnimation { onboardingComplete = true }
                    }
                    .transition(.move(edge: .trailing).combined(with: .opacity))

                case .mentor:
                    // ── PARTNER's code ──────────────────────────────────
                    // Replace this placeholder with MentorOnboardingView()
                    // once your partner creates it on their branch.
                    MentorOnboardingPlaceholder {
                        withAnimation { onboardingComplete = true }
                    }
                    .transition(.move(edge: .trailing).combined(with: .opacity))
                }
            } else {
                ProfileTypeSelectionView { type in
                    withAnimation(.easeInOut(duration: 0.35)) {
                        selectedRole = type
                    }
                }
            }
        }
        .animation(.easeInOut(duration: 0.35), value: selectedRole)
        .animation(.easeInOut(duration: 0.35), value: onboardingComplete)
        .preferredColorScheme(.dark)
    }
}

// MARK: - Mentor Placeholder
// DELETE this and replace with MentorOnboardingView once partner's branch is merged.

struct MentorOnboardingPlaceholder: View {
    let onComplete: () -> Void
    var body: some View {
        ZStack {
            Color.ascendBackground.ignoresSafeArea()
            VStack(spacing: 20) {
                Text("🏅").font(.system(size: 64))
                Text("Mentor Onboarding")
                    .font(.largeTitle.bold()).foregroundColor(.ascendTextPrimary)
                Text("Your partner is building this screen.\nCome back after merging their branch.")
                    .font(.subheadline).foregroundColor(.ascendTextSecondary)
                    .multilineTextAlignment(.center)
                Button("Skip for now →") { onComplete() }
                    .buttonStyle(.borderedProminent).tint(.ascendAccent)
            }
            .padding(40)
        }
    }
}

#Preview {
    ContentView()
}
