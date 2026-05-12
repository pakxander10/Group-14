//
//  WelcomeView.swift
//  Group-14 — Features/Auth/Views
//
//  Entry point shown when no userRole is stored. Routes the user to
//  learner signup, mentor signup, or login.
//

import SwiftUI

enum WelcomeRoute: Hashable {
    case learnerSignup
    case mentorSignup
    case login
}

struct WelcomeView: View {
    @State private var route: WelcomeRoute?

    var body: some View {
        NavigationStack {
            ZStack {
                Color.ascendBackground.ignoresSafeArea()

                VStack(spacing: 32) {
                    Spacer()

                    VStack(spacing: 12) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 56))
                            .foregroundColor(.ascendAccent)
                        Text("Welcome to Ascend")
                            .font(.largeTitle.bold())
                            .foregroundColor(.ascendTextPrimary)
                        Text("Choose how you'd like to get started.")
                            .font(.subheadline)
                            .foregroundColor(.ascendTextSecondary)
                    }

                    Spacer()

                    VStack(spacing: 12) {
                        routeButton(
                            title: "Sign Up as Learner",
                            subtitle: "Get matched with a Fidelity mentor",
                            systemImage: "graduationcap.fill",
                            background: Color.ascendAccent,
                            destination: .learnerSignup
                        )

                        routeButton(
                            title: "Sign Up as Mentor",
                            subtitle: "Share your expertise with first-gen learners",
                            systemImage: "person.2.badge.gearshape.fill",
                            background: Color.ascendPrimary,
                            destination: .mentorSignup
                        )

                        routeButton(
                            title: "Log In",
                            subtitle: "Continue with an existing profile",
                            systemImage: "key.fill",
                            background: Color.ascendSurface,
                            destination: .login
                        )
                    }

                    Spacer()
                }
                .padding(.horizontal, 24)
            }
            .preferredColorScheme(.dark)
            .navigationDestination(item: $route) { route in
                switch route {
                case .learnerSignup: LearnerProfileCreationView()
                case .mentorSignup:  MentorProfileCreationView()
                case .login:         LoginView()
                }
            }
        }
    }

    private func routeButton(
        title: String,
        subtitle: String,
        systemImage: String,
        background: Color,
        destination: WelcomeRoute
    ) -> some View {
        Button {
            route = destination
        } label: {
            HStack(spacing: 16) {
                Image(systemName: systemImage)
                    .font(.title2)
                    .frame(width: 32)
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.headline)
                    Text(subtitle)
                        .font(.caption)
                        .opacity(0.85)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.footnote.weight(.semibold))
                    .opacity(0.7)
            }
            .foregroundColor(.white)
            .padding(.vertical, 16)
            .padding(.horizontal, 20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(background)
            )
        }
    }
}

#Preview {
    WelcomeView()
        .preferredColorScheme(.dark)
}
