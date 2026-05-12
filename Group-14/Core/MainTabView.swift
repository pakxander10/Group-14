//
//  MainTabView.swift
//  Group-14
//
//  Root tab container. Tab set is role-aware:
//    learner → Profile, Confidence, Match, Q Thread
//    mentor  → Profile, Q Thread
//

import SwiftUI

struct MainTabView: View {
    @AppStorage("userRole") private var userRole: String = ""

    var body: some View {
        TabView {
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.crop.circle.fill")
                }

            if userRole == UserRole.learner.storageValue {
                ConfidenceDashboardView()
                    .tabItem {
                        Label("Confidence", systemImage: "chart.bar.fill")
                    }

                QuestionnaireView()
                    .tabItem {
                        Label("Match", systemImage: "sparkles")
                    }
            }

            MentorThreadView()
                .tabItem {
                    Label("Q Thread", systemImage: "bubble.left.and.bubble.right.fill")
                }
        }
        .tint(.ascendAccent)
        .preferredColorScheme(.dark)
    }
}

#Preview {
    MainTabView()
}
