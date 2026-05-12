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
                Color.investBackground.ignoresSafeArea()

                VStack(spacing: 0) {
                    heroBand
                    Spacer(minLength: 24)

                    VStack(spacing: 12) {
                        routeButton(
                            title: "Sign Up as Learner",
                            subtitle: "Get matched learn from Experienced professionals in fintech industries",
                            systemImage: "graduationcap.fill",
                            background: Color.investPrimary,
                            foreground: .white,
                            destination: .learnerSignup
                        )

                        routeButton(
                            title: "Sign Up as Mentor",
                            subtitle: "Share your expertise with unique learners",
                            systemImage: "person.2.badge.gearshape.fill",
                            background: Color.investAccent,
                            foreground: .white,
                            destination: .mentorSignup
                        )

                        routeButton(
                            title: "Log In",
                            subtitle: "Continue with an existing profile",
                            systemImage: "key.fill",
                            background: Color.investSurface,
                            foreground: .investTitle,
                            destination: .login
                        )
                    }
                    .padding(.horizontal, 24)

                    Spacer(minLength: 24)
                }
            }
            .navigationDestination(item: $route) { route in
                switch route {
                case .learnerSignup: LearnerProfileCreationView()
                case .mentorSignup:  MentorProfileCreationView()
                case .login:         LoginView()
                }
            }
        }
    }

    private var heroBand: some View {
        VStack(spacing: 12) {
            Image(systemName: "sparkles")
                .font(.system(size: 48))
                .foregroundStyle(Color.investPrimary)
            Text("Welcome to InvestInMe")
                .font(.largeTitle.bold())
                .foregroundStyle(Color.investTitle)
                .multilineTextAlignment(.center)
            Text("Choose how you'd like to get started.")
                .font(.subheadline)
                .foregroundStyle(Color.investAccent)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 48)
        .padding(.horizontal, 24)
        .background(Color.investHeroBand)
        .overlay(
            Rectangle()
                .fill(Color.investBorder)
                .frame(height: 1),
            alignment: .bottom
        )
    }

    private func routeButton(
        title: String,
        subtitle: String,
        systemImage: String,
        background: Color,
        foreground: Color,
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
            .foregroundStyle(foreground)
            .padding(.vertical, 16)
            .padding(.horizontal, 20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(background)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(Color.investBorder, lineWidth: background == .investSurface ? 1 : 0)
                    )
            )
        }
    }
}

#Preview {
    WelcomeView()
}
